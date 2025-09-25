import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'coursedetails.dart';
import 'course_data_manager.dart';
import 'theme_provider.dart';
import 'app_state.dart';

// Model class for Course
class Course {
  final String id;
  final String title;
  final String instructor;
  final String summary;
  final double rating;
  final String difficulty;
  final int enrolledCount;
  final String duration;
  final String category;
  final List<String> prerequisites;
  final String description;
  final bool isEnrolled;
  final bool isHighlighted;

  Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.summary,
    required this.rating,
    required this.difficulty,
    required this.enrolledCount,
    required this.duration,
    required this.category,
    required this.prerequisites,
    required this.description,
    this.isEnrolled = false,
    this.isHighlighted = false,
  });

  Course copyWith({
    String? id,
    String? title,
    String? instructor,
    String? summary,
    double? rating,
    String? difficulty,
    int? enrolledCount,
    String? duration,
    String? category,
    List<String>? prerequisites,
    String? description,
    bool? isEnrolled,
    bool? isHighlighted,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      instructor: instructor ?? this.instructor,
      summary: summary ?? this.summary,
      rating: rating ?? this.rating,
      difficulty: difficulty ?? this.difficulty,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      prerequisites: prerequisites ?? this.prerequisites,
      description: description ?? this.description,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }
}

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  List<Course> _filteredCourses = [];
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;
  late AnimationController _listAnimationController;
  late Animation<double> _listAnimation;

  final CourseDataManager _courseManager = CourseDataManager();
  List<Course> get _courses => _courseManager.allCourses;

  final List<String> _categories = [
    'All',
    'Track & Field',
  ];

  @override
  void initState() {
    super.initState();
    _filteredCourses = _courses;
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _listAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _listAnimationController,
        curve: Curves.easeOut,
      ),
    );
    _listAnimationController.forward();
  }

  void _filterCourses() {
    setState(() {
      _filteredCourses = _courses.where((course) {
        final matchesSearch = _searchController.text.isEmpty ||
            course.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            course.instructor.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            course.category.toLowerCase().contains(_searchController.text.toLowerCase());
        
        final matchesCategory = _selectedCategory == 'All' || course.category == _selectedCategory;
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final appState = Provider.of<AppState>(context);
    final standardAssessment = _courses.firstWhere((course) => course.isHighlighted, orElse: () => _courses.first);
    final otherCourses = _filteredCourses.where((course) => !course.isHighlighted).toList();
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            title: Text('Courses'),
            automaticallyImplyLeading: false,
            floating: true,
            snap: true,
          ),
          
          // Standard Assessment (Fixed at top)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: _buildCourseCard(standardAssessment),
            ),
          ),
          
          // Search and Filter Section (Sticky)
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchHeaderDelegate(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (value) => _filterCourses(),
                      decoration: InputDecoration(
                        hintText: 'Search courses, instructors, or categories...',
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Category Filter
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = category == _selectedCategory;
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              selected: isSelected,
                              label: Text(category,
                                style: TextStyle(
                                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyLarge?.color,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                                _filterCourses();
                              },
                              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              checkmarkColor: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Course Results Count
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                '${otherCourses.length} other courses found',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          
          // Other Course List (Can overlay above when scrolling)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final course = otherCourses[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.5),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _listAnimationController,
                        curve: Interval(
                          index * 0.1,
                          (index * 0.1) + 0.3,
                          curve: Curves.easeOut,
                        ),
                      ),
                    ),
                    child: FadeTransition(
                      opacity: Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).animate(
                        CurvedAnimation(
                          parent: _listAnimationController,
                          curve: Interval(
                            index * 0.1,
                            (index * 0.1) + 0.3,
                            curve: Curves.easeOut,
                          ),
                        ),
                      ),
                      child: _buildCourseCard(course),
                    ),
                  ),
                );
              },
              childCount: otherCourses.length,
            ),
          ),
          
          // Floating Action Button Space
          SliverToBoxAdapter(
            child: Container(
              height: 100,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        _showAddCourseDialog(context);
                      },
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      elevation: 8,
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text(
                        'Add Course',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    return Hero(
      tag: 'course-${course.id}',
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => CourseDetailsPage(course: course),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)),
                  child: child,
                );
              },
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()..scale(1.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
            border: course.isHighlighted
                ? Border.all(color: Theme.of(context).colorScheme.secondary, width: 3)
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Thumbnail with gradient overlay
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            child: _getCourseImage(course.title),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Color(0xFFFBBF24),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    course.rating.toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Course Title and Category
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  course.title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).textTheme.headlineSmall?.color,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  course.category,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Instructor
                          Text(
                            'by ${course.instructor}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Course Summary
                          Text(
                            course.summary,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 16),

                          // Course Stats with enhanced design
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Duration
                                Expanded(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        size: 20,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        course.duration,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  width: 1,
                                  height: 30,
                                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                ),

                                // Difficulty
                                Expanded(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.trending_up,
                                        size: 20,
                                        color: _getDifficultyColor(course.difficulty),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        course.difficulty,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _getDifficultyColor(course.difficulty),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  width: 1,
                                  height: 30,
                                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                ),

                                // Enrolled Count
                                Expanded(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.people,
                                        size: 20,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${course.enrolledCount}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getCourseImage(String courseTitle) {
    if (courseTitle.toLowerCase().contains('javelin')) {
      return Image.asset(
        'assets/images/javeline.jpg',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (courseTitle.toLowerCase().contains('hurdle')) {
      return Image.asset(
        'assets/images/hurdle.jpg',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      return Container(
        color: const Color(0xFFE5E7EB),
        child: const Center(
          child: Icon(
            Icons.play_circle_outline,
            size: 48,
            color: Color(0xFF9CA3AF),
          ),
        ),
      );
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF10B981);
      case 'intermediate':
        return const Color(0xFFF59E0B);
      case 'advanced':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _showAddCourseDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController instructorController = TextEditingController();
    final TextEditingController summaryController = TextEditingController();
    String selectedDifficulty = 'Beginner';
    String selectedCategory = 'Track & Field';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Course'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Course Title',
                    hintText: 'Enter course title',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: instructorController,
                  decoration: const InputDecoration(
                    labelText: 'Instructor',
                    hintText: 'Enter instructor name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: summaryController,
                  decoration: const InputDecoration(
                    labelText: 'Summary',
                    hintText: 'Enter course summary',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedDifficulty,
                  decoration: const InputDecoration(
                    labelText: 'Difficulty Level',
                  ),
                  items: ['Beginner', 'Intermediate', 'Advanced']
                      .map((difficulty) => DropdownMenuItem<String>(
                            value: difficulty,
                            child: Text(difficulty),
                          ))
                      .toList(),
                  onChanged: (value) {
                    selectedDifficulty = value!;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  items: ['Track & Field', 'Swimming', 'Basketball']
                      .map((category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    selectedCategory = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    instructorController.text.isNotEmpty) {
                  final newCourse = Course(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    instructor: instructorController.text,
                    summary: summaryController.text.isNotEmpty
                        ? summaryController.text
                        : 'Learn the fundamentals of this exciting sport.',
                    rating: 4.5,
                    difficulty: selectedDifficulty,
                    enrolledCount: 0,
                    duration: '2-3 hours',
                    category: selectedCategory,
                    prerequisites: ['Basic fitness level'],
                    description: 'Detailed course description would go here.',
                  );

                  _courseManager.addCourse(newCourse);
                  _filterCourses();

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Course added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Add Course'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchAnimationController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }
}

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  
  _SearchHeaderDelegate({required this.child});
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }
  
  @override
  double get maxExtent => 140;
  
  @override
  double get minExtent => 140;
  
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
