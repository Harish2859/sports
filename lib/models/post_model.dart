class Post {
  final String id;
  final String username;
  final String userProfilePic;
  final String timestamp;
  final String? textContent;
  final String? imageUrl;
  final String? videoUrl;
  final bool isPerformanceVideo;
  int likes;
  int commentsCount;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.username,
    required this.userProfilePic,
    required this.timestamp,
    this.textContent,
    this.imageUrl,
    this.videoUrl,
    this.isPerformanceVideo = false,
    this.likes = 0,
    this.commentsCount = 0,
    required this.comments,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      userProfilePic: json['userProfilePic'] ?? '',
      timestamp: json['timestamp'] ?? '',
      textContent: json['textContent'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      isPerformanceVideo: json['isPerformanceVideo'] ?? false,
      likes: json['likes'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      comments: (json['comments'] as List<dynamic>?)
          ?.map((comment) => Comment.fromJson(comment))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'userProfilePic': userProfilePic,
      'timestamp': timestamp,
      'textContent': textContent,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'isPerformanceVideo': isPerformanceVideo,
      'likes': likes,
      'commentsCount': commentsCount,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }
}

class Comment {
  final String id;
  final String username;
  final String userProfilePic;
  final String content;
  final String timestamp;

  Comment({
    required this.id,
    required this.username,
    required this.userProfilePic,
    required this.content,
    required this.timestamp,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      userProfilePic: json['userProfilePic'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'userProfilePic': userProfilePic,
      'content': content,
      'timestamp': timestamp,
    };
  }
}