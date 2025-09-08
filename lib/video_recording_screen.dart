import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoRecordingScreen extends StatefulWidget {
  const VideoRecordingScreen({super.key});

  @override
  State<VideoRecordingScreen> createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;
  String? _videoPath;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (status != PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera permission denied')),
          );
        }
        return;
      }

      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
        if (mounted) setState(() {});
      }
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController == null || !_cameraController!.value.isRecordingVideo) {
      return;
    }

    try {
      final XFile videoFile = await _cameraController!.stopVideoRecording();
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String videoPath = path.join(appDir.path, 'performance_${DateTime.now().millisecondsSinceEpoch}.mp4');
      
      await File(videoFile.path).copy(videoPath);
      
      setState(() {
        _isRecording = false;
        _videoPath = videoPath;
      });

      _initializeVideoPlayer();
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _initializeVideoPlayer() async {
    if (_videoPath != null) {
      _videoPlayerController = VideoPlayerController.file(File(_videoPath!));
      await _videoPlayerController!.initialize();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Record Performance', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, _videoPath),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _videoPath != null
                ? _buildVideoPreview()
                : _buildCameraPreview(),
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return CameraPreview(_cameraController!);
  }

  Widget _buildVideoPreview() {
    if (_videoPlayerController == null || !_videoPlayerController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        VideoPlayer(_videoPlayerController!),
        if (!_videoPlayerController!.value.isPlaying)
          IconButton(
            onPressed: () {
              _videoPlayerController!.play();
              setState(() {});
            },
            icon: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 64,
            ),
          ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (_videoPath != null) ...[
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _videoPath = null;
                  _videoPlayerController?.dispose();
                  _videoPlayerController = null;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Record Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, _videoPath),
              icon: const Icon(Icons.check),
              label: const Text('Save Video'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ] else ...[
            GestureDetector(
              onTap: _isRecording ? _stopRecording : _startRecording,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.red : Colors.white,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.videocam,
                  color: _isRecording ? Colors.white : Colors.red,
                  size: 32,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}