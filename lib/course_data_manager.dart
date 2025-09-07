import 'package:flutter/material.dart';
import 'course.dart';

class CourseDataManager {
  static final CourseDataManager _instance = CourseDataManager._internal();
  factory CourseDataManager() => _instance;
  CourseDataManager._internal();

  final List<Course> _courses = [
    Course(
      id: '1',
      title: 'Long Jump',
      instructor: 'Coach Johnson',
      summary: 'Master the art of long jump with proper technique and explosive power',
      rating: 4.8,
      difficulty: 'Intermediate',
      enrolledCount: 450,
      duration: '10 weeks',
      category: 'Track & Field',
      prerequisites: ['Basic running ability', 'Good coordination'],
      description: 'Comprehensive long jump training covering approach run, takeoff, flight, and landing techniques. Develop explosive power and perfect your form for maximum distance.',
    ),
    Course(
      id: '2',
      title: 'Javelin Throw',
      instructor: 'Coach Martinez',
      summary: 'Learn proper javelin throwing techniques for maximum distance and accuracy',
      rating: 4.7,
      difficulty: 'Intermediate',
      enrolledCount: 380,
      duration: '12 weeks',
      category: 'Track & Field',
      prerequisites: ['Basic throwing experience', 'Good upper body strength'],
      description: 'Master the javelin throw with proper grip, approach, and release techniques. Build strength and coordination for optimal performance.',
    ),
    Course(
      id: '3',
      title: 'Hurdles',
      instructor: 'Coach Smith',
      summary: 'Master hurdling techniques for speed and efficiency over obstacles',
      rating: 4.6,
      difficulty: 'Intermediate',
      enrolledCount: 320,
      duration: '8 weeks',
      category: 'Track & Field',
      prerequisites: ['Basic sprinting skills', 'Good agility'],
      description: 'Learn proper hurdling form, rhythm, and clearance techniques. Develop the speed and coordination needed for successful hurdle races.',
    ),
  ];

  final Map<String, CourseDetails> _courseDetails = {};

  List<Course> get allCourses => List.unmodifiable(_courses);



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

