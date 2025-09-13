import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../screens/full_screen_recorder.dart';

class VideoRecorder extends StatefulWidget {
  final String title;
  final String description;
  final CameraDescription camera;
  final Function(String videoPath)? onVideoSaved;

  const VideoRecorder({
    super.key,
    required this.title,
    required this.description,
    required this.camera,
    this.onVideoSaved,
  });

  @override
  State<VideoRecorder> createState() => _VideoRecorderState();
}

class _VideoRecorderState extends State<VideoRecorder> {
  late CameraController _controller;
  bool _isInitialized = false;
  bool _isRecording = false;
  String? _videoPath;
  String _recordingTime = "00:00";
  DateTime? _recordingStartTime;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _controller = CameraController(
        widget.camera,
        ResolutionPreset.high,
        enableAudio: true,
      );
      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _startRecording() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenRecorder(
          camera: widget.camera,
          title: widget.title,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _videoPath = result;
      });

      if (widget.onVideoSaved != null) {
        widget.onVideoSaved!(result);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Video saved: ${path.basename(result)}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            
            // Camera preview
            if (_isInitialized)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CameraPreview(_controller),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Recording controls
            Center(
              child: ElevatedButton.icon(
                onPressed: _isInitialized ? _startRecording : null,
                icon: const Icon(Icons.videocam),
                label: const Text('Record Video'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Recording status
            if (_videoPath != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text(
                    'Video saved successfully',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}