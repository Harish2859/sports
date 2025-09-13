import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:ui' as ui;
import '../services/height_assessment_service.dart';

class FullScreenRecorder extends StatefulWidget {
  final CameraDescription camera;
  final String title;

  const FullScreenRecorder({
    super.key,
    required this.camera,
    required this.title,
  });

  @override
  State<FullScreenRecorder> createState() => _FullScreenRecorderState();
}

class _FullScreenRecorderState extends State<FullScreenRecorder> {
  late CameraController _controller;
  late PoseDetector _poseDetector;
  bool _isInitialized = false;
  bool _isRecording = false;
  String _recordingTime = "00:00";
  DateTime? _recordingStartTime;
  bool _isProcessing = false;
  
  // Assessment phases
  String _phase = "height";
  int _countdown = 10;
  Timer? _countdownTimer;
  
  // Height measurement
  double _estimatedHeight = 0.0;
  List<double> _heightEstimates = [];
  bool _heightAnalysisComplete = false;
  HeightAssessmentResult? _heightAssessment;
  
  // Sit-up tracking
  int _sitUpCount = 0;
  bool _isUp = false;
  double _formScore = 0.0;
  List<Pose>? _previousPoses;
  
  // UI state
  String _instruction = "Stand straight for height measurement";
  Color _formBarColor = Colors.red;
  
