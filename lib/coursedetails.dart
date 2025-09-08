import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'course.dart';
import 'app_state.dart';
import 'main_layout.dart';
import 'gotocourse.dart';
import 'course_data_manager.dart';
import 'theme_provider.dart';

// Comment Model
class Comment {
  final String id;
  final String username;
  final String text;
  final DateTime timestamp;
  final int likes;
  final bool isLiked;

  Comment({
    required this.id,
    required this.username,
    required this.text,
    required this.timestamp,
    required this.likes,
    this.isLiked = false,
  });

  Comment copyWith({
    String? id,
    String? username,
    String? text,
    DateTime? timestamp,
    int? likes,
    bool? isLiked,
  }) {
    return Comment(
      id: id ?? this.id,
      username: username ?? this.username,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

class CourseDetailsPage extends StatefulWidget {
  final Course course;

  const CourseDetailsPage({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AppState _appState = AppState();
  
  late Course _course;
  int _enrolledCount = 0;
  
  List<Comment> _comments = [
    Comment(
      id: '1',
      username: 'Alex Johnson',
      text: 'Excellent course! The instructor explains complex concepts very clearly.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 12,
    ),
    Comment(
      id: '2',
      username: 'Maria Garcia',
      text: 'Great practical examples and hands-on projects. Highly recommend!',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      likes: 8,
    ),
    Comment(
      id: '3',
      username: 'John Smith',
      text: 'The course content is up-to-date and relevant to industry standards.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      likes: 15,
    ),
  ];

  final CourseDataManager _courseManager = CourseDataManager();
  List<String> get _sessionTitles => _courseManager.getSessionTitles(_course.id);

  @override
  void initState() {
    super.initState();
    _course = widget.course;
    _enrolledCount = _course.enrolledCount;
  }

  void _enrollInCourse() {
    final userName = _appState.userName;
    final userGender = _appState.userGender;

    _appState.enrollInCourseWithGender(_course, userName, userGender);
    setState(() {
      _enrolledCount += 1;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Successfully enrolled in course!'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _toggleFavorite() {
    setState(() {
      if (_appState.isFavorite(_course.id)) {
        _appState.removeFromFavorites(_course);
      } else {
        _appState.addToFavorites(_course);
      }
    });
  }

  void _addComment() {
    if (_commentController.text.trim().isNotEmpty) {
      final newComment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: 'You', // In a real app, this would be the current user's name
        text: _commentController.text.trim(),
        timestamp: DateTime.now(),
        likes: 0,
      );
      
      setState(() {
        _comments.insert(0, newComment);
        _commentController.clear();
      });
    }
  }

  void _toggleLike(Comment comment) {
    setState(() {
      final index = _comments.indexWhere((c) => c.id == comment.id);
      if (index != -1) {
        _comments[index] = comment.copyWith(
          isLiked: !comment.isLiked,
          likes: comment.isLiked ? comment.likes - 1 : comment.likes + 1,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      decoration: themeProvider.isGamified
          ? const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1a237e), Color(0xFF000000)],
              ),
            )
          : null,
      child: MainLayout(
        currentIndex: 3, // Course tab
        onTabChanged: (index) {
          if (index != 3) {
            Navigator.pop(context);
          }
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Custom App Bar
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: themeProvider.isGamified
                  ? Colors.transparent
                  : themeProvider.themeMode == ThemeMode.dark
                      ? Colors.grey[800]
                      : const Color(0xFF2563EB),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              ),
              IconButton(
                icon: Icon(
                  _appState.isFavorite(_course.id) ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _getCourseBannerImage(_course.title),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Course Content
          SliverToBoxAdapter(
            child: Container(
              decoration: themeProvider.isGamified
                  ? const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1a237e), Color(0xFF000000)],
                      ),
                    )
                  : BoxDecoration(
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? Colors.grey[900]
                          : Colors.white,
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                        // Course Header
                        Padding(
                          padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Title
                      Text(
                        _course.title,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isGamified
                              ? Colors.white
                              : themeProvider.themeMode == ThemeMode.dark
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                          height: 1.2,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Instructor and Meta Info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                            child: Text(
                              _course.instructor[0].toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _course.instructor,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: themeProvider.isGamified
                                        ? Colors.white
                                        : themeProvider.themeMode == ThemeMode.dark
                                            ? Colors.white
                                            : const Color(0xFF1F2937),
                                  ),
                                ),
                                Text(
                                  '${_course.duration} • ${_course.difficulty}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: themeProvider.isGamified
                                        ? Colors.white70
                                        : themeProvider.themeMode == ThemeMode.dark
                                            ? Colors.grey[400]
                                            : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Rating and Enrolled Count
                      Row(
                        children: [
                          Row(
                            children: [
                              ...List.generate(5, (index) {
                                return Icon(
                                  index < _course.rating.floor()
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 20,
                                  color: const Color(0xFFFBBF24),
                                );
                              }),
                              const SizedBox(width: 8),
                              Text(
                                _course.rating.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: themeProvider.isGamified
                                      ? Colors.white
                                      : themeProvider.themeMode == ThemeMode.dark
                                          ? Colors.white
                                          : const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          Row(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 20,
                                color: themeProvider.themeMode == ThemeMode.dark
                                    ? Colors.grey[400]
                                    : const Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$_enrolledCount enrolled',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: themeProvider.isGamified
                                      ? Colors.white70
                                      : themeProvider.themeMode == ThemeMode.dark
                                          ? Colors.grey[400]
                                          : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                        ),
                        
                        // Course Description
                        Padding(
                          padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About this course',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isGamified
                              ? Colors.white
                              : themeProvider.themeMode == ThemeMode.dark
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _course.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: themeProvider.isGamified
                              ? Colors.white70
                              : themeProvider.themeMode == ThemeMode.dark
                                  ? Colors.grey[400]
                                  : const Color(0xFF4B5563),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                
                        // Prerequisites
                        if (_course.prerequisites.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prerequisites',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isGamified
                                ? Colors.white
                                : themeProvider.themeMode == ThemeMode.dark
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...(_course.prerequisites.map((prereq) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  prereq,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: themeProvider.isGamified
                                        ? Colors.white70
                                        : themeProvider.themeMode == ThemeMode.dark
                                            ? Colors.grey[400]
                                            : const Color(0xFF4B5563),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))),
                      ],
                    ),
                          ),
                        
                        // Course Sessions
                        Padding(
                          padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Course Sessions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isGamified
                              ? Colors.white
                              : themeProvider.themeMode == ThemeMode.dark
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _sessionTitles.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Container(
                                width: 140,
                                decoration: BoxDecoration(
                                  gradient: themeProvider.isGamified
                                      ? const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [Color(0xFF3949ab), Color(0xFF1a237e)],
                                        )
                                      : null,
                                  color: themeProvider.isGamified
                                      ? null
                                      : themeProvider.themeMode == ThemeMode.dark
                                          ? Colors.grey[800]
                                          : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: themeProvider.isGamified
                                          ? Colors.white.withOpacity(0.3)
                                          : themeProvider.themeMode == ThemeMode.dark
                                              ? Colors.grey[700]!
                                              : const Color(0xFFE5E7EB)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 70,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: themeProvider.themeMode == ThemeMode.dark
                                            ? Colors.grey[700]
                                            : const Color(0xFFE5E7EB),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: themeProvider.themeMode == ThemeMode.dark
                                                ? Colors.grey[500]
                                                : const Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(
                                          _sessionTitles[index],
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: themeProvider.isGamified
                                                ? Colors.white
                                                : themeProvider.themeMode == ThemeMode.dark
                                                    ? Colors.white
                                                    : const Color(0xFF1F2937),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                        // Enroll/Join Button
                        Padding(
                          padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _appState.isEnrolled(_course.id) 
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GotoCoursePage(
                                    courseName: _course.title,
                                    courseId: _course.id,
                                  ),
                                ),
                              );
                            }
                          : _enrollInCourse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _appState.isEnrolled(_course.id) 
                            ? const Color(0xFF10B981) 
                            : const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _appState.isEnrolled(_course.id) ? Icons.play_arrow : Icons.school,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _appState.isEnrolled(_course.id) ? 'Join Now' : 'Enroll for the course',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                        // Comments Section
                        Padding(
                          padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Reviews & Comments',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isGamified
                                  ? Colors.white
                                  : themeProvider.themeMode == ThemeMode.dark
                                      ? Colors.white
                                      : const Color(0xFF1F2937),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_comments.length} reviews',
                            style: TextStyle(
                              fontSize: 14,
                              color: themeProvider.isGamified
                                  ? Colors.white70
                                  : themeProvider.themeMode == ThemeMode.dark
                                      ? Colors.grey[400]
                                      : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Add Comment Input
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFF2563EB),
                            child: Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                hintText: 'Add a comment...',
                                filled: true,
                                fillColor: themeProvider.isGamified
                                    ? Colors.white.withOpacity(0.15)
                                    : themeProvider.themeMode == ThemeMode.dark
                                        ? Colors.grey[800]
                                        : const Color(0xFFF9FAFB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: _addComment,
                                  icon: const Icon(
                                    Icons.send,
                                    color: Color(0xFF2563EB),
                                    size: 20,
                                  ),
                                ),
                              ),
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Comments List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _comments.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 32,
                          color: themeProvider.themeMode == ThemeMode.dark
                              ? Colors.grey[800]
                              : const Color(0xFFF3F4F6),
                        ),
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return _buildCommentCard(comment);
                        },
                      ),
                    ],
                  ),
                ),
                
                        // FAQ Section
                        Padding(
                          padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frequently Asked Questions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isGamified
                              ? Colors.white
                              : themeProvider.themeMode == ThemeMode.dark
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._courseManager.getFAQItems(_course.id).map((faq) => _buildFAQItem(faq.question, faq.answer)),
                    ],
                  ),
                ),
                
                        // Course Metadata
                        Padding(
                          padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Course Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isGamified
                              ? Colors.white
                              : themeProvider.themeMode == ThemeMode.dark
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Category', _course.category),
                      _buildInfoRow('Duration', _course.duration),
                      _buildInfoRow('Difficulty Level', _course.difficulty),
                      ..._courseManager.getCourseMetadata(_course.id).entries.map((entry) => _buildInfoRow(entry.key, entry.value)),
                    ],
                  ),
                ),

                        // User Gender Leaderboard
                        Padding(
                          padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Course Leaderboard',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isGamified
                              ? Colors.white
                              : themeProvider.themeMode == ThemeMode.dark
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildUserGenderLeaderboard(),
                    ],
                  ),
                ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard(Comment comment) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
          child: Text(
            comment.username[0].toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.username,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.isGamified
                          ? Colors.white
                          : themeProvider.themeMode == ThemeMode.dark
                              ? Colors.white
                              : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTimestamp(comment.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.isGamified
                          ? Colors.white70
                          : themeProvider.themeMode == ThemeMode.dark
                              ? Colors.grey[400]
                              : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment.text,
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.isGamified
                      ? Colors.white70
                      : themeProvider.themeMode == ThemeMode.dark
                          ? Colors.grey[400]
                          : const Color(0xFF4B5563),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggleLike(comment),
                    child: Row(
                      children: [
                        Icon(
                          comment.isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: comment.isLiked 
                              ? const Color(0xFFEF4444) 
                              : themeProvider.themeMode == ThemeMode.dark
                                  ? Colors.grey[400]
                                  : const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          comment.likes.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: comment.isLiked 
                                ? const Color(0xFFEF4444) 
                                : themeProvider.themeMode == ThemeMode.dark
                                    ? Colors.grey[400]
                                    : const Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      // Reply functionality could be added here
                    },
                    child: Text(
                      'Reply',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.themeMode == ThemeMode.dark
                            ? Colors.grey[400]
                            : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: themeProvider.isGamified
              ? Colors.white
              : themeProvider.themeMode == ThemeMode.dark
                  ? Colors.white
                  : const Color(0xFF1F2937),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.isGamified
                  ? Colors.white70
                  : themeProvider.themeMode == ThemeMode.dark
                      ? Colors.grey[400]
                      : const Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ),
      ],
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.isGamified
                    ? Colors.white70
                    : themeProvider.themeMode == ThemeMode.dark
                        ? Colors.grey[400]
                        : const Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: themeProvider.isGamified
                    ? Colors.white
                    : themeProvider.themeMode == ThemeMode.dark
                        ? Colors.white
                        : const Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCourseBannerImage(String courseTitle) {
    if (courseTitle.toLowerCase().contains('javelin')) {
      return Image.asset(
        'assets/images/javeline.jpg',
        fit: BoxFit.cover,
      );
    } else if (courseTitle.toLowerCase().contains('hurdle')) {
      return Image.asset(
        'assets/images/hurdle.jpg',
        fit: BoxFit.cover,
      );
    } else {
      final themeProvider = Provider.of<ThemeProvider>(context);
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeProvider.themeMode == ThemeMode.dark
                ? [Colors.grey[800]!, Colors.grey[700]!]
                : [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.play_circle_outline,
            size: 64,
            color: Colors.white38,
          ),
        ),
      );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildUserGenderLeaderboard() {
    final userGender = _appState.userGender;
    final genderData = {
      'Male': {'icon': Icons.male, 'color': const Color(0xFF2563EB)},
      'Female': {'icon': Icons.female, 'color': const Color(0xFFDC2626)},
      'Other': {'icon': Icons.transgender, 'color': const Color(0xFF7C3AED)},
    };

    final data = genderData[userGender] ?? genderData['Other']!;
    final icon = data['icon'] as IconData;
    final color = data['color'] as Color;

    return _buildGenderLeaderboard(userGender, icon, color);
  }

  Widget _buildGenderLeaderboard(String gender, IconData icon, Color color) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // Use real data from AppState instead of dummy data
    final enrolledUsers = _appState.getEnrolledUsersByGender(_course.id, gender);
    final enrolledCount = enrolledUsers.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                '$gender Leaderboard',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                '$enrolledCount enrolled',
                style: TextStyle(
                  fontSize: 12,
                  color: color.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (enrolledUsers.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No $gender users enrolled yet',
                  style: TextStyle(
                    fontSize: 14,
                    color: color.withOpacity(0.6),
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: enrolledUsers.length,
                itemBuilder: (context, index) {
                  final userName = enrolledUsers[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        color: themeProvider.themeMode == ThemeMode.dark
                            ? Colors.grey[800]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: color.withOpacity(0.2),
                            child: Text(
                              userName[0].toUpperCase(),
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: themeProvider.themeMode == ThemeMode.dark
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}