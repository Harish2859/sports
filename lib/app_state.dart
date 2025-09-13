import 'package:flutter/material.dart';
import 'course.dart';
import 'certificate_manager.dart';
import 'adminevents.dart' as admin;

class AppState extends ChangeNotifier {
  static AppState? _instance;
  static AppState get instance {
    _instance ??= AppState._internal();
    return _instance!;
  }
  factory AppState() => instance;
  AppState._internal();

  final List<Course> _enrolledCourses = [];
  final List<Course> _favoriteCourses = [];
  int _totalXP = 0; // Start with zero XP

  // User profile data
  String _userName = 'python';
  String _userGender = 'Male'; // Default gender
  String? _profileImagePath;

  // Streak data
  int _streakCount = 0;
  DateTime? _lastCompletionDate;

  // Course enrollments by gender: courseId -> gender -> list of usernames
  final Map<String, Map<String, List<String>>> _courseEnrollmentsByGender = {};

  List<Course> get enrolledCourses => List.unmodifiable(_enrolledCourses);
  List<Course> get favoriteCourses => List.unmodifiable(_favoriteCourses);
  int get totalXP => _totalXP;
  String get userName => _userName;
  String get userGender => _userGender;
  String? get profileImagePath => _profileImagePath;
  int get streakCount => _streakCount;
  DateTime? get lastCompletionDate => _lastCompletionDate;

  void enrollInCourse(Course course) {
    if (!_enrolledCourses.any((c) => c.id == course.id)) {
      _enrolledCourses.add(course);
      notifyListeners();
    }
  }

  void enrollInCourseWithGender(Course course, String userName, String gender) {
    if (!_enrolledCourses.any((c) => c.id == course.id)) {
      _enrolledCourses.add(course);

      // Track enrollment by gender
      _courseEnrollmentsByGender.putIfAbsent(course.id, () => {});
      _courseEnrollmentsByGender[course.id]!.putIfAbsent(gender, () => []);
      if (!_courseEnrollmentsByGender[course.id]![gender]!.contains(userName)) {
        _courseEnrollmentsByGender[course.id]![gender]!.add(userName);
      }

      notifyListeners();
    }
  }

  List<String> getEnrolledUsersByGender(String courseId, String gender) {
    return _courseEnrollmentsByGender[courseId]?[gender] ?? [];
  }

  Map<String, List<String>> getAllEnrollmentsByGender(String courseId) {
    return _courseEnrollmentsByGender[courseId] ?? {};
  }

  void addToFavorites(Course course) {
    if (!_favoriteCourses.any((c) => c.id == course.id)) {
      _favoriteCourses.add(course);
      notifyListeners();
    }
  }

  void removeFromFavorites(Course course) {
    _favoriteCourses.removeWhere((c) => c.id == course.id);
    notifyListeners();
  }

  bool isEnrolled(String courseId) {
    return _enrolledCourses.any((c) => c.id == courseId);
  }

  bool isFavorite(String courseId) {
    return _favoriteCourses.any((c) => c.id == courseId);
  }

  void addXP(int xp) {
    print('Adding $xp XP. Current: $_totalXP');
    _totalXP += xp;
    print('New total XP: $_totalXP');
    notifyListeners();
  }

  void updateUserProfile(String name, String gender) {
    _userName = name;
    _userGender = gender;
    notifyListeners();
  }

  void updateProfileImage(String imagePath) {
    _profileImagePath = imagePath;
    notifyListeners();
  }

  void updateUserGender(String gender) {
    _userGender = gender;
    notifyListeners();
  }

  // Course completion tracking
  final Map<String, bool> _completedCourses = {};

  bool isCourseCompleted(String courseId) {
    return _completedCourses[courseId] ?? false;
  }

  void completeCourse(String courseId, String courseTitle) {
    if (!_completedCourses.containsKey(courseId)) {
      _completedCourses[courseId] = true;

      // Generate certificate
      final certificateManager = CertificateManager();
      certificateManager.addCertificate(courseId, courseTitle, _userName);

      // Add XP for completion
      addXP(100);

      notifyListeners();
    }
  }

  // Event management
  final List<admin.Event> _events = [];

  List<admin.Event> get events => List.unmodifiable(_events);

  void addEvent(admin.Event event) {
    _events.add(event);
    notifyListeners();
  }

  void updateEvent(admin.Event updatedEvent) {
    final index = _events.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      _events[index] = updatedEvent;
      notifyListeners();
    }
  }

  void deleteEvent(String eventId) {
    _events.removeWhere((e) => e.id == eventId);
    notifyListeners();
  }

  admin.Event? getEventById(String eventId) {
    return _events.firstWhere((e) => e.id == eventId);
  }

  // Streak management
  void updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastCompletionDate == null) {
      _streakCount = 1;
      _lastCompletionDate = today;
    } else {
      final lastDate = DateTime(_lastCompletionDate!.year, _lastCompletionDate!.month, _lastCompletionDate!.day);
      final daysDifference = today.difference(lastDate).inDays;
      
      if (daysDifference == 1) {
        _streakCount++;
        _lastCompletionDate = today;
      } else if (daysDifference > 1) {
        _streakCount = 1;
        _lastCompletionDate = today;
      }
    }
    notifyListeners();
  }

  bool get isStreakActive {
    if (_lastCompletionDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(_lastCompletionDate!.year, _lastCompletionDate!.month, _lastCompletionDate!.day);
    return today.difference(lastDate).inDays <= 1;
  }

  // Gamification mode
  bool _isGamificationMode = false;
  bool get isGamificationMode => _isGamificationMode;

  void toggleGamificationMode() {
    _isGamificationMode = !_isGamificationMode;
    notifyListeners();
  }
}
