import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class SimpleVideoRecorder extends StatefulWidget {
  const SimpleVideoRecorder({super.key});

  @override
  State<SimpleVideoRecorder> createState() => _SimpleVideoRecorderState();
}

class _SimpleVideoRecorderState extends State<SimpleVideoRecorder> {
  final ImagePicker _picker = ImagePicker();
  String? _videoPath;
  VideoPlayerController? _videoController;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        setState(() {
          _videoPath = video.path;
        });
        _initializeVideoPlayer();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording video: $e')),
      );
    }
  }

  Future<void> _initializeVideoPlayer() async {
    if (_videoPath != null) {
      _videoController = VideoPlayerController.file(File(_videoPath!));
      await _videoController!.initialize();
      setState(() {});
    }
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
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _videoPath != null
                ? _buildVideoPreview()
                : _buildRecordingPrompt(),
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildRecordingPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam, size: 80, color: Colors.white54),
          const SizedBox(height: 20),
          const Text(
            'Tap the record button to start',
            style: TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        VideoPlayer(_videoController!),
        if (!_videoController!.value.isPlaying)
          IconButton(
            onPressed: () {
              _videoController!.play();
              setState(() {});
            },
            icon: const Icon(Icons.play_arrow, color: Colors.white, size: 64),
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
                  _videoController?.dispose();
                  _videoController = null;
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
          ] else
            GestureDetector(
              onTap: _recordVideo,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Icon(Icons.videocam, color: Colors.white, size: 32),
              ),
            ),
        ],
      ),
    );
  }
}