  // Pose data for skeleton drawing
  Pose? _currentPose;
  Size _imageSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _poseDetector = PoseDetector(options: PoseDetectorOptions());
    _startCountdown();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: true,
    );
    await _controller.initialize();
    if (mounted) {
      _controller.startImageStream(_processImage);
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _processImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage != null) {
        final poses = await _poseDetector.processImage(inputImage);
        if (poses.isNotEmpty) {
          final pose = poses.first;
          
          if (mounted) {
            setState(() {
              _currentPose = pose;
              _imageSize = Size(image.width.toDouble(), image.height.toDouble());
            });
          }
          
          if (_phase == "height") {
            _estimateHeight(pose);
          } else if (_phase == "situp") {
            _analyzeSitUps(pose);
          }
        }
      }
    } catch (e) {
      print('Processing error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final allBytes = <int>[];
      for (final plane in image.planes) {
        allBytes.addAll(plane.bytes);
      }
      final bytes = Uint8List.fromList(allBytes);

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
      return inputImage;
    } catch (e) {
      return null;
    }
  }

  void _estimateHeight(Pose pose) {
    final landmarks = pose.landmarks;
    final nose = landmarks[PoseLandmarkType.nose];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];

    if (nose != null && leftAnkle != null && rightAnkle != null &&
        leftShoulder != null && rightShoulder != null && leftHip != null && rightHip != null &&
        nose.likelihood > 0.7 && leftAnkle.likelihood > 0.7 && rightAnkle.likelihood > 0.7) {
      
      // Check if person is standing upright
      final shoulderY = (leftShoulder.y + rightShoulder.y) / 2;
      final hipY = (leftHip.y + rightHip.y) / 2;
      
      if (shoulderY < hipY) { // Standing upright
        final headToFoot = (nose.y - (leftAnkle.y + rightAnkle.y) / 2).abs();
        final depthFactor = 1.0 / (1 + nose.z.abs() + 1e-6);
        final estimatedHeight = headToFoot * 165 / 0.8 * depthFactor;

        if (estimatedHeight >= 100 && estimatedHeight <= 250) {
          _heightEstimates.add(estimatedHeight);
          if (mounted) {
            setState(() {
              _estimatedHeight = _heightEstimates.reduce((a, b) => a + b) / _heightEstimates.length;
            });
          }
        }
      }
    }
  }

  void _analyzeSitUps(Pose pose) {
    final landmarks = pose.landmarks;
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];

    if (leftShoulder != null && rightShoulder != null && leftHip != null && 
        rightHip != null && leftKnee != null && rightKnee != null) {
      
      // Calculate torso angle
      final shoulderY = (leftShoulder.y + rightShoulder.y) / 2;
      final hipY = (leftHip.y + rightHip.y) / 2;
      final kneeY = (leftKnee.y + rightKnee.y) / 2;
      
      final torsoAngle = atan2((shoulderY - hipY).abs(), 1) * 180 / pi;
      
      // Form analysis
      final shoulderStability = (leftShoulder.x - rightShoulder.x).abs();
      final hipStability = (leftHip.x - rightHip.x).abs();
      _formScore = (1 - (shoulderStability + hipStability) / 2).clamp(0.0, 1.0);
      
      // Update form bar color
      if (_formScore > 0.7) {
        _formBarColor = Colors.green;
      } else if (_formScore > 0.4) {
        _formBarColor = Colors.yellow;
      } else {
        _formBarColor = Colors.red;
      }
      
      // Sit-up counting
      if (torsoAngle > 45 && !_isUp) {
        _isUp = true;
      } else if (torsoAngle < 20 && _isUp) {
        _isUp = false;
        if (mounted) {
          setState(() {
            _sitUpCount++;
          });
        }
      }
      
      _previousPoses = [pose];
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            if (_phase == "height") {
              // Complete height analysis and show result
              _heightAnalysisComplete = true;
              final avgHeight = _heightEstimates.isNotEmpty 
                  ? _heightEstimates.reduce((a, b) => a + b) / _heightEstimates.length 
                  : 0.0;
              _estimatedHeight = avgHeight;
              _phase = "height_result";
              _countdown = 5; // Show result for 5 seconds
              _instruction = "Height: ${avgHeight.toStringAsFixed(1)} cm";
              
              // Perform height assessment
              _performHeightAssessment(avgHeight);
            } else if (_phase == "height_result") {
              _phase = "countdown";
              _countdown = 10;
              _instruction = "Get ready for sit-ups!";
            } else if (_phase == "countdown") {
              _phase = "situp";
              _instruction = "Do 10 sit-ups!";
              timer.cancel();
            }
          }
        });
      }
    });
  }

  Future<void> _startRecording() async {
    if (!_controller.value.isInitialized || _isRecording) return;

    await _controller.startVideoRecording();
    _recordingStartTime = DateTime.now();
    
    setState(() {
      _isRecording = true;
    });

    _updateRecordingTime();
  }

  void _updateRecordingTime() {
    if (_isRecording && _recordingStartTime != null) {
      Future.delayed(const Duration(seconds: 1), () {
        if (_isRecording && mounted) {
          final duration = DateTime.now().difference(_recordingStartTime!);
          final minutes = duration.inMinutes.toString().padLeft(2, '0');
          final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
          setState(() {
            _recordingTime = "$minutes:$seconds";
          });
          _updateRecordingTime();
        }
      });
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    final videoFile = await _controller.stopVideoRecording();
    
    setState(() {
      _isRecording = false;
    });

    Navigator.pop(context, videoFile.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isInitialized
          ? Stack(
              children: [
                // Full screen camera preview
                Positioned.fill(
                  child: CameraPreview(_controller),
                ),
                
                // Skeleton overlay during height measurement
                if (_phase == "height" && _currentPose != null)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: SkeletonPainter(
                        pose: _currentPose!,
                        imageSize: _imageSize,
                        cameraController: _controller,
                      ),
                    ),
                  ),
                
                // Top bar with info
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                _instruction,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (_phase == "height" && _estimatedHeight > 0)
                                Text(
                                  'Current: ${_estimatedHeight.toStringAsFixed(1)} cm',
                                  style: const TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 14,
                                  ),
                                ),
                              if (_phase == "height_result")
                                Column(
                                  children: [
                                    Text(
                                      'Final Height: ${_estimatedHeight.toStringAsFixed(1)} cm',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (_heightAssessment != null) ...<Widget>[
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_heightAssessment!.category} (${_heightAssessment!.percentile.toStringAsFixed(0)}th percentile)',
                                        style: TextStyle(
                                          color: _heightAssessment!.isHealthy ? Colors.green : Colors.orange,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              if (_phase == "height" || _phase == "countdown" || _phase == "height_result")
                                Text(
                                  '$_countdown',
                                  style: TextStyle(
                                    color: _phase == "height_result" ? Colors.green : Colors.red,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_phase == "situp")
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_sitUpCount/10',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
                
                // Form analysis bar
                if (_phase == "situp")
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom + 140,
                    left: 20,
                    right: 20,
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.yellow, Colors.green],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: _formScore,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: _formBarColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Recording time indicator
                if (_isRecording)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 120,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _recordingTime,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Height assessment details
                if (_phase == "height_result" && _heightAssessment != null)
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom + 140,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Assessment: ${_heightAssessment!.category}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Confidence: ${(_heightAssessment!.confidence * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Bottom controls
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _isRecording ? _stopRecording : _startRecording,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRecording ? Colors.red : Colors.white,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.videocam,
                            color: _isRecording ? Colors.white : Colors.red,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
    );
  }

  Future<void> _performHeightAssessment(double height) async {
    try {
      final assessment = await HeightAssessmentService.analyzeHeight(
        estimatedHeight: height,
        heightEstimates: _heightEstimates,
        age: 25, // Default age - should be from user profile
        gender: 'male', // Default gender - should be from user profile
      );
      
      if (mounted) {
        setState(() {
          _heightAssessment = assessment;
        });
      }
    } catch (e) {
      print('Height assessment error: $e');
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller.dispose();
    _poseDetector.close();
    super.dispose();
  }
}

class SkeletonPainter extends CustomPainter {
  final Pose pose;
  final Size imageSize;
  final CameraController cameraController;

  SkeletonPainter({
    required this.pose,
    required this.imageSize,
    required this.cameraController,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final jointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final landmarks = pose.landmarks;
    
    // Scale factors to convert from image coordinates to screen coordinates
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    // Helper function to get scaled point
    Offset? getScaledPoint(PoseLandmarkType type) {
      final landmark = landmarks[type];
      if (landmark != null && landmark.likelihood > 0.5) {
        return Offset(
          landmark.x * scaleX,
          landmark.y * scaleY,
        );
      }
      return null;
    }

    // Draw skeleton connections
    final connections = [
      // Head and torso
      [PoseLandmarkType.nose, PoseLandmarkType.leftEye],
      [PoseLandmarkType.nose, PoseLandmarkType.rightEye],
      [PoseLandmarkType.leftEye, PoseLandmarkType.leftEar],
      [PoseLandmarkType.rightEye, PoseLandmarkType.rightEar],
      
      // Torso
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
      
      // Left arm
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
      [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
      
      // Right arm
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
      [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
      
      // Left leg
      [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
      [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
      
      // Right leg
      [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
      [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
    ];

    // Draw connections
    for (final connection in connections) {
      final point1 = getScaledPoint(connection[0]);
      final point2 = getScaledPoint(connection[1]);
      
      if (point1 != null && point2 != null) {
        canvas.drawLine(point1, point2, paint);
      }
    }

    // Draw joints
    for (final landmark in landmarks.values) {
      if (landmark.likelihood > 0.5) {
        final point = Offset(
          landmark.x * scaleX,
          landmark.y * scaleY,
        );
        canvas.drawCircle(point, 6, jointPaint);
      }
    }

    // Draw height measurement lines
    final nose = getScaledPoint(PoseLandmarkType.nose);
    final leftAnkle = getScaledPoint(PoseLandmarkType.leftAnkle);
    final rightAnkle = getScaledPoint(PoseLandmarkType.rightAnkle);
    
    if (nose != null && leftAnkle != null && rightAnkle != null) {
      final avgAnkle = Offset(
        (leftAnkle.dx + rightAnkle.dx) / 2,
        (leftAnkle.dy + rightAnkle.dy) / 2,
      );
      
      // Draw height measurement line
      final heightPaint = Paint()
        ..color = Colors.cyan
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(nose, avgAnkle, heightPaint);
      
      // Draw measurement markers
      canvas.drawCircle(nose, 8, Paint()..color = Colors.cyan);
      canvas.drawCircle(avgAnkle, 8, Paint()..color = Colors.cyan);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Widget to display detailed height assessment results
class HeightAssessmentDialog extends StatelessWidget {
  final HeightAssessmentResult assessment;
  
  const HeightAssessmentDialog({super.key, required this.assessment});
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Height Assessment Results'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Height: ${assessment.estimatedHeight.toStringAsFixed(1)} cm',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Category: ${assessment.category}',
              style: TextStyle(
                fontSize: 16,
                color: assessment.isHealthy ? Colors.green : Colors.orange,
              ),
            ),
            Text(
              'Percentile: ${assessment.percentile.toStringAsFixed(0)}th',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Confidence: ${(assessment.confidence * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Recommendations:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...assessment.recommendations.map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $rec', style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}