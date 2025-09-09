import 'dart:io';

class Post {
  final String id;
  final String imagePath;
  final String description;
  final DateTime createdAt;
  int likes;
  final List<String> comments;

  Post({
    required this.id,
    required this.imagePath,
    required this.description,
    required this.createdAt,
    this.likes = 0,
    List<String>? comments,
  }) : comments = comments ?? [];
}

class PostManager {
  static final PostManager _instance = PostManager._internal();
  factory PostManager() => _instance;
  PostManager._internal();

  final List<Post> _posts = [];

  List<Post> get posts => List.unmodifiable(_posts);

  void addPost(String imagePath, String description) {
    final post = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      description: description,
      createdAt: DateTime.now(),
    );
    _posts.add(post);
  }

  void removePost(String id) {
    _posts.removeWhere((post) => post.id == id);
  }

  void likePost(String id) {
    final post = _posts.firstWhere((p) => p.id == id);
    post.likes++;
  }

  void addComment(String id, String comment) {
    final post = _posts.firstWhere((p) => p.id == id);
    post.comments.add(comment);
  }

  bool hasPosts() => _posts.isNotEmpty;
}
