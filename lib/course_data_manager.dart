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
    final details = _courseDetails[courseId];
    if (details != null && details.sessionTitles.isNotEmpty) {
      return details.sessionTitles;
    }
    
    // Return specific session titles based on course ID
    if (courseId == '2') {
      // Hurdles course - only 1 session
      return [
        'Sprint Hurdle Mastery',
      ];
    }
    
    // Default for other courses
    return [
      'Fundamentals & Assessment',
      'Technical Development',
      'Power & Conditioning',
      'Competition Preparation',
      'Performance Optimization',
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
    final details = _courseDetails[courseId];
    if (details != null) {
      return {
        'Last Updated': details.lastUpdated,
        'Release Date': details.releaseDate,
      };
    }
    return {
      'Last Updated': 'January 2025',
      'Release Date': 'March 2024',
    };
  }

  List<CourseSectionData> getCourseSections(String courseId) {
    final details = _courseDetails[courseId];
    if (details != null && details.sections.isNotEmpty) {
      return details.sections;
    }

    // Return specific sections based on course ID
    if (courseId == '1') {
      // Javelin Throw Course Sections
      return [
        CourseSectionData(
          id: '1',
          title: 'Section 1: Biomechanics & Foundation',
          description: 'Master throwing biomechanics and establish proper foundation',
          units: [
            UnitData(
              id: '1',
              name: 'Javelin Grip Basics',
              description: 'Learn the correct way to hold the javelin',
              objectives: ['Position hand correctly', 'Maintain secure grip'],
              dos: ['Use binding tape', 'Keep wrist straight'],
              donts: ['Don\'t grip too tightly', 'Avoid bent wrist'],
            ),
            UnitData(
              id: '2',
              name: 'Stance Setup',
              description: 'Establish proper throwing stance and positioning',
              objectives: ['Position feet correctly', 'Align body properly'],
              dos: ['Keep feet shoulder-width', 'Face throwing direction'],
              donts: ['Don\'t stand too narrow', 'Avoid incorrect alignment'],
            ),
            UnitData(
              id: '3',
              name: 'Balance and Posture',
              description: 'Develop balance and maintain proper posture',
              objectives: ['Find center of gravity', 'Maintain stability'],
              dos: ['Keep core engaged', 'Distribute weight evenly'],
              donts: ['Don\'t lean excessively', 'Avoid unstable positions'],
            ),
            UnitData(
              id: '4',
              name: 'Grip and Stance Drills',
              description: 'Practice fundamental grip and stance exercises',
              objectives: ['Build muscle memory', 'Ensure consistency'],
              dos: ['Practice slowly', 'Focus on form'],
              donts: ['Don\'t rush', 'Avoid bad habits'],
            ),
          ],
        ),
        CourseSectionData(
          id: '2',
          title: 'Section 2: Dynamic Approach System',
          description: 'Master the dynamic approach run and acceleration patterns',
          units: [
            UnitData(
              id: '5',
              name: 'Approach Run Setup',
              description: 'Learn the approach run starting position and initial movement',
              objectives: ['Establish starting point', 'Begin with correct posture'],
              dos: ['Start with javelin up', 'Maintain balance'],
              donts: ['Don\'t start too close', 'Avoid poor posture'],
            ),
            UnitData(
              id: '6',
              name: 'Acceleration Phase',
              description: 'Build speed through the approach run',
              objectives: ['Achieve optimal speed', 'Maintain control'],
              dos: ['Drive with arms', 'Keep strides consistent'],
              donts: ['Don\'t decelerate', 'Avoid losing control'],
            ),
            UnitData(
              id: '7',
              name: 'Transition to Throw',
              description: 'Smoothly transition from run to throwing position',
              objectives: ['Time the crossover', 'Maintain momentum'],
              dos: ['Plant support foot', 'Transfer weight smoothly'],
              donts: ['Don\'t stop abruptly', 'Avoid jerky movements'],
            ),
            UnitData(
              id: '8',
              name: 'Approach Run Drills',
              description: 'Practice approach run with specific focus exercises',
              objectives: ['Perfect timing', 'Build consistency'],
              dos: ['Use markers', 'Practice repeatedly'],
              donts: ['Don\'t sacrifice form', 'Avoid fatigue'],
            ),
          ],
        ),
        CourseSectionData(
          id: '3',
          title: 'Section 3: Power Transfer & Release',
          description: 'Optimize power transfer through kinetic chain and perfect release mechanics',
          units: [
            UnitData(
              id: '9',
              name: 'Throwing Motion',
              description: 'Learn the fundamental throwing movement',
              objectives: ['Generate power', 'Maintain control'],
              dos: ['Use full body', 'Keep arm extended'],
              donts: ['Don\'t throw with arm only', 'Avoid early release'],
            ),
            UnitData(
              id: '10',
              name: 'Release Point',
              description: 'Master the critical release timing and technique',
              objectives: ['Find optimal release angle', 'Control javelin direction'],
              dos: ['Release at right moment', 'Maintain follow-through'],
              donts: ['Don\'t release too early', 'Avoid dropping javelin'],
            ),
            UnitData(
              id: '11',
              name: 'Power Generation',
              description: 'Develop maximum throwing power through proper mechanics',
              objectives: ['Utilize body segments', 'Generate torque'],
              dos: ['Use hip drive', 'Maintain sequence'],
              donts: ['Don\'t neglect legs', 'Avoid arm-dominant throws'],
            ),
            UnitData(
              id: '12',
              name: 'Throwing Drills',
              description: 'Practice throwing technique with progressive exercises',
              objectives: ['Build confidence', 'Perfect form'],
              dos: ['Start with light javelins', 'Focus on technique'],
              donts: ['Don\'t skip fundamentals', 'Avoid bad habits'],
            ),
          ],
        ),
        CourseSectionData(
          id: '4',
          title: 'Section 4: Athletic Performance Development',
          description: 'Develop sport-specific strength, power, and conditioning for elite performance',
          units: [
            UnitData(
              id: '13',
              name: 'Core Strength',
              description: 'Develop core strength essential for throwing power',
              objectives: ['Build rotational strength', 'Improve stability'],
              dos: ['Use compound movements', 'Progress gradually'],
              donts: ['Don\'t neglect recovery', 'Avoid poor form'],
            ),
            UnitData(
              id: '14',
              name: 'Upper Body Power',
              description: 'Strengthen upper body for better throwing performance',
              objectives: ['Build shoulder strength', 'Improve arm speed'],
              dos: ['Focus on functional strength', 'Include recovery'],
              donts: ['Don\'t overtrain', 'Avoid imbalanced training'],
            ),
            UnitData(
              id: '15',
              name: 'Lower Body Power',
              description: 'Develop explosive lower body strength',
              objectives: ['Build leg power', 'Improve drive'],
              dos: ['Include plyometrics', 'Maintain balance'],
              donts: ['Don\'t neglect flexibility', 'Avoid injury'],
            ),
            UnitData(
              id: '16',
              name: 'Conditioning Program',
              description: 'Implement comprehensive conditioning for peak performance',
              objectives: ['Build endurance', 'Prevent injury'],
              dos: ['Include mobility work', 'Monitor progress'],
              donts: ['Don\'t overdo it', 'Avoid neglecting nutrition'],
            ),
          ],
        ),
        CourseSectionData(
          id: '5',
          title: 'Section 5: Elite Competition Strategy',
          description: 'Master competition psychology, advanced techniques, and performance optimization',
          units: [
            UnitData(
              id: '17',
              name: 'Competition Preparation',
              description: 'Mental and physical preparation for competitions',
              objectives: ['Develop competition routine', 'Manage pressure'],
              dos: ['Visualize success', 'Follow preparation routine'],
              donts: ['Don\'t change technique', 'Avoid negative thinking'],
            ),
            UnitData(
              id: '18',
              name: 'Advanced Techniques',
              description: 'Learn advanced throwing techniques and refinements',
              objectives: ['Optimize technique', 'Improve consistency'],
              dos: ['Film and analyze', 'Make gradual changes'],
              donts: ['Don\'t overhaul technique', 'Avoid experimental changes'],
            ),
            UnitData(
              id: '19',
              name: 'Performance Analysis',
              description: 'Analyze performance and identify improvement areas',
              objectives: ['Track progress', 'Identify weaknesses'],
              dos: ['Use objective measures', 'Keep training log'],
              donts: ['Don\'t be discouraged', 'Avoid comparison traps'],
            ),
            UnitData(
              id: '20',
              name: 'Competition Execution',
              description: 'Strategies for successful competition performance',
              objectives: ['Optimize performance', 'Handle variables'],
              dos: ['Stay focused', 'Trust training'],
              donts: ['Don\'t panic', 'Avoid last-minute changes'],
            ),
          ],
        ),
      ];
    } else if (courseId == '2') {
      // Hurdles Course Sections
      return [
        CourseSectionData(
          id: '1',
          title: 'Section 1: Sprint Hurdle Mastery',
          description: 'Master elite sprint hurdle technique and race strategy',
          units: [
            UnitData(
              id: '1',
              name: 'Advanced Hurdle Clearance',
              description: 'Perfect the technical aspects of hurdle clearance at race pace',
              objectives: ['Minimize clearance time', 'Maintain sprint rhythm'],
              dos: ['Attack the hurdle', 'Drive through with speed'],
              donts: ['Don\'t decelerate before hurdles', 'Avoid excessive height'],
            ),
          ],
        ),
      ];
    }

    // Default fallback
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