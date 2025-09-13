import cv2
import numpy as np
import mediapipe as mp
import json
import time
from PyQt5.QtWidgets import QApplication, QMainWindow, QLabel, QVBoxLayout, QWidget
from PyQt5.QtGui import QImage, QPixmap
from PyQt5.QtCore import Qt, QTimer
import sys
import os

# Initialize MediaPipe Pose
mp_pose = mp.solutions.pose
pose = mp_pose.Pose(static_image_mode=False, model_complexity=2, enable_segmentation=False, min_detection_confidence=0.5)
mp_drawing = mp.solutions.drawing_utils

# BlazePose keypoint connections
connections = [
    (0, 1), (0, 4), (1, 2), (2, 3), (3, 7), (4, 5), (5, 6), (6, 8),
    (9, 10), (11, 12), (11, 13), (12, 14), (13, 15), (14, 16),
    (15, 17), (15, 19), (15, 21), (16, 18), (16, 20), (16, 22),
    (11, 23), (12, 24), (23, 24), (23, 25), (24, 26),
    (25, 27), (26, 28), (27, 29), (28, 30), (29, 31), (30, 32)
]

# Variables
sit_up_count = 0
is_up = False
is_good_form = False
form_score = 0.0
estimated_height = 0.0
height_estimates = []
previous_keypoints = None
status = "Ready"
output_data = []
start_time = time.time()
frame_width = 640
frame_height = 480
score_out_of_10 = 0.0
logs = []
running = True

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Fitness Tracker")
        self.setGeometry(100, 100, 700, 700)

        # GUI Widgets
        self.video_label = QLabel(self)
        self.video_label.setFixedSize(frame_width, frame_height)
        self.time_label = QLabel("Time: 0.0s", self)
        self.status_label = QLabel("Status: Ready", self)
        self.rep_label = QLabel("Rep Count: 0", self)
        self.form_label = QLabel("Form: 0.0", self)
        self.score_label = QLabel("Score: 0.0/10", self)
        self.height_label = QLabel("Height: Estimating...", self)

        # Layout
        layout = QVBoxLayout()
        layout.addWidget(self.video_label)
        layout.addWidget(self.time_label)
        layout.addWidget(self.status_label)
        layout.addWidget(self.rep_label)
        layout.addWidget(self.form_label)
        layout.addWidget(self.score_label)
        layout.addWidget(self.height_label)

        container = QWidget()
        container.setLayout(layout)
        self.setCentralWidget(container)

        # Webcam
        self.cap = cv2.VideoCapture(0)
        if not self.cap.isOpened():
            print("Error: Could not open webcam. Ensure a camera is connected.")
            sys.exit(1)
        self.cap.set(cv2.CAP_PROP_FRAME_WIDTH, frame_width)
        self.cap.set(cv2.CAP_PROP_FRAME_HEIGHT, frame_height)

        # Timer for video processing
        self.timer = QTimer()
        self.timer.timeout.connect(self.process_frame)
        self.timer.start(33)  # ~30 FPS

    def process_frame(self):
        global sit_up_count, is_up, is_good_form, form_score, estimated_height, height_estimates, previous_keypoints, status, output_data, phase, score_out_of_10, running
        if not running:
            self.timer.stop()
            self.cap.release()
            pose.close()
            self.save_outputs()
            self.close()
            return

        current_time = time.time() - start_time
        phase = "countdown"
        if current_time > 10:
            phase = "height"
        if current_time > 30:
            phase = "gap"
        if current_time > 40:
            phase = "situp"

        ret, frame = self.cap.read()
        if not ret:
            print("Error: Failed to capture frame")
            return
        frame = cv2.flip(frame, 1)
        input_image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        keypoints = run_inference(input_image)

        frame_output = {
            "frame": len(output_data),
            "time_s": current_time,
            "phase": phase,
            "sit_up_count": sit_up_count,
            "is_good_form": form_score > 0.7,
            "form_score": float(form_score),
            "score_out_of_10": float(score_out_of_10),
            "estimated_height_cm": float(estimated_height),
            "cheat_detected": "Cheat detected" in status,
            "status": status,
            "keypoints": [kp.tolist() for kp in keypoints] if keypoints is not None else None
        }

        if phase == "height" and keypoints is not None:
            estimate_height(keypoints)
        elif phase == "situp" and keypoints is not None:
            analyze_sit_ups(keypoints)
            detect_cheat(keypoints)
        elif phase == "gap":
            avg_height = np.median(height_estimates) if height_estimates else 0.0
            status = f"Height Result: {avg_height:.1f} cm"
            logs.append((status, (0, 255, 255)))

        output_data.append(frame_output)
        draw_skeleton(frame, keypoints)
        draw_ui(frame, current_time, phase)

        # Update GUI
        self.update_gui(current_time, phase, frame)

    def update_gui(self, current_time, phase, frame):
        self.time_label.setText(f"Time: {current_time:.1f}s")
        self.status_label.setText(f"Status: {status}")
        self.rep_label.setText(f"Rep Count: {sit_up_count}")
        self.form_label.setText(f"Form: {form_score:.2f}")
        self.score_label.setText(f"Score: {score_out_of_10:.1f}/10")
        if phase == "height" and height_estimates:
            self.height_label.setText(f"Height: {np.median(height_estimates):.1f} cm")
        elif phase in ["gap", "situp"]:
            self.height_label.setText(f"Height Result: {np.median(height_estimates) if height_estimates else 0.0:.1f} cm")

        # Form bar color
        form_color = "red" if form_score < 0.5 else "yellow" if form_score < 0.8 else "green"
        self.form_label.setStyleSheet(f"background-color: {form_color}; color: white; padding: 5px;")

        # Display video frame
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        h, w, ch = frame_rgb.shape
        bytes_per_line = ch * w
        q_image = QImage(frame_rgb.data, w, h, bytes_per_line, QImage.Format_RGB888)
        self.video_label.setPixmap(QPixmap.fromImage(q_image))

    def save_outputs(self):
        try:
            output_path = os.path.join(os.getcwd(), "blazepose_outputs.json")
            with open(output_path, 'w') as f:
                json.dump(output_data, f, indent=4)
            print(f"Outputs saved to {output_path}")
            logs.append((f"Outputs saved to {output_path}", (0, 255, 0)))
        except Exception as e:
            print(f"Error saving JSON: {e}")
            logs.append((f"Error saving JSON: {e}", (0, 0, 255)))

    def closeEvent(self, event):
        global running
        running = False
        self.timer.stop()
        self.cap.release()
        pose.close()
        self.save_outputs()
        event.accept()

