import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'post_manager.dart';
import 'performance_videos_manager.dart';

// Enum to define the type of upload
enum UploadType { post, performance }

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final PostManager _postManager = PostManager();
  final PerformanceVideosManager _videosManager = PerformanceVideosManager();
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _mediaFile;
  UploadType _selectedType = UploadType.post; // Default to 'Post'

  Future<void> _pickMedia() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
      });
    }
  }

  void _shareContent() {
    if (_mediaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image or video first.')),
      );
      return;
    }

    if (_selectedType == UploadType.post) {
      _postManager.addPost(_mediaFile!.path, _captionController.text);
    } else {
      _videosManager.addVideo(_mediaFile!.path);
    }
    
    // Show a confirmation and go back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_selectedType.name.capitalize()} shared successfully!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Create new content', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _shareContent,
            child: const Text(
              'Share',
              style: TextStyle(
                color: Colors.deepPurpleAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickMedia,
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _mediaFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_mediaFile!, fit: BoxFit.cover),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_library, color: Colors.grey[600], size: 50),
                            const SizedBox(height: 8),
                            Text('Tap to select media', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            
            TextField(
              controller: _captionController,
              maxLines: 4,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Write a caption...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
              ),
            ),
            const Divider(color: Colors.grey),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SegmentedButton<UploadType>(
                segments: const [
                  ButtonSegment(value: UploadType.post, label: Text('Post'), icon: Icon(Icons.grid_on)),
                  ButtonSegment(value: UploadType.performance, label: Text('Performance'), icon: Icon(Icons.play_circle_outline)),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<UploadType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
                style: SegmentedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  selectedForegroundColor: Colors.white,
                  selectedBackgroundColor: Colors.deepPurpleAccent,
                ),
              ),
            ),
            const Divider(color: Colors.grey),
            
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.black),
              title: const Text('Tag People', style: TextStyle(color: Colors.black)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.location_on_outlined, color: Colors.black),
              title: const Text('Add Location', style: TextStyle(color: Colors.black)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

// Simple extension to capitalize the first letter of a string
extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    }
}