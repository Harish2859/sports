import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/post_card.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../theme_provider.dart';
import '../main_layout.dart';
import '../constants/app_constants.dart';
import '../explore.dart';
import '../widgets/event_page_wrapper.dart';
import '../course.dart';
import '../profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final PostService _postService = PostService();
  final TextEditingController _commentController = TextEditingController();
  bool _showCommentOverlay = false;
  Post? _selectedPost;
  late AnimationController _overlayAnimationController;
  late Animation<Offset> _slideAnimation;

  final List<Widget> _screens = [
    const HomeContent(),
    ExplorePage(),
    const EventPage(),
    const CoursePage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _postService.initializePosts();
    
    _overlayAnimationController = AnimationController(
      duration: const Duration(milliseconds: AppConstants.defaultAnimationDuration),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0.2),
    ).animate(CurvedAnimation(
      parent: _overlayAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _overlayAnimationController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showComments(Post post) {
    setState(() {
      _selectedPost = post;
      _showCommentOverlay = true;
    });
    _overlayAnimationController.forward();
  }

  void _hideComments() {
    _overlayAnimationController.reverse().then((_) {
      setState(() {
        _showCommentOverlay = false;
        _selectedPost = null;
      });
    });
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty || _selectedPost == null) return;

    final comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: 'current_user',
      userProfilePic: '',
      content: _commentController.text.trim(),
      timestamp: 'now',
    );

    _postService.addComment(_selectedPost!.id, comment);
    _commentController.clear();
    setState(() {});
  }

  void _likePost(Post post) {
    _postService.likePost(post.id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // If profile page is selected, show it without MainLayout
    if (_currentIndex == 4) {
      return Scaffold(
        body: Stack(
          children: [
            _screens[_currentIndex],
            if (_showCommentOverlay) _buildCommentOverlay(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex.clamp(0, 4),
          onTap: _onTabChanged,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school),
              label: 'Modules',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      );
    }
    
    return MainLayout(
      currentIndex: _currentIndex,
      onTabChanged: _onTabChanged,
      child: Stack(
        children: [
          _currentIndex == 0 ? _buildHomeContent() : _screens[_currentIndex],
          if (_showCommentOverlay) _buildCommentOverlay(),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    final isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: _postService.posts.length,
          itemBuilder: (context, index) {
            final post = _postService.posts[index];
            return PostCard(
              post: post,
              isDarkMode: isDarkMode,
              onLike: () => _likePost(post),
              onComment: () => _showComments(post),
              onShare: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share functionality')),
                );
              },
              onBookmark: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bookmark functionality')),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCommentOverlay() {
    final isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    
    return GestureDetector(
      onTap: _hideComments,
      child: Container(
        color: Colors.black54,
        child: SlideTransition(
          position: _slideAnimation,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  _buildCommentOverlayHeader(isDarkMode),
                  if (_selectedPost != null) _buildPostPreview(_selectedPost!, isDarkMode),
                  Expanded(child: _buildCommentsList(isDarkMode)),
                  _buildCommentInput(isDarkMode),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentOverlayHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Comments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _hideComments,
          ),
        ],
      ),
    );
  }

  Widget _buildPostPreview(Post post, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (post.textContent != null)
                  Text(
                    post.textContent!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(bool isDarkMode) {
    if (_selectedPost == null || _selectedPost!.comments.isEmpty) {
      return Center(
        child: Text(
          'No comments yet',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _selectedPost!.comments.length,
      itemBuilder: (context, index) {
        final comment = _selectedPost!.comments[index];
        return _buildCommentItem(comment, isDarkMode);
      },
    );
  }

  Widget _buildCommentItem(Comment comment, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: comment.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' ${comment.content}'),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.timestamp,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: 3,
              minLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.send,
              color: Colors.blue[600],
            ),
            onPressed: _addComment,
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home Content'),
    );
  }
}