import 'package:flutter/material.dart';
import 'course.dart';

class CourseDataManager {
  static final CourseDataManager _instance = CourseDataManager._internal();
  factory CourseDataManager() => _instance;
  CourseDataManager._internal();

  final List<Course> _courses = [
    Course(
      id: '1',
      title: 'Javelin Throw Mastery',
      instructor: 'Coach Rodriguez',
      summary: 'Complete javelin throwing program from fundamentals to competition level',
      rating: 4.9,
      difficulty: 'Advanced',
      enrolledCount: 520,
      duration: '10 days',
      category: 'Track & Field',
      prerequisites: ['Athletic background', 'Shoulder mobility', 'Core strength'],
      description: 'Comprehensive javelin throwing course covering biomechanics, power development, and competition strategies. Transform your technique with scientific training methods.',
    ),
    Course(
      id: '2',
      title: 'Sprint Hurdles Excellence',
      instructor: 'Coach Thompson',
      summary: 'Elite hurdling program for competitive sprint hurdle events',
      rating: 4.8,
      difficulty: 'Advanced',
      enrolledCount: 285,
      duration: '10 days',
      category: 'Track & Field',
      prerequisites: ['Sub-12 second 100m', 'Flexibility training', 'Sprint experience'],
      description: 'Advanced hurdle training focusing on race strategy, technical precision, and speed endurance. Master 110m and 100m hurdle events with professional coaching methods.',
    ),
    Course(
      id: '3',
      title: 'Strength Assessment',
      instructor: 'Coach Alpha',
      summary: 'Assess and improve your athletic strength with targeted exercises.',
      rating: 4.7,
      difficulty: 'Beginner',
      enrolledCount: 150,
      duration: '1 day',
      category: 'Fitness',
      prerequisites: ['None'],
      description: 'A comprehensive module to assess your current strength levels across key athletic movements. Includes sit-ups, vertical jumps, shuttle runs, and height measurement.',
      isHighlighted: true,
    ),
  ];

  final Map<String, CourseDetails> _courseDetails = {};

  List<Course> get allCourses => List.unmodifiable(_courses);

  void addCourse(Course course) {
    _courses.add(course);
  }

  CourseDetails? getCourseDetails(String courseId) {
    return _courseDetails[courseId];
  }

  List<String> getSessionTitles(String courseId) {
    return [
      'Fundamentals & Assessment',
      'Technical Development',
      'Power & Conditioning',
      'Competition Preparation',
      'Performance Optimization',
    ];
  }

  List<FAQItem> getFAQItems(String courseId) {
    return [
      FAQItem(
        question: 'What equipment do I need for training?',
        answer: 'Basic training equipment includes practice implements, proper footwear, and access to a throwing/running area.',
      ),
      FAQItem(
        question: 'How often should I train per week?',
        answer: 'We recommend 4-5 training sessions per week with proper rest and recovery periods.',
      ),
      FAQItem(
        question: 'Is this suitable for beginners?',
        answer: 'This course is designed for athletes with some athletic background. We recommend basic fitness before starting.',
      ),
    ];
  }

  Map<String, String> getCourseMetadata(String courseId) {
    return {
      'Last Updated': 'January 2025',
      'Release Date': 'March 2024',
    };
  }

  List<CourseSectionData> getCourseSections(String courseId) {
    if (courseId == '3') { // Strength Assessment
      return [
        CourseSectionData(
          id: '1',
          title: 'Strength Assessment Session',
          description: 'Complete strength evaluation',
          units: [
            UnitData(
              id: '1',
              name: 'Complete Assessment',
              description: 'Comprehensive strength and fitness evaluation',
              objectives: ['Complete all assessment exercises', 'Record accurate measurements'],
              dos: ['Follow proper form', 'Give maximum effort', 'Rest between exercises'],
              donts: ['Skip warm-up', 'Rush through exercises', 'Ignore safety guidelines'],
            ),
          ],
        ),
      ];
    }
    
    return [
      CourseSectionData(
        id: '1',
        title: 'Section 1: Foundations',
        description: 'Basic principles and form',
        units: [
          UnitData(
            id: '1',
            name: 'Warm-Up Readiness',
            description: 'Learn proper activation techniques',
            objectives: ['Perform movements smoothly', 'Follow demonstrated range'],
            dos: ['Keep core engaged', 'Breathe naturally'],
            donts: ['Don\'t rush movements', 'Avoid forcing ranges'],
          ),
          UnitData(
            id: '2',
            name: 'Movement Efficiency',
            description: 'Master fundamental techniques',
            objectives: ['Maintain proper posture', 'Execute with precision'],
            dos: ['Focus on quality', 'Keep movements symmetrical'],
            donts: ['Don\'t compensate patterns', 'Avoid excessive speed'],
          ),
        ],
      ),
    ];
  }
}

class CourseDetails {
  final List<String> sessionTitles;
  final List<String> faqQuestions;
  final List<String> faqAnswers;
  final String language;
  final String lastUpdated;
  final String releaseDate;
  final List<CourseSectionData> sections;

  CourseDetails({
    required this.sessionTitles,
    required this.faqQuestions,
    required this.faqAnswers,
    required this.language,
    required this.lastUpdated,
    required this.releaseDate,
    required this.sections,
  });
}

class CourseSectionData {
  final String id;
  final String title;
  final String description;
  final List<UnitData> units;

  CourseSectionData({
    required this.id,
    required this.title,
    required this.description,
    required this.units,
  });
}

class UnitData {
  final String id;
  final String name;
  final String description;
  final List<String> objectives;
  final List<String> dos;
  final List<String> donts;

  UnitData({
    required this.id,
    required this.name,
    required this.description,
    required this.objectives,
    required this.dos,
    required this.donts,
  });
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
}