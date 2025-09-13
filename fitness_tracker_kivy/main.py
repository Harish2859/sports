import kivy
kivy.require('2.2.1')
from kivy.app import App
from kivy.uix.widget import Widget
from kivy.uix.label import Label
from kivy.clock import Clock
from kivy.graphics import Color, Ellipse, Line, Rectangle
from kivy.uix.image import Image
from kivy.uix.camera import Camera
import numpy as np
import mediapipe as mp
import cv2
import json
import time
import os
from kivy.core.window import Window

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

class FitnessTrackerWidget(Widget):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.frame_width = frame_width
        self.frame_height = frame_height
        self.camera = Camera(resolution=(frame_width, frame_height), play=True, index=0)
        self.image = Image(size=(frame_width, frame_height))
        self.add_widget(self.image)
        
        # GUI Labels
        self.time_label = Label(text="Time: 0.0s", pos=(10, Window.height - 30), color=(1, 1, 1, 1))
        self.status_label = Label(text="Status: Ready", pos=(10, Window.height - 60), color=(0, 1, 0, 1))
        self.rep_label = Label(text="Rep Count: 0", pos=(10, Window.height - 90), color=(1, 1, 1, 1))
        self.form_label = Label(text="Form: 0.0", pos=(10, Window.height - 120), color=(1, 1, 1, 1))
        self.score_label = Label(text="Score: 0.0/10", pos=(10, Window.height - 150), color=(1, 1, 1, 1))
        self.height_label = Label(text="Height: Estimating...", pos=(10, Window.height - 180), color=(1, 1, 1, 1))
        
        self.add_widget(self.time_label)
        self.add_widget(self.status_label)
        self.add_widget(self.rep_label)
        self.add_widget(self.form_label)
        self.add_widget(self.score_label)
        self.add_widget(self.height_label)
        
        Clock.schedule_interval(self.process_frame, 1.0 / 30.0)

    def process_frame(self, dt):
        global sit_up_count, is_up, is_good_form, form_score, estimated_height, height_estimates, previous_keypoints, status, output_data, score_out_of_10, running
        if not running:
            Clock.unschedule(self.process_frame)
            pose.close()
            self.save_outputs()
            App.get_running_app().stop()
            return

        current_time = time.time() - start_time
        phase = "countdown" if current_time <= 10 else "height" if current_time <= 30 else "gap" if current_time <= 40 else "situp"

        texture = self.camera.texture
        if not texture:
            return
        pixels = texture.pixels
        frame = np.frombuffer(pixels, dtype=np.uint8).reshape(texture.height, texture.width, 4)
        frame = cv2.cvtColor(frame, cv2.COLOR_RGBA2RGB)
        frame = cv2.flip(frame, 1)
        input_image = frame.copy()
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
        self.draw_ui(frame, current_time, phase, keypoints)
        self.update_gui(current_time, phase, frame)

        if current_time > 60:
            global running
            running = False

    def update_gui(self, current_time, phase, frame):
        self.time_label.text = f"Time: {current_time:.1f}s"
        self.status_label.text = f"Status: {status}"
        self.rep_label.text = f"Rep Count: {sit_up_count}"
        self.form_label.text = f"Form: {form_score:.2f}"
        self.score_label.text = f"Score: {score_out_of_10:.1f}/10"
        if phase == "height" and height_estimates:
            self.height_label.text = f"Height: {np.median(height_estimates):.1f} cm"
        elif phase in ["gap", "situp"]:
            self.height_label.text = f"Height Result: {np.median(height_estimates) if height_estimates else 0.0:.1f} cm"
        
        form_color = (1, 0, 0) if form_score < 0.5 else (1, 1, 0) if form_score < 0.8 else (0, 1, 0)
        self.form_label.color = form_color + (1,)

    def draw_ui(self, frame, current_time, phase, keypoints):
        with self.canvas:
            self.canvas.clear()
            if keypoints is not None:
                for i, kp in enumerate(keypoints):
                    if kp[3] > 0.5:
                        x, y = kp[0] * self.frame_width, self.frame_height - kp[1] * self.frame_height
                        Color(0, 1, 0, 1)
                        Ellipse(pos=(x - 5, y - 5), size=(10, 10))
                for conn in connections:
                    kp1 = keypoints[conn[0]]
                    kp2 = keypoints[conn[1]]
                    if kp1[3] > 0.5 and kp2[3] > 0.5:
                        x1, y1 = kp1[0] * self.frame_width, self.frame_height - kp1[1] * self.frame_height
                        x2, y2 = kp2[0] * self.frame_width, self.frame_height - kp2[1] * self.frame_height
                        Color(1, 1, 0, 1)
                        Line(points=[x1, y1, x2, y2], width=2)

    def save_outputs(self):
        try:
            from android.storage import primary_external_storage_path
            storage_path = primary_external_storage_path()
            output_path = os.path.join(storage_path, "blazepose_outputs.json")
        except:
            output_path = "/sdcard/blazepose_outputs.json"
        
        try:
            with open(output_path, 'w') as f:
                json.dump(output_data, f, indent=4)
            print(f"Outputs saved to {output_path}")
        except Exception as e:
            print(f"Error saving JSON: {e}")

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
        lower_body_conf = np.mean([keypoints[i][3] for i in [23, 24, 25, 26, 31, 32]])
        if lower_body_conf < 0.4:
            status = "Cheat detected! Lower body not visible."
            logs.append((status, (0, 0, 255)))
    except Exception as e:
        print(f"Cheat detection error: {e}")
        status = "Cheat detection error"
        logs.append((status, (0, 0, 255)))

class FitnessTrackerApp(App):
    def build(self):
        return FitnessTrackerWidget()

if __name__ == '__main__':
    FitnessTrackerApp().run()