    // Return specific sections based on course ID
    if (courseId == '1') {
      // Long Jump Course Sections
      return [
        CourseSectionData(
          id: '1',
          title: 'Section 1: Approach Run Fundamentals',
          description: 'Master the approach run technique for optimal speed and rhythm',
          units: [
            UnitData(
              id: '1',
              name: 'Approach Run Basics',
              description: 'Learn the proper approach run setup and initial steps',
              objectives: ['Establish correct starting position', 'Develop consistent rhythm'],
              dos: ['Maintain upright posture', 'Keep eyes focused ahead'],
              donts: ['Don\'t look down', 'Avoid starting too fast'],
            ),
            UnitData(
              id: '2',
              name: 'Speed Development',
              description: 'Build speed throughout the approach run',
              objectives: ['Achieve maximum controllable speed', 'Maintain acceleration'],
              dos: ['Drive with arms', 'Keep strides consistent'],
              donts: ['Don\'t decelerate', 'Avoid short strides'],
            ),
            UnitData(
              id: '3',
              name: 'Rhythm and Timing',
              description: 'Perfect the timing of your approach run',
              objectives: ['Count steps accurately', 'Time the takeoff point'],
              dos: ['Practice with markers', 'Maintain consistent pace'],
              donts: ['Don\'t rush the last steps', 'Avoid changing rhythm'],
            ),
            UnitData(
              id: '4',
              name: 'Approach Run Drills',
              description: 'Practice drills to improve approach consistency',
              objectives: ['Execute smooth transitions', 'Build muscle memory'],
              dos: ['Focus on form', 'Repeat consistently'],
              donts: ['Don\'t sacrifice technique', 'Avoid fatigue'],
            ),
          ],
        ),
        CourseSectionData(
          id: '2',
          title: 'Section 2: Takeoff Technique',
          description: 'Learn the critical takeoff mechanics for maximum height and distance',
          units: [
            UnitData(
              id: '5',
              name: 'Takeoff Board Setup',
              description: 'Master the positioning and setup for takeoff',
              objectives: ['Position correctly on board', 'Prepare for explosive takeoff'],
              dos: ['Plant support foot firmly', 'Keep body aligned'],
              donts: ['Don\'t step on the board early', 'Avoid leaning back'],
            ),
            UnitData(
              id: '6',
              name: 'Drive Phase',
              description: 'Execute powerful upward and forward drive',
              objectives: ['Generate maximum force', 'Maintain forward momentum'],
              dos: ['Drive arms upward', 'Extend takeoff leg fully'],
              donts: ['Don\'t block with arms', 'Avoid early takeoff'],
            ),
            UnitData(
              id: '7',
              name: 'Body Position',
              description: 'Achieve optimal body position during takeoff',
              objectives: ['Maintain upright posture', 'Control body rotation'],
              dos: ['Keep head neutral', 'Drive knees upward'],
              donts: ['Don\'t arch back excessively', 'Avoid side-to-side movement'],
            ),
            UnitData(
              id: '8',
              name: 'Takeoff Drills',
              description: 'Practice takeoff-specific exercises and drills',
              objectives: ['Build explosive power', 'Perfect timing'],
              dos: ['Focus on height', 'Practice repeatedly'],
              donts: ['Don\'t neglect form', 'Avoid rushing'],
            ),
          ],
        ),
        CourseSectionData(
          id: '3',
          title: 'Section 3: Flight and Hang Technique',
          description: 'Master the flight phase for optimal distance and style',
          units: [
            UnitData(
              id: '9',
              name: 'Flight Position',
              description: 'Learn the proper body position during flight',
              objectives: ['Achieve hang position', 'Maintain aerodynamic form'],
              dos: ['Keep legs together', 'Arms extended forward'],
              donts: ['Don\'t bend at waist', 'Avoid tucking legs'],
            ),
            UnitData(
              id: '10',
              name: 'Hang Time Optimization',
              description: 'Maximize time in the air with proper technique',
              objectives: ['Control body position', 'Maintain forward momentum'],
              dos: ['Stay relaxed', 'Keep core engaged'],
              donts: ['Don\'t tense up', 'Avoid premature descent'],
            ),
            UnitData(
              id: '11',
              name: 'Style Development',
              description: 'Develop personal style while maintaining efficiency',
              objectives: ['Find comfortable position', 'Ensure consistency'],
              dos: ['Experiment safely', 'Focus on comfort'],
              donts: ['Don\'t sacrifice form', 'Avoid unsafe positions'],
            ),
            UnitData(
              id: '12',
              name: 'Flight Drills',
              description: 'Practice flight techniques with specific exercises',
              objectives: ['Build confidence', 'Improve control'],
              dos: ['Start from low heights', 'Focus on form'],
              donts: ['Don\'t force positions', 'Avoid overthinking'],
            ),
          ],
        ),
        CourseSectionData(
          id: '4',
          title: 'Section 4: Landing Technique',
          description: 'Perfect the landing for maximum distance and safety',
          units: [
            UnitData(
              id: '13',
              name: 'Landing Preparation',
              description: 'Prepare for safe and effective landing',
              objectives: ['Position for landing', 'Control descent'],
              dos: ['Prepare arms for balance', 'Keep eyes forward'],
              donts: ['Don\'t land flat-footed', 'Avoid stiff legs'],
            ),
            UnitData(
              id: '14',
              name: 'Sand Pit Landing',
              description: 'Master landing technique in the sand pit',
              objectives: ['Land safely', 'Maximize distance'],
              dos: ['Bend knees on contact', 'Fall forward'],
              donts: ['Don\'t land on heels', 'Avoid sitting back'],
            ),
            UnitData(
              id: '15',
              name: 'Distance Optimization',
              description: 'Learn to land for maximum distance',
              objectives: ['Control forward momentum', 'Minimize energy loss'],
              dos: ['Lean forward', 'Keep moving after landing'],
              donts: ['Don\'t stop abruptly', 'Avoid backward movement'],
            ),
            UnitData(
              id: '16',
              name: 'Landing Drills',
              description: 'Practice landing with progressive difficulty',
              objectives: ['Build confidence', 'Perfect technique'],
              dos: ['Start from height', 'Focus on form'],
              donts: ['Don\'t skip safety', 'Avoid rushing progress'],
            ),
          ],
        ),
        CourseSectionData(
          id: '5',
          title: 'Section 5: Competition Preparation',
          description: 'Prepare mentally and physically for competition',
          units: [
            UnitData(
              id: '17',
              name: 'Competition Strategy',
              description: 'Develop competition tactics and mental preparation',
              objectives: ['Plan approach', 'Manage pressure'],
              dos: ['Visualize success', 'Stay focused'],
              donts: ['Don\'t overthink', 'Avoid negative thoughts'],
            ),
            UnitData(
              id: '18',
              name: 'Performance Analysis',
              description: 'Analyze performance and make improvements',
              objectives: ['Review technique', 'Identify weaknesses'],
              dos: ['Use video analysis', 'Track progress'],
              donts: ['Don\'t be too critical', 'Avoid comparison'],
            ),
            UnitData(
              id: '19',
              name: 'Injury Prevention',
              description: 'Learn to prevent common long jump injuries',
              objectives: ['Recognize risk factors', 'Implement prevention strategies'],
              dos: ['Warm up properly', 'Listen to body'],
              donts: ['Don\'t ignore pain', 'Avoid overtraining'],
            ),
            UnitData(
              id: '20',
              name: 'Competition Day',
              description: 'Final preparation and execution strategies',
              objectives: ['Optimize performance', 'Handle competition stress'],
              dos: ['Follow routine', 'Stay confident'],
              donts: ['Don\'t change technique', 'Avoid distractions'],
            ),
          ],
        ),
      ];
    } else if (courseId == '2') {
      // Javelin Throw Course Sections
      return [
        CourseSectionData(
          id: '1',
          title: 'Section 1: Grip and Stance',
          description: 'Master the fundamental grip and stance for javelin throwing',
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
          title: 'Section 2: Approach Run',
          description: 'Develop speed and rhythm in the approach run',
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
          title: 'Section 3: Throwing Technique',
          description: 'Master the throwing motion and release mechanics',
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
          title: 'Section 4: Strength and Conditioning',
          description: 'Build the strength and conditioning needed for javelin throwing',
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
          title: 'Section 5: Competition and Advanced Techniques',
          description: 'Prepare for competition and master advanced throwing techniques',
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
    } else if (courseId == '3') {
      // Hurdles Course Sections
      return [
        CourseSectionData(
          id: '1',
          title: 'Section 1: Hurdling Fundamentals',
          description: 'Master the basic techniques of hurdling',
          units: [
            UnitData(
              id: '1',
              name: 'Hurdle Clearance Basics',
              description: 'Learn the proper technique for clearing hurdles',
              objectives: ['Maintain proper form', 'Clear hurdles efficiently'],
              dos: ['Lead with the knee', 'Keep body upright'],
              donts: ['Don\'t knock down hurdles', 'Avoid leaning back'],
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