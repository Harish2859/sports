import 'package:flutter/material.dart';
import 'course.dart';

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
  String _userName = 'Alex Rodriguez';
  String _userGender = 'Male'; // Default gender

  // Course enrollments by gender: courseId -> gender -> list of usernames
  final Map<String, Map<String, List<String>>> _courseEnrollmentsByGender = {};

  List<Course> get enrolledCourses => List.unmodifiable(_enrolledCourses);
  List<Course> get favoriteCourses => List.unmodifiable(_favoriteCourses);
  int get totalXP => _totalXP;
  String get userName => _userName;
  String get userGender => _userGender;

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

  void updateUserGender(String gender) {
    _userGender = gender;
    notifyListeners();
  }
}