def run_inference(image):
    try:
        results = pose.process(image)
        if not results.pose_landmarks:
            return None
        keypoints = [(lm.x, lm.y, lm.z, lm.visibility) for lm in results.pose_landmarks.landmark]
        return np.array(keypoints)
    except Exception as e:
        print(f"Inference error: {e}")
        return None

def draw_skeleton(frame, keypoints):
    if keypoints is None:
        return
    for i, kp in enumerate(keypoints):
        if kp[3] > 0.5:
            x = int(kp[0] * frame_width)
            y = int(kp[1] * frame_height)
            cv2.circle(frame, (x, y), 5, (0, 255, 0), -1)
    for conn in connections:
        kp1 = keypoints[conn[0]]
        kp2 = keypoints[conn[1]]
        if kp1[3] > 0.5 and kp2[3] > 0.5:
            x1, y1 = int(kp1[0] * frame_width), int(kp1[1] * frame_height)
            x2, y2 = int(kp2[0] * frame_width), int(kp2[1] * frame_height)
            cv2.line(frame, (x1, y1), (x2, y2), (0, 255, 255), 2)

def estimate_height(keypoints):
    global estimated_height, status, height_estimates, logs
    if keypoints is None:
        return
    try:
        if (keypoints[0][3] < 0.7 or keypoints[31][3] < 0.7 or keypoints[32][3] < 0.7 or
            keypoints[11][3] < 0.7 or keypoints[12][3] < 0.7):
            status = "Adjust position for height estimation"
            logs.append((status, (255, 255, 0)))
            return
        if keypoints[11][1] < keypoints[23][1] and keypoints[12][1] < keypoints[24][1]:
            head_to_foot = abs(keypoints[0][1] - (keypoints[31][1] + keypoints[32][1]) / 2)
            depth_factor = 1.0 / (1 + abs(keypoints[0][2]) + 1e-6)
            estimated_height = head_to_foot * 165 / 0.8 * depth_factor
            if 100 <= estimated_height <= 250:
                height_estimates.append(estimated_height)
                status = "Height estimated"
                logs.append((status, (0, 255, 0)))
            else:
                status = "Height estimate out of range"
                logs.append((status, (255, 255, 0)))
        else:
            status = "Stand up for height estimation"
            logs.append((status, (255, 255, 0)))
    except Exception as e:
        print(f"Height estimation error: {e}")
        status = "Height estimation error"
        logs.append((status, (0, 0, 255)))

