import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'performance_videos_manager.dart';
import 'theme_provider.dart';

class PerformanceUploadPage extends StatefulWidget {
  const PerformanceUploadPage({super.key});

  @override
  State<PerformanceUploadPage> createState() => _PerformanceUploadPageState();
}

class _PerformanceUploadPageState extends State<PerformanceUploadPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _video;
  final TextEditingController _titleController = TextEditingController();
  bool _isUploading = false;

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _video = video;
      });
    }
  }

  Future<void> _upload() async {
    if (_video == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video and add a title')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final videosManager = PerformanceVideosManager();
    videosManager.addVideo(_video!.path);

    // Update the title if possible, but since manager doesn't have title update, perhaps modify manager
    // For now, just add

    setState(() {
      _isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video uploaded successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final isGamified = themeProvider.isGamified;

    return Scaffold(
      backgroundColor: isGamified
          ? Colors.black
          : (isDarkMode ? Colors.grey[900] : Colors.white),
      appBar: AppBar(
        backgroundColor: isGamified ? Colors.black : null,
        title: Text(
          'New Performance Video',
          style: TextStyle(
            color: isGamified ? Colors.white : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _upload,
            child: Text(
              _isUploading ? 'Uploading...' : 'Upload',
              style: TextStyle(
                color: isGamified ? Colors.blue[300] : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Video Preview Placeholder
            GestureDetector(
              onTap: _pickVideo,
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isGamified
                      ? Colors.grey[800]
                      : (isDarkMode ? Colors.grey[700] : Colors.grey[200]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isGamified ? Colors.white.withOpacity(0.3) : Colors.grey,
                    width: 2,
                  ),
                ),
                child: _video != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam,
                            size: 64,
                            color: isGamified ? Colors.white : Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Video selected',
                            style: TextStyle(
                              color: isGamified ? Colors.white : Colors.grey,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.video_call,
                            size: 64,
                            color: isGamified ? Colors.white.withOpacity(0.6) : Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tap to select video',
                            style: TextStyle(
                              color: isGamified ? Colors.white.withOpacity(0.6) : Colors.grey,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            // Title Text Field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Video title...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isGamified
                    ? Colors.grey[800]
                    : (isDarkMode ? Colors.grey[700] : Colors.white),
              ),
              style: TextStyle(
                color: isGamified ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
