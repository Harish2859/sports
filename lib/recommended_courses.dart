import 'package:flutter/material.dart';
import 'course.dart';
import 'home.dart';

class RecommendedCoursesPage extends StatelessWidget {
  final Map<String, dynamic> userPreferences;

  const RecommendedCoursesPage({super.key, required this.userPreferences});

  @override
  Widget build(BuildContext context) {
    final recommendedCourses = _getRecommendedCourses();

    return MainLayout(
      currentIndex: 1,
      onTabChanged: (index) {
        Navigator.pop(context);
      },
      child: Column(
        children: [
          // Header Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Perfect Matches for You',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Based on your preferences, we found ${recommendedCourses.length} courses',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // Course List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recommendedCourses.length,
              itemBuilder: (context, index) {
                final course = recommendedCourses[index];
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

  List<Course> _getRecommendedCourses() {
    return [
      Course(
        id: 'r1',
        title: 'Football Fundamentals',
        instructor: 'Coach Martinez',
        summary: 'Master the basics of football with professional techniques',
        rating: 4.7,
        difficulty: 'Beginner',
        enrolledCount: 850,
        duration: '8 weeks',
        category: 'Football',
        prerequisites: ['Basic fitness'],
        description: 'Learn football fundamentals including passing, shooting, and tactical awareness.',
      ),
      Course(
        id: 'r2',
        title: 'Basketball Skills',
        instructor: 'Coach Thompson',
        summary: 'Develop your basketball skills from dribbling to shooting',
        rating: 4.6,
        difficulty: 'Intermediate',
        enrolledCount: 720,
        duration: '10 weeks',
        category: 'Basketball',
        prerequisites: ['Basic coordination'],
        description: 'Comprehensive basketball training covering all essential skills.',
      ),
      Course(
        id: 'r3',
        title: 'Swimming Techniques',
        instructor: 'Sarah Wilson',
        summary: 'Perfect your swimming strokes and build endurance',
        rating: 4.8,
        difficulty: 'Beginner',
        enrolledCount: 650,
        duration: '12 weeks',
        category: 'Swimming',
        prerequisites: ['Basic swimming ability'],
        description: 'Learn proper swimming techniques for all major strokes.',
      ),
      Course(
        id: 'r4',
        title: 'Yoga for Athletes',
        instructor: 'Maya Patel',
        summary: 'Improve flexibility and mental focus through yoga',
        rating: 4.9,
        difficulty: 'Beginner',
        enrolledCount: 920,
        duration: '6 weeks',
        category: 'Yoga',
        prerequisites: ['None'],
        description: 'Yoga practices specifically designed for athletic performance.',
      ),
      Course(
        id: 'r5',
        title: 'Running Performance',
        instructor: 'David Kim',
        summary: 'Enhance your running technique and endurance',
        rating: 4.5,
        difficulty: 'Intermediate',
        enrolledCount: 580,
        duration: '14 weeks',
        category: 'Running',
        prerequisites: ['Basic running experience'],
        description: 'Advanced running techniques for improved performance and injury prevention.',
      ),
    ];
  }

  Widget _buildCourseCard(Course course) {
    return Container(
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
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE5E7EB),
              borderRadius: BorderRadius.only(
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

                    // Duration
                    Text(
                      course.duration,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
}