def analyze_sit_ups(keypoints):
    global sit_up_count, is_up, is_good_form, form_score, status, previous_keypoints, score_out_of_10, logs
    if keypoints is None:
        status = "Low confidence keypoints"
        form_score = 0.0
        score_out_of_10 = 0.0
        is_good_form = False
        logs.append((status, (255, 255, 0)))
        return
    try:
        required_keypoints = [11, 12, 23, 24, 25, 26, 0, 15, 16, 31, 32]
        if any(keypoints[i][3] < 0.5 for i in required_keypoints):
            status = "Adjust position for sit-up analysis"
            form_score = 0.0
            score_out_of_10 = 0.0
            is_good_form = False
            logs.append((status, (255, 255, 0)))
            return
        shoulder_y = (keypoints[11][1] + keypoints[12][1]) / 2
        hip_y = (keypoints[23][1] + keypoints[24][1]) / 2
        knee_y = (keypoints[25][1] + keypoints[26][1]) / 2
        torso_vec = np.array([0, shoulder_y - hip_y])
        upper_leg_vec = np.array([0, knee_y - hip_y])
        dot_product = np.dot(torso_vec, upper_leg_vec)
        norm_torso = np.linalg.norm(torso_vec)
        norm_upper_leg = np.linalg.norm(upper_leg_vec)
        if norm_torso * norm_upper_leg < 1e-6:
            torso_angle = 0.0
        else:
            cosine_angle = np.clip(dot_product / (norm_torso * norm_upper_leg), -1.0, 1.0)
            torso_angle = np.arccos(cosine_angle) * 180 / np.pi
        left_wrist_dist_to_nose = np.linalg.norm(np.array([keypoints[15][0], keypoints[15][1]]) - np.array([keypoints[0][0], keypoints[0][1]]))
        right_wrist_dist_to_nose = np.linalg.norm(np.array([keypoints[16][0], keypoints[16][1]]) - np.array([keypoints[0][0], keypoints[0][1]]))
        shoulder_dist = np.linalg.norm(np.array([keypoints[11][0], keypoints[11][1]]) - np.array([keypoints[12][0], keypoints[12][1]]))
        normalized_wrist_dist = (left_wrist_dist_to_nose + right_wrist_dist_to_nose) / (2 * shoulder_dist + 1e-6)
        ankle_movement = 0.0
        if previous_keypoints is not None:
            ankle_movement = (np.linalg.norm(np.array([keypoints[31][0], keypoints[31][1]]) - np.array([previous_keypoints[31][0], previous_keypoints[31][1]])) +
                              np.linalg.norm(np.array([keypoints[32][0], keypoints[32][1]]) - np.array([previous_keypoints[32][0], previous_keypoints[32][1]]))) / 2
        wrist_score = max(0, 1 - normalized_wrist_dist * 2.0)
        ankle_score = max(0, 1 - ankle_movement * 5.0)
        form_score = (wrist_score + ankle_score) / 2.0
        score_out_of_10 = form_score * 10
        is_good_form = form_score > 0.7
        if is_good_form:
            if torso_angle > 60 and not is_up:
                is_up = True
                status = "Going up"
                logs.append((status, (0, 255, 0)))
            elif torso_angle < 30 and is_up:
                is_up = False
                sit_up_count += 1
                status = "Rep counted!"
                logs.append((status, (0, 255, 0)))
            else:
                status = "Performing sit-up"
                logs.append((status, (0, 255, 0)))
        else:
            status = "Bad form - improve form for rep count"
            logs.append((status, (255, 255, 0)))
        previous_keypoints = keypoints.copy()
    except Exception as e:
        print(f"Sit-up analysis error: {e}")
        status = "Analysis error"
        form_score = 0.0
        score_out_of_10 = 0.0
        is_good_form = False
        logs.append((status, (0, 0, 255)))

