import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

class FitnessTrackerScreen extends StatefulWidget {
  final CameraDescription camera;
  const FitnessTrackerScreen({required this.camera, super.key});

  @override
  State<FitnessTrackerScreen> createState() => _FitnessTrackerScreenState();
}

class _FitnessTrackerScreenState extends State<FitnessTrackerScreen> {
  late CameraController _controller;
  late PoseDetector _poseDetector;
  
  // Core variables
  int sitUpCount = 0;
  bool isUp = false;
  bool isGoodForm = false;
  double formScore = 0.0;
  double estimatedHeight = 0.0;
  List<double> heightEstimates = [];
  List<Pose>? previousKeypoints;
  String status = "Ready";
  List<Map<String, dynamic>> outputData = [];
  List<LogEntry> logs = [];
  double scoreOutOf10 = 0.0;
  String phase = "countdown";
  late DateTime startTime;
  bool running = true;
  bool _isProcessing = false;
  
  // Current pose for skeleton drawing
  Pose? _currentPose;
  Size _imageSize = Size.zero;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _initializeCamera();
    _poseDetector = PoseDetector(options: PoseDetectorOptions());
    
    // Timer for phase updates
    Timer.periodic(const Duration(milliseconds: 33), (timer) {
      if (!running) {
        timer.cancel();
        return;
      }
      _updatePhase();
    });
  }

  Future<void> _initializeCamera() async {
    try {
      _controller = CameraController(
        widget.camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _controller.initialize();
      if (mounted) {
        _controller.startImageStream(_processImage);
        setState(() {});
      }
    } catch (e) {
      _addLog("Camera initialization failed: $e", Colors.red);
    }
  }

  void _processImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage != null) {
        final poses = await _poseDetector.processImage(inputImage);
        final pose = poses.isNotEmpty ? poses.first : null;
        
        // Update current pose for skeleton drawing
        if (pose != null && mounted) {
          setState(() {
            _currentPose = pose;
            _imageSize = Size(image.width.toDouble(), image.height.toDouble());
          });
        }
        
        final currentTime = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
        
        // Create frame output
        final frameOutput = {
          "frame": outputData.length,
          "time_s": currentTime,
          "phase": phase,
          "sit_up_count": sitUpCount,
          "is_good_form": formScore > 0.7,
          "form_score": formScore,
          "score_out_of_10": scoreOutOf10,
          "estimated_height_cm": estimatedHeight,
          "cheat_detected": status.contains("Cheat"),
          "status": status,
          "keypoints": pose != null ? _poseToKeypoints(pose) : null,
        };

        // Process based on phase
        if (phase == "height" && pose != null) {
          _estimateHeight(pose);
        } else if (phase == "situp" && pose != null) {
          _analyzeSitUps(pose);
          _detectCheat(pose);
        } else if (phase == "gap") {
          final avgHeight = heightEstimates.isNotEmpty 
              ? heightEstimates.reduce((a, b) => a + b) / heightEstimates.length 
              : 0.0;
          status = "Height Result: ${avgHeight.toStringAsFixed(1)} cm";
          _addLog(status, Colors.cyan);
        }

        outputData.add(frameOutput);
        
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      _addLog("Processing error: $e", Colors.red);
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final camera = widget.camera;
      final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
      if (imageRotation == null) return null;

      final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw);
      if (inputImageFormat == null) return null;

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: imageSize,
          rotation: imageRotation,
          format: inputImageFormat,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  List<List<double>> _poseToKeypoints(Pose pose) {
    return pose.landmarks.values.map((landmark) => [
      landmark.x,
      landmark.y,
      landmark.z,
      landmark.likelihood,
    ]).toList();
  }

  void _updatePhase() {
    final currentTime = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
    
    if (currentTime <= 10) {
      phase = "countdown";
    } else if (currentTime <= 30) {
      phase = "height";
    } else if (currentTime <= 40) {
      phase = "gap";
    } else if (currentTime <= 60) {
      phase = "situp";
    } else {
      running = false;
      _saveOutputs();
    }
  }

  void _estimateHeight(Pose pose) {
    try {
      final landmarks = pose.landmarks;
      final nose = landmarks[PoseLandmarkType.nose];
      final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
      final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];
      final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
      final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

      if (nose == null || leftAnkle == null || rightAnkle == null || 
          leftShoulder == null || rightShoulder == null) return;

      // Check visibility
      if (nose.likelihood < 0.7 || leftAnkle.likelihood < 0.7 || 
          rightAnkle.likelihood < 0.7 || leftShoulder.likelihood < 0.7 || 
          rightShoulder.likelihood < 0.7) {
        status = "Adjust position for height estimation";
        _addLog(status, Colors.yellow);
        return;
      }

      // Check if standing (shoulders above hips)
      final leftHip = landmarks[PoseLandmarkType.leftHip];
      final rightHip = landmarks[PoseLandmarkType.rightHip];
      
      if (leftHip != null && rightHip != null &&
          leftShoulder.y < leftHip.y && rightShoulder.y < rightHip.y) {
        
        final headToFoot = (nose.y - (leftAnkle.y + rightAnkle.y) / 2).abs();
        final depthFactor = 1.0 / (1 + nose.z.abs() + 1e-6);
        estimatedHeight = headToFoot * 165 / 0.8 * depthFactor;

        if (estimatedHeight >= 100 && estimatedHeight <= 250) {
          heightEstimates.add(estimatedHeight);
          status = "Height estimated";
          _addLog(status, Colors.green);
        } else {
          status = "Height estimate out of range";
          _addLog(status, Colors.yellow);
        }
      } else {
        status = "Stand up for height estimation";
        _addLog(status, Colors.yellow);
      }
    } catch (e) {
      status = "Height estimation error";
      _addLog(status, Colors.red);
    }
  }

  void _analyzeSitUps(Pose pose) {
    try {
      final landmarks = pose.landmarks;
      
      // Required keypoints
      final requiredTypes = [
        PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder,
        PoseLandmarkType.leftHip, PoseLandmarkType.rightHip,
        PoseLandmarkType.leftKnee, PoseLandmarkType.rightKnee,
        PoseLandmarkType.nose, PoseLandmarkType.leftWrist, PoseLandmarkType.rightWrist,
        PoseLandmarkType.leftAnkle, PoseLandmarkType.rightAnkle,
      ];

      final keypoints = <PoseLandmarkType, PoseLandmark>{};
      for (final type in requiredTypes) {
        final landmark = landmarks[type];
        if (landmark == null || landmark.likelihood < 0.5) {
          status = "Adjust position for sit-up analysis";
          formScore = 0.0;
          scoreOutOf10 = 0.0;
          isGoodForm = false;
          _addLog(status, Colors.yellow);
          return;
        }
        keypoints[type] = landmark;
      }

      // Calculate torso angle
      final shoulderY = (keypoints[PoseLandmarkType.leftShoulder]!.y + 
                       keypoints[PoseLandmarkType.rightShoulder]!.y) / 2;
      final hipY = (keypoints[PoseLandmarkType.leftHip]!.y + 
                   keypoints[PoseLandmarkType.rightHip]!.y) / 2;
      final kneeY = (keypoints[PoseLandmarkType.leftKnee]!.y + 
                    keypoints[PoseLandmarkType.rightKnee]!.y) / 2;

      final torsoVec = [0.0, shoulderY - hipY];
      final upperLegVec = [0.0, kneeY - hipY];
      
      final dotProduct = torsoVec[0] * upperLegVec[0] + torsoVec[1] * upperLegVec[1];
      final normTorso = sqrt(torsoVec[0] * torsoVec[0] + torsoVec[1] * torsoVec[1]);
      final normUpperLeg = sqrt(upperLegVec[0] * upperLegVec[0] + upperLegVec[1] * upperLegVec[1]);
      
      double torsoAngle = 0.0;
      if (normTorso * normUpperLeg > 1e-6) {
        final cosineAngle = (dotProduct / (normTorso * normUpperLeg)).clamp(-1.0, 1.0);
        torsoAngle = acos(cosineAngle) * 180 / pi;
      }

      // Calculate form score
      final nose = keypoints[PoseLandmarkType.nose]!;
      final leftWrist = keypoints[PoseLandmarkType.leftWrist]!;
      final rightWrist = keypoints[PoseLandmarkType.rightWrist]!;
      final leftShoulder = keypoints[PoseLandmarkType.leftShoulder]!;
      final rightShoulder = keypoints[PoseLandmarkType.rightShoulder]!;

      final leftWristDistToNose = sqrt(pow(leftWrist.x - nose.x, 2) + pow(leftWrist.y - nose.y, 2));
      final rightWristDistToNose = sqrt(pow(rightWrist.x - nose.x, 2) + pow(rightWrist.y - nose.y, 2));
      final shoulderDist = sqrt(pow(leftShoulder.x - rightShoulder.x, 2) + pow(leftShoulder.y - rightShoulder.y, 2));
      
      final normalizedWristDist = (leftWristDistToNose + rightWristDistToNose) / (2 * shoulderDist + 1e-6);

      // Ankle movement (simplified)
      double ankleMovement = 0.0;
      if (previousKeypoints != null && previousKeypoints!.isNotEmpty) {
        final prevLandmarks = previousKeypoints!.first.landmarks;
        final prevLeftAnkle = prevLandmarks[PoseLandmarkType.leftAnkle];
        final prevRightAnkle = prevLandmarks[PoseLandmarkType.rightAnkle];
        
        if (prevLeftAnkle != null && prevRightAnkle != null) {
          final leftAnkleMove = sqrt(pow(keypoints[PoseLandmarkType.leftAnkle]!.x - prevLeftAnkle.x, 2) + 
                                   pow(keypoints[PoseLandmarkType.leftAnkle]!.y - prevLeftAnkle.y, 2));
          final rightAnkleMove = sqrt(pow(keypoints[PoseLandmarkType.rightAnkle]!.x - prevRightAnkle.x, 2) + 
                                    pow(keypoints[PoseLandmarkType.rightAnkle]!.y - prevRightAnkle.y, 2));
          ankleMovement = (leftAnkleMove + rightAnkleMove) / 2;
        }
      }

      final wristScore = (1 - normalizedWristDist * 2.0).clamp(0.0, 1.0);
      final ankleScore = (1 - ankleMovement * 5.0).clamp(0.0, 1.0);
      formScore = (wristScore + ankleScore) / 2.0;
      scoreOutOf10 = formScore * 10;
      isGoodForm = formScore > 0.7;

      // Sit-up counting logic
      if (isGoodForm) {
        if (torsoAngle > 60 && !isUp) {
          isUp = true;
          status = "Going up";
          _addLog(status, Colors.green);
        } else if (torsoAngle < 30 && isUp) {
          isUp = false;
          sitUpCount++;
          status = "Rep counted!";
          _addLog(status, Colors.green);
        } else {
          status = "Performing sit-up";
          _addLog(status, Colors.green);
        }
      } else {
        status = "Bad form - improve form for rep count";
        _addLog(status, Colors.yellow);
      }

      previousKeypoints = [pose];
    } catch (e) {
      status = "Analysis error";
      formScore = 0.0;
      scoreOutOf10 = 0.0;
      isGoodForm = false;
      _addLog(status, Colors.red);
    }
  }

  void _detectCheat(Pose pose) {
    if (previousKeypoints == null || previousKeypoints!.isEmpty) return;

    try {
      final landmarks = pose.landmarks;
      final prevLandmarks = previousKeypoints!.first.landmarks;
      
      final hip = landmarks[PoseLandmarkType.leftHip];
      final prevHip = prevLandmarks[PoseLandmarkType.leftHip];
      
      if (hip != null && prevHip != null) {
        final hipDelta = sqrt(pow(hip.x - prevHip.x, 2) + pow(hip.y - prevHip.y, 2));
        if (hipDelta > 0.1) {
          status = "Cheat detected! Sudden movement.";
          _addLog(status, Colors.red);
          return;
        }
      }

      if (phase == "situp") {
        final lowerBodyTypes = [
          PoseLandmarkType.leftHip, PoseLandmarkType.rightHip,
          PoseLandmarkType.leftKnee, PoseLandmarkType.rightKnee,
          PoseLandmarkType.leftAnkle, PoseLandmarkType.rightAnkle,
        ];
        
        final confidences = lowerBodyTypes
            .map((type) => landmarks[type]?.likelihood ?? 0.0)
            .toList();
        
        final avgConfidence = confidences.reduce((a, b) => a + b) / confidences.length;
        if (avgConfidence < 0.4) {
          status = "Cheat detected! Lower body not visible.";
          _addLog(status, Colors.red);
        }
      }
    } catch (e) {
      status = "Cheat detection error";
      _addLog(status, Colors.red);
    }
  }

  void _addLog(String message, Color color) {
    logs.add(LogEntry(message, color));
    if (logs.length > 4) {
      logs.removeAt(0);
    }
  }

  Future<void> _saveOutputs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/blazepose_outputs.json');
      await file.writeAsString(jsonEncode(outputData));
      _addLog("Outputs saved to ${file.path}", Colors.green);
    } catch (e) {
      _addLog("Error saving JSON: $e", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentTime = DateTime.now().difference(startTime).inMilliseconds / 1000.0;

    return Scaffold(
      body: Stack(
        children: [
          // Camera preview
          CameraPreview(_controller),
          
          // Skeleton overlay during height measurement
          if (phase == "height" && _currentPose != null)
            CustomPaint(
              painter: SkeletonOverlayPainter(
                pose: _currentPose!,
                imageSize: _imageSize,
              ),
              child: Container(),
            ),
          
          // Custom painter for UI overlays
          CustomPaint(
            painter: PosePainter(
              currentTime: currentTime,
              phase: phase,
              status: status,
              formScore: formScore,
              scoreOutOf10: scoreOutOf10,
              sitUpCount: sitUpCount,
              heightEstimates: heightEstimates,
              logs: logs,
            ),
            child: Container(),
          ),
          
          // Bottom info panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Rep Count: $sitUpCount",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: formScore < 0.5 
                          ? Colors.red 
                          : formScore < 0.8 
                              ? Colors.yellow 
                              : Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "Form: ${formScore.toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Score: ${scoreOutOf10.toStringAsFixed(1)}/10",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Height: ${heightEstimates.isNotEmpty ? (heightEstimates.reduce((a, b) => a + b) / heightEstimates.length).toStringAsFixed(1) : '0.0'} cm",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    running = false;
    _controller.dispose();
    _poseDetector.close();
    _saveOutputs();
    super.dispose();
  }
}

class PosePainter extends CustomPainter {
  final double currentTime;
  final String phase;
  final String status;
  final double formScore;
  final double scoreOutOf10;
  final int sitUpCount;
  final List<double> heightEstimates;
  final List<LogEntry> logs;

  PosePainter({
    required this.currentTime,
    required this.phase,
    required this.status,
    required this.formScore,
    required this.scoreOutOf10,
    required this.sitUpCount,
    required this.heightEstimates,
    required this.logs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw time
    _drawText(canvas, "Time: ${currentTime.toStringAsFixed(1)}s", 
              const Offset(10, 30), Colors.white, 20);
    
    // Draw status
    _drawText(canvas, status, const Offset(10, 60), Colors.green, 18);
    
    // Draw phase-specific info
    if (phase == "countdown") {
      final countdown = (10 - currentTime).ceil();
      _drawText(canvas, "Get Ready: $countdown", 
                const Offset(10, 90), Colors.red, 24);
    } else if (phase == "height") {
      _drawText(canvas, "Height Estimating", 
                const Offset(10, 90), Colors.blue, 24);
      if (heightEstimates.isNotEmpty) {
        final current = heightEstimates.last;
        _drawText(canvas, "Current: ${current.toStringAsFixed(1)} cm", 
                  const Offset(10, 120), Colors.cyan, 16);
      }
      
      // Draw skeleton guidance text
      _drawText(canvas, "Stand straight - Skeleton visible", 
                const Offset(10, 150), Colors.green, 14);
    } else if (phase == "gap") {
      final avgHeight = heightEstimates.isNotEmpty 
          ? heightEstimates.reduce((a, b) => a + b) / heightEstimates.length 
          : 0.0;
      _drawText(canvas, "Height Result: ${avgHeight.toStringAsFixed(1)} cm", 
                const Offset(10, 90), Colors.cyan, 24);
      final countdown = (40 - currentTime).ceil();
      _drawText(canvas, "Get Ready for Sit-Ups: $countdown", 
                const Offset(10, 120), Colors.red, 18);
    } else if (phase == "situp") {
      _drawText(canvas, "Sit-Ups: $sitUpCount", 
                const Offset(10, 90), Colors.yellow, 24);
      
      // Form bar
      final barColor = formScore < 0.5 
          ? Colors.red 
          : formScore < 0.8 
              ? Colors.yellow 
              : Colors.green;
      
      final paint = Paint()..color = barColor;
      canvas.drawRect(
        Rect.fromLTWH(10, 120, 200 * formScore, 20),
        paint,
      );
      
      _drawText(canvas, "Form", const Offset(220, 135), Colors.white, 14);
      _drawText(canvas, "Score: ${scoreOutOf10.toStringAsFixed(1)}/10", 
                const Offset(10, 170), Colors.white, 18);
    }
    
    // Draw logs
    for (int i = 0; i < logs.length; i++) {
      final log = logs[i];
      _drawText(canvas, log.message, 
                Offset(10, size.height - 80 + i * 15), log.color, 12);
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color color, double fontSize) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LogEntry {
  final String message;
  final Color color;
  
  LogEntry(this.message, this.color);
}

class SkeletonOverlayPainter extends CustomPainter {
  final Pose pose;
  final Size imageSize;

  SkeletonOverlayPainter({
    required this.pose,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize == Size.zero) return;
    
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.8)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final jointPaint = Paint()
      ..color = Colors.red.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final landmarks = pose.landmarks;
    
    // Scale factors
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    // Helper function to get scaled point
    Offset? getScaledPoint(PoseLandmarkType type) {
      final landmark = landmarks[type];
      if (landmark != null && landmark.likelihood > 0.6) {
        return Offset(
          landmark.x * scaleX,
          landmark.y * scaleY,
        );
      }
      return null;
    }

    // Google ML Kit BlazePose connections
    final connections = [
      // Face
      [PoseLandmarkType.leftEyeInner, PoseLandmarkType.leftEye],
      [PoseLandmarkType.leftEye, PoseLandmarkType.leftEyeOuter],
      [PoseLandmarkType.rightEyeInner, PoseLandmarkType.rightEye],
      [PoseLandmarkType.rightEye, PoseLandmarkType.rightEyeOuter],
      [PoseLandmarkType.leftEyeOuter, PoseLandmarkType.leftEar],
      [PoseLandmarkType.rightEyeOuter, PoseLandmarkType.rightEar],
      [PoseLandmarkType.leftMouth, PoseLandmarkType.rightMouth],
      
      // Torso
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
      
      // Left arm
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
      [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
      [PoseLandmarkType.leftWrist, PoseLandmarkType.leftPinky],
      [PoseLandmarkType.leftWrist, PoseLandmarkType.leftIndex],
      [PoseLandmarkType.leftWrist, PoseLandmarkType.leftThumb],
      
      // Right arm
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
      [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
      [PoseLandmarkType.rightWrist, PoseLandmarkType.rightPinky],
      [PoseLandmarkType.rightWrist, PoseLandmarkType.rightIndex],
      [PoseLandmarkType.rightWrist, PoseLandmarkType.rightThumb],
      
      // Left leg
      [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
      [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
      [PoseLandmarkType.leftAnkle, PoseLandmarkType.leftHeel],
      [PoseLandmarkType.leftAnkle, PoseLandmarkType.leftFootIndex],
      
      // Right leg
      [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
      [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
      [PoseLandmarkType.rightAnkle, PoseLandmarkType.rightHeel],
      [PoseLandmarkType.rightAnkle, PoseLandmarkType.rightFootIndex],
    ];

    // Draw connections only if both points are detected
    for (final connection in connections) {
      final point1 = getScaledPoint(connection[0]);
      final point2 = getScaledPoint(connection[1]);
      
      if (point1 != null && point2 != null) {
        canvas.drawLine(point1, point2, paint);
      }
    }

    // Draw key joints only
    final keyJoints = [
      PoseLandmarkType.nose,
      PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftElbow, PoseLandmarkType.rightElbow,
      PoseLandmarkType.leftWrist, PoseLandmarkType.rightWrist,
      PoseLandmarkType.leftHip, PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee, PoseLandmarkType.rightKnee,
      PoseLandmarkType.leftAnkle, PoseLandmarkType.rightAnkle,
    ];
    
    for (final jointType in keyJoints) {
      final point = getScaledPoint(jointType);
      if (point != null) {
        canvas.drawCircle(point, 5, jointPaint);
      }
    }

    // Draw height measurement line
    final nose = getScaledPoint(PoseLandmarkType.nose);
    final leftAnkle = getScaledPoint(PoseLandmarkType.leftAnkle);
    final rightAnkle = getScaledPoint(PoseLandmarkType.rightAnkle);
    
    if (nose != null && leftAnkle != null && rightAnkle != null) {
      final avgAnkle = Offset(
        (leftAnkle.dx + rightAnkle.dx) / 2,
        (leftAnkle.dy + rightAnkle.dy) / 2,
      );
      
      final heightPaint = Paint()
        ..color = Colors.cyan.withOpacity(0.8)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(nose, avgAnkle, heightPaint);
      canvas.drawCircle(nose, 6, Paint()..color = Colors.cyan);
      canvas.drawCircle(avgAnkle, 6, Paint()..color = Colors.cyan);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WriteBuffer {
  final List<int> _buffer = [];
  
  void putUint8List(List<int> list) {
    _buffer.addAll(list);
  }
  
  ByteData done() {
    final bytes = Uint8List.fromList(_buffer);
    return ByteData.view(bytes.buffer);
  }
}