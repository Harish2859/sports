import 'dart:io';

class PerformanceVideo {
  final String id;
  final String filePath;
  final DateTime recordedAt;
  final String title;

  PerformanceVideo({
    required this.id,
    required this.filePath,
    required this.recordedAt,
    required this.title,
  });
}

class PerformanceVideosManager {
  static final PerformanceVideosManager _instance = PerformanceVideosManager._internal();
  factory PerformanceVideosManager() => _instance;
  PerformanceVideosManager._internal();

  final List<PerformanceVideo> _videos = [];

  List<PerformanceVideo> get videos => List.unmodifiable(_videos);

  void addVideo(String filePath) {
    final video = PerformanceVideo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      filePath: filePath,
      recordedAt: DateTime.now(),
      title: 'Performance ${_videos.length + 1}',
    );
    _videos.add(video);
  }

  void removeVideo(String id) {
    _videos.removeWhere((video) => video.id == id);
  }

  bool hasVideos() => _videos.isNotEmpty;
}