import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'course.dart';
import 'app_state.dart';
import 'main_layout.dart';
import 'gotocourse.dart';
import 'course_data_manager.dart';
import 'theme_provider.dart';

// Comment class remains the same
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

class _CourseDetailsPageState extends State<CourseDetailsPage> with TickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final AppState _appState = AppState();

  late Course _course;
  int _currentSection = 0;
  int _enrolledCount = 0;
  
  final Map<String, IconData> _sectionTabs = {
    'About': Icons.info_outline,
    'Prerequisites': Icons.check_circle_outline,
    'Sessions': Icons.list_alt,
    'Reviews': Icons.reviews_outlined,
    'FAQ': Icons.quiz_outlined,
    'Info': Icons.dataset_outlined,
    'Leaderboard': Icons.leaderboard_outlined,
  };

  // **NEW**: A list of placeholder images for the session cards.
  // Make sure you have these images in your assets/images/ folder.
  final List<String> _sessionImages = [
    'assets/images/javeline.jpg',
    'assets/images/hurdle.jpg',
    'assets/images/running_track.jpg', // Example new image
    'assets/images/starting_blocks.jpg', // Example new image
  ];

  List<Comment> _comments = [
    Comment(id: '1', username: 'Alex Johnson', text: 'Excellent course! The instructor explains complex concepts very clearly.', timestamp: DateTime.now().subtract(const Duration(hours: 2)), likes: 12),
    Comment(id: '2', username: 'Maria Garcia', text: 'Great practical examples and hands-on projects. Highly recommend!', timestamp: DateTime.now().subtract(const Duration(days: 1)), likes: 8),
    Comment(id: '3', username: 'John Smith', text: 'The course content is up-to-date and relevant to industry standards.', timestamp: DateTime.now().subtract(const Duration(days: 2)), likes: 15),
  ];

  final CourseDataManager _courseManager = CourseDataManager();
  List<String> get _sessionTitles => _courseManager.getSessionTitles(_course.id);

  @override
  void initState() {
    super.initState();
    _course = widget.course;
    _enrolledCount = _course.enrolledCount;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(themeProvider),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildSectionTabs(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: _buildSectionContent(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildEnrollButton(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeProvider themeProvider) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: themeProvider.themeMode == ThemeMode.dark
          ? Colors.grey[900]
          : const Color(0xFF2563EB),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              _appState.isFavorite(_course.id) ? Icons.favorite : Icons.favorite_border,
              color: _appState.isFavorite(_course.id) ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            _getCourseBannerImage(_course.title),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_course.category, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _course.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, offset: Offset(0, 2), blurRadius: 4)],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTabs() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _sectionTabs.length,
        itemBuilder: (context, index) {
          final title = _sectionTabs.keys.elementAt(index);
          final icon = _sectionTabs.values.elementAt(index);
          final isSelected = index == _currentSection;
          return GestureDetector(
            onTap: () => setState(() => _currentSection = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2563EB) : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: isSelected ? const Color(0xFF2563EB) : Colors.grey.withOpacity(0.2)),
                boxShadow: isSelected
                    ? [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionContent() {
    switch (_currentSection) {
      case 0:
        return _buildAboutSection(key: const ValueKey('about'));
      case 1:
        return _buildPrerequisitesSection(key: const ValueKey('prereqs'));
      case 2:
        return _buildSessionsSection(key: const ValueKey('sessions'));
      case 3:
        return _buildReviewsSection(key: const ValueKey('reviews'));
      case 4:
        return _buildFAQSection(key: const ValueKey('faq'));
      case 5:
        return _buildInfoSection(key: const ValueKey('info'));
      case 6:
        return _buildLeaderboardSection(key: const ValueKey('leaderboard'));
      default:
        return const SizedBox.shrink(key: ValueKey('empty'));
    }
  }

  Widget _buildAboutSection({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstructorCard(),
          const SizedBox(height: 24),
          const Text("Course Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildCourseStats(),
          const SizedBox(height: 24),
          Text(
            _course.description,
            style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildInstructorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
            child: Text(
              _course.instructor[0].toUpperCase(),
              style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_course.instructor, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Course Instructor", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _InfoPill(icon: Icons.star_rounded, text: '${_course.rating} Rating', color: const Color(0xFFFBBF24)),
        _InfoPill(icon: Icons.timer_outlined, text: _course.duration, color: const Color(0xFF10B981)),
        _InfoPill(icon: Icons.bar_chart_rounded, text: _course.difficulty, color: const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _buildPrerequisitesSection({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Prerequisites', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_course.prerequisites.isEmpty)
            const Text('No prerequisites required')
          else
            ..._course.prerequisites.map((prereq) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 22, color: Color(0xFF10B981)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(prereq, style: const TextStyle(fontSize: 16))),
                    ],
                  ),
                )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // **MODIFIED**: This section now builds image-based cards.
  Widget _buildSessionsSection({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Module Sessions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _sessionTitles.length,
            itemBuilder: (context, index) {
              // Use modulo to loop through the available images
              final imagePath = _sessionImages[index % _sessionImages.length];
              return Card(
                clipBehavior: Clip.antiAlias, // Ensures the image respects the card's rounded corners
                elevation: 4.0,
                shadowColor: Colors.black.withOpacity(0.2),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    // Background Image with error handling
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          imagePath,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.play_circle_outline,
                                  size: 40,
                                  color: Colors.white70,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Gradient Scrim for text readability
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                        ),
                      ),
                    ),
                    // Text and Icon Content
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Session ${index + 1}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _sessionTitles[index],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.play_circle_fill,
                            color: Colors.white.withOpacity(0.9),
                            size: 40,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildReviewsSection({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${_comments.length} reviews', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(radius: 16, backgroundColor: Color(0xFF2563EB), child: Icon(Icons.person, size: 16, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                    suffixIcon: IconButton(onPressed: _addComment, icon: const Icon(Icons.send, color: Color(0xFF2563EB))),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            itemBuilder: (context, index) => _buildCommentCard(_comments[index]),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFAQSection({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FAQ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _courseManager.getFAQItems(_course.id).map((faq) => _buildFAQItem(faq.question, faq.answer)).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoSection({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Module Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildInfoRow('Category', _course.category),
          _buildInfoRow('Duration', _course.duration),
          _buildInfoRow('Difficulty Level', _course.difficulty),
          ..._courseManager.getCourseMetadata(_course.id).entries.map((entry) => _buildInfoRow(entry.key, entry.value)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLeaderboardSection({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Leaderboards', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildGenderLeaderboard('Male', Icons.male, const Color(0xFF2563EB)),
          const SizedBox(height: 16),
          _buildGenderLeaderboard('Female', Icons.female, const Color(0xFFDC2626)),
          const SizedBox(height: 16),
          _buildGenderLeaderboard('Other', Icons.transgender, const Color(0xFF7C3AED)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEnrollButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: _appState.isEnrolled(_course.id)
                ? [const Color(0xFF10B981), const Color(0xFF059669)]
                : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
          ),
          boxShadow: [
            BoxShadow(
              color: (_appState.isEnrolled(_course.id) ? const Color(0xFF10B981) : const Color(0xFF2563EB)).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _appState.isEnrolled(_course.id)
              ? () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          GotoCoursePage(courseName: _course.title, courseId: _course.id),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: animation.drive(Tween(begin: const Offset(0.0, 0.1), end: Offset.zero)),
                            child: child,
                          ),
                        );
                      },
                    ),
                  );
                }
              : _enrollInCourse,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_appState.isEnrolled(_course.id) ? Icons.play_arrow : Icons.school, size: 24, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                _appState.isEnrolled(_course.id) ? 'Continue Learning' : 'Enroll for the Module',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
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
        username: 'You',
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

  Widget _buildCommentCard(Comment comment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
              child: Text(comment.username[0].toUpperCase(), style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(comment.username, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Text(_formatTimestamp(comment.timestamp), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(comment.text, style: const TextStyle(fontSize: 14, height: 1.4)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _toggleLike(comment),
                    child: Row(
                      children: [
                        Icon(comment.isLiked ? Icons.favorite : Icons.favorite_border, size: 16, color: comment.isLiked ? Colors.red : Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(comment.likes.toString(), style: TextStyle(fontSize: 12, color: comment.isLiked ? Colors.red : Colors.grey[600], fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4)),
        ),
      ],
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600]))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _getCourseBannerImage(String courseTitle) {
    if (courseTitle.toLowerCase().contains('javelin')) {
      return Image.asset('assets/images/javeline.jpg', fit: BoxFit.cover);
    } else if (courseTitle.toLowerCase().contains('hurdle')) {
      return Image.asset('assets/images/hurdle.jpg', fit: BoxFit.cover);
    } else {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white38)),
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

  Widget _buildGenderLeaderboard(String gender, IconData icon, Color color) {
    final enrolledUsers = _appState.getEnrolledUsersByGender(_course.id, gender) ?? [];
    final safeEnrolledUsers = enrolledUsers.where((user) => user != null && user.isNotEmpty).toList();
    final enrolledCount = safeEnrolledUsers.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
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
              Text('$gender Leaderboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              const Spacer(),
              Text('$enrolledCount enrolled', style: TextStyle(fontSize: 12, color: color.withOpacity(0.7))),
            ],
          ),
          const SizedBox(height: 12),
          if (safeEnrolledUsers.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No $gender users enrolled yet', style: TextStyle(fontSize: 14, color: color.withOpacity(0.6))),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: safeEnrolledUsers.length > 5 ? 5 : safeEnrolledUsers.length, // Show top 5
              itemBuilder: (context, index) {
                final userName = safeEnrolledUsers[index] ?? 'Unknown';
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Text(
                    '#${index + 1}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                  ),
                  title: Text(userName),
                  trailing: CircleAvatar(
                    radius: 14,
                    backgroundColor: color.withOpacity(0.2),
                    child: Text(userName.isNotEmpty ? userName[0].toUpperCase() : '?', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoPill({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}