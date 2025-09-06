import 'package:flutter/material.dart';
import 'course.dart';
import 'admincourse.dart';

class CourseDataManager {
  static final CourseDataManager _instance = CourseDataManager._internal();
  factory CourseDataManager() => _instance;
  CourseDataManager._internal();

  final List<Course> _courses = [
    Course(
      id: '1',
      title: 'Strength',
      instructor: 'Dr. Sarah Johnson',
      summary: 'Build muscle strength and power through progressive training',
      rating: 4.8,
      difficulty: 'Intermediate',
      enrolledCount: 1250,
      duration: '12 weeks',
      category: 'Strength Training',
      prerequisites: ['Basic fitness knowledge', 'Gym access'],
      description: 'Comprehensive strength training course covering progressive overload, proper form, and advanced techniques. Build real strength and learn industry best practices.',
    ),
    Course(
      id: '2',
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
      id: '3',
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
      id: '4',
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
      id: '5',
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
      id: '6',
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

  final Map<String, CourseDetails> _courseDetails = {};

  List<Course> get allCourses => List.unmodifiable(_courses);

  void addAdminCourse(AdminCourse adminCourse) {
    final course = Course(
      id: adminCourse.id,
      title: adminCourse.title,
      instructor: adminCourse.instructor,
      summary: adminCourse.summary,
      rating: adminCourse.rating,
      difficulty: adminCourse.difficulty,
      enrolledCount: adminCourse.enrolledCount,
      duration: adminCourse.duration,
      category: adminCourse.category,
      prerequisites: adminCourse.prerequisites,
      description: adminCourse.description,
    );

    final details = CourseDetails(
      sessionTitles: adminCourse.sessionTitles,
      faqQuestions: adminCourse.faqQuestions,
      faqAnswers: adminCourse.faqAnswers,
      language: adminCourse.language,
      lastUpdated: adminCourse.lastUpdated,
      releaseDate: adminCourse.releaseDate,
      sections: adminCourse.sections.map((section) => CourseSectionData(
        id: section.id,
        title: section.title,
        description: section.description,
        units: section.units.map((unit) => UnitData(
          id: unit.id,
          name: unit.name,
          description: unit.description,
          objectives: unit.objectives,
          dos: unit.dos,
          donts: unit.donts,
        )).toList(),
      )).toList(),
    );

    _courses.add(course);
    _courseDetails[course.id] = details;
  }

  void updateAdminCourse(AdminCourse adminCourse) {
    final index = _courses.indexWhere((c) => c.id == adminCourse.id);
    if (index != -1) {
      final course = Course(
        id: adminCourse.id,
        title: adminCourse.title,
        instructor: adminCourse.instructor,
        summary: adminCourse.summary,
        rating: adminCourse.rating,
        difficulty: adminCourse.difficulty,
        enrolledCount: adminCourse.enrolledCount,
        duration: adminCourse.duration,
        category: adminCourse.category,
        prerequisites: adminCourse.prerequisites,
        description: adminCourse.description,
      );

      final details = CourseDetails(
        sessionTitles: adminCourse.sessionTitles,
        faqQuestions: adminCourse.faqQuestions,
        faqAnswers: adminCourse.faqAnswers,
        language: adminCourse.language,
        lastUpdated: adminCourse.lastUpdated,
        releaseDate: adminCourse.releaseDate,
        sections: adminCourse.sections.map((section) => CourseSectionData(
          id: section.id,
          title: section.title,
          description: section.description,
          units: section.units.map((unit) => UnitData(
            id: unit.id,
            name: unit.name,
            description: unit.description,
            objectives: unit.objectives,
            dos: unit.dos,
            donts: unit.donts,
          )).toList(),
        )).toList(),
      );

      _courses[index] = course;
      _courseDetails[course.id] = details;
    }
  }

  void removeAdminCourse(String courseId) {
    _courses.removeWhere((c) => c.id == courseId);
    _courseDetails.remove(courseId);
  }

  CourseDetails? getCourseDetails(String courseId) {
    return _courseDetails[courseId];
  }

  List<String> getSessionTitles(String courseId) {
    final details = _courseDetails[courseId];
    if (details != null && details.sessionTitles.isNotEmpty) {
      return details.sessionTitles;
    }
    return [
      'Introduction & Setup',
      'Core Concepts',
      'Practical Applications',
      'Advanced Topics',
      'Final Project',
    ];
  }

  List<FAQItem> getFAQItems(String courseId) {
    final details = _courseDetails[courseId];
    if (details != null && details.faqQuestions.isNotEmpty) {
      List<FAQItem> faqs = [];
      for (int i = 0; i < details.faqQuestions.length; i++) {
        faqs.add(FAQItem(
          question: details.faqQuestions[i],
          answer: i < details.faqAnswers.length ? details.faqAnswers[i] : '',
        ));
      }
      return faqs;
    }
    return [
      FAQItem(
        question: 'How long do I have access to the course?',
        answer: 'You have lifetime access to the course materials once enrolled.',
      ),
      FAQItem(
        question: 'Is there a certificate upon completion?',
        answer: 'Yes, you will receive a certificate of completion that you can share on your professional profiles.',
      ),
      FAQItem(
        question: 'Can I get a refund if I\'m not satisfied?',
        answer: 'We offer a 30-day money-back guarantee if you\'re not completely satisfied with the course.',
      ),
    ];
  }

  Map<String, String> getCourseMetadata(String courseId) {
    final details = _courseDetails[courseId];
    if (details != null) {
      return {
        'Language': details.language,
        'Last Updated': details.lastUpdated,
        'Release Date': details.releaseDate,
      };
    }
    return {
      'Language': 'English',
      'Last Updated': 'December 2024',
      'Release Date': 'January 2024',
    };
  }

  List<CourseSectionData> getCourseSections(String courseId) {
    final details = _courseDetails[courseId];
    if (details != null && details.sections.isNotEmpty) {
      return details.sections;
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