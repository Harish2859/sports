import 'package:flutter/material.dart';
import 'coursedetails.dart';
import 'course_data_manager.dart';

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
    );
  }
}

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  List<Course> _filteredCourses = [];

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
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          // Search and Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) => _filterCourses(),
                  decoration: InputDecoration(
                    hintText: 'Search courses, instructors, or categories...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
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
                          label: Text(category),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                            _filterCourses();
                          },
                          selectedColor: const Color(0xFF2563EB).withOpacity(0.2),
                          checkmarkColor: const Color(0xFF2563EB),
                          labelStyle: TextStyle(
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF6B7280),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Course Results Count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              '${_filteredCourses.length} courses found',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Course List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredCourses.length,
              itemBuilder: (context, index) {
                final course = _filteredCourses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildCourseCard(course),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailsPage(course: course),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Thumbnail
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 48,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Title and Category
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          course.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Instructor
                  Text(
                    'by ${course.instructor}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Course Summary
                  Text(
                    course.summary,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4B5563),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Course Stats
                  Row(
                    children: [
                      // Rating
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Color(0xFFFBBF24),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            course.rating.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Difficulty Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(course.difficulty).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          course.difficulty,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getDifficultyColor(course.difficulty),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Enrolled Count
                      Row(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${course.enrolledCount}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