def detect_cheat(keypoints):
    global status, previous_keypoints, logs
    if keypoints is None or previous_keypoints is None:
        return
    try:
        hip_delta = np.linalg.norm(np.array([keypoints[23][0], keypoints[23][1]]) - np.array([previous_keypoints[23][0], previous_keypoints[23][1]]))
        if hip_delta > 0.1:
            status = "Cheat detected! Sudden movement."
            logs.append((status, (0, 0, 255)))
        if phase == "situp":
            lower_body_conf = np.mean([keypoints[i][3] for i in [23, 24, 25, 26, 31, 32]])
            if lower_body_conf < 0.4:
                status = "Cheat detected! Lower body not visible."
                logs.append((status, (0, 0, 255)))
    except Exception as e:
        print(f"Cheat detection error: {e}")
        status = "Cheat detection error"
        logs.append((status, (0, 0, 255)))

def draw_ui(frame, current_time, phase):
    cv2.putText(frame, f"Time: {current_time:.1f}s", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 255, 255), 2)
    cv2.putText(frame, status, (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 0), 2)
    if phase == "countdown":
        countdown = int(10 - current_time)
        cv2.putText(frame, f"Get Ready: {countdown}", (10, 90), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2)
    elif phase == "height":
        cv2.putText(frame, "Height Estimating", (10, 90), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)
        if height_estimates:
            cv2.putText(frame, f"Current: {estimated_height:.1f} cm", (10, 120), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 255), 2)
    elif phase == "gap":
        avg_height = np.median(height_estimates) if height_estimates else 0.0
        cv2.putText(frame, f"Height Result: {avg_height:.1f} cm", (10, 90), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 255), 2)
        countdown = int(40 - current_time)
        cv2.putText(frame, f"Get Ready for Sit-Ups: {countdown}", (10, 120), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 0, 0), 2)
    elif phase == "situp":
        cv2.putText(frame, f"Sit-Ups: {sit_up_count}", (10, 90), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 0), 2)
        bar_color = (0, 0, 255) if form_score < 0.5 else (0, 255, 255) if form_score < 0.8 else (0, 255, 0)
        cv2.rectangle(frame, (10, 120), (10 + int(200 * form_score), 140), bar_color, -1)
        cv2.putText(frame, "Form", (220, 135), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
        cv2.putText(frame, f"Score: {score_out_of_10:.1f}/10", (10, 170), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 255, 255), 2)
    log_y_start = frame_height - 80
    for i, (msg, color) in enumerate(logs[-4:]):
        cv2.putText(frame, msg, (10, log_y_start + i * 15), cv2.FONT_HERSHEY_SIMPLEX, 0.4, color, 1)

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec_())