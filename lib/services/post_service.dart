import '../models/post_model.dart';

class PostService {
  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;
  PostService._internal();

  List<Post> _posts = [];

  List<Post> get posts => _posts;

  void initializePosts() {
    _posts = [
      Post(
        id: '1',
        username: 'athlete_mike',
        userProfilePic: '',
        timestamp: '2 hours ago',
        textContent: 'Just finished an amazing training session! 💪 Ready for the upcoming championship.',
        imageUrl: 'assets/images/post 1.jpg',
        likes: 124,
        commentsCount: 23,
        comments: [
          Comment(
            id: '1',
            username: 'coach_sarah',
            userProfilePic: '',
            content: 'Great form! Keep it up!',
            timestamp: '1 hour ago',
          ),
          Comment(
            id: '2',
            username: 'teammate_alex',
            userProfilePic: '',
            content: 'Inspiring as always! 🔥',
            timestamp: '45 mins ago',
          ),
        ],
      ),
      Post(
        id: '2',
        username: 'runner_jenny',
        userProfilePic: '',
        timestamp: '4 hours ago',
        textContent: 'New personal best today! The hard work is paying off.',
        imageUrl: 'assets/images/post 2.jpg',
        likes: 87,
        commentsCount: 15,
        comments: [
          Comment(
            id: '3',
            username: 'fitness_coach',
            userProfilePic: '',
            content: 'Congratulations! Your dedication shows.',
            timestamp: '3 hours ago',
          ),
        ],
      ),
      Post(
        id: '3',
        username: 'swimmer_tom',
        userProfilePic: '',
        timestamp: '6 hours ago',
        textContent: 'Pool training session complete. Working on my technique for the next competition.',
        imageUrl: 'assets/images/post 3.jpg',
        likes: 156,
        commentsCount: 31,
        comments: [
          Comment(
            id: '4',
            username: 'swim_coach',
            userProfilePic: '',
            content: 'Your stroke technique has improved significantly!',
            timestamp: '5 hours ago',
          ),
          Comment(
            id: '5',
            username: 'athlete_mike',
            userProfilePic: '',
            content: 'Great session! See you at practice tomorrow.',
            timestamp: '4 hours ago',
          ),
        ],
      ),
      Post(
        id: '4',
        username: 'basketball_pro',
        userProfilePic: '',
        timestamp: '8 hours ago',
        videoUrl: 'assets/videos/video.mp4',
        isPerformanceVideo: true,
        textContent: 'Performance Analysis: Working on my shooting form. Check out this slow-motion breakdown.',
        likes: 243,
        commentsCount: 45,
        comments: [
          Comment(
            id: '6',
            username: 'coach_kevin',
            userProfilePic: '',
            content: 'Perfect arc on that shot! 🏀',
            timestamp: '7 hours ago',
          ),
        ],
      ),
      Post(
        id: '5',
        username: 'tennis_ace',
        userProfilePic: '',
        timestamp: '12 hours ago',
        videoUrl: 'assets/videos/video.mp4',
        isPerformanceVideo: true,
        textContent: 'Performance Video: Analyzing my serve technique. Feedback welcome! 🎾',
        likes: 198,
        commentsCount: 38,
        comments: [
          Comment(
            id: '7',
            username: 'tennis_coach',
            userProfilePic: '',
            content: 'Great power and accuracy! Work on the follow-through.',
            timestamp: '11 hours ago',
          ),
        ],
      ),
    ];
  }

  void likePost(String postId) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      _posts[postIndex].likes++;
    }
  }

  void addComment(String postId, Comment comment) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      _posts[postIndex].comments.add(comment);
      _posts[postIndex].commentsCount++;
    }
  }

  Post? getPostById(String postId) {
    try {
      return _posts.firstWhere((post) => post.id == postId);
    } catch (e) {
      return null;
    }
  }
}