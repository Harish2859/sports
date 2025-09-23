import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'performance_videos_manager.dart';
import 'simple_video_recorder.dart';
import 'theme_provider.dart';
import 'main_layout.dart';

class PerformanceVideosPage extends StatefulWidget {
  const PerformanceVideosPage({super.key});

  @override
  State<PerformanceVideosPage> createState() => _PerformanceVideosPageState();
}

class _PerformanceVideosPageState extends State<PerformanceVideosPage> {
  final PerformanceVideosManager _videosManager = PerformanceVideosManager();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : null,
      appBar: AppBar(
        title: const Text('Your Performance'),
        backgroundColor: isDarkMode ? Colors.grey[800] : null,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: _videosManager.hasVideos()
          ? _buildVideosList()
          : _buildEmptyState(),
    );
  }

  Widget _buildVideosList() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _videosManager.videos.length,
      itemBuilder: (context, index) {
        final video = _videosManager.videos[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.play_circle_filled, 
                color: Colors.red, 
                size: 32
              ),
            ),
            title: Text(
              video.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            subtitle: Text(
              'Recorded: ${_formatDate(video.recordedAt)}',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            trailing: PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: isDarkMode ? Colors.white : Theme.of(context).iconTheme.color,
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteVideo(video);
                }
              },
            ),
            onTap: () => _playVideo(video),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off,
            size: 64,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No performance videos yet',
            style: TextStyle(
              fontSize: 18,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the camera button to record your first video',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),

        ],
      ),
    );
  }

  Future<void> _recordNewVideo() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const SimpleVideoRecorder()),
    );

    if (result != null) {
      _videosManager.addVideo(result);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video saved successfully!')),
      );
    }
  }

  void _playVideo(PerformanceVideo video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoPath: video.filePath, title: video.title),
      ),
    );
  }

  void _deleteVideo(PerformanceVideo video) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[800] : null,
        title: Text(
          'Delete Video',
          style: TextStyle(
            color: isDarkMode ? Colors.white : null,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this video?',
          style: TextStyle(
            color: isDarkMode ? Colors.white : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.white : null,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _videosManager.removeVideo(video.id);
              setState(() {});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Video deleted'),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.videoPath,
    required this.title,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.file(File(widget.videoPath));
    await _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _controller == null || !_controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_controller!),
                      if (!_isPlaying)
                        IconButton(
                          onPressed: () {
                            _controller!.play();
                            setState(() => _isPlaying = true);
                            _controller!.addListener(() {
                              if (_controller!.value.position >= _controller!.value.duration) {
                                setState(() => _isPlaying = false);
                              }
                            });
                          },
                          icon: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 64,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_isPlaying) {
                            _controller!.pause();
                            setState(() => _isPlaying = false);
                          } else {
                            _controller!.play();
                            setState(() => _isPlaying = true);
                          }
                        },
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _controller!.seekTo(Duration.zero);
                          setState(() => _isPlaying = false);
                        },
                        icon: const Icon(
                          Icons.replay,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}