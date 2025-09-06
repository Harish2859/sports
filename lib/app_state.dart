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

  List<Course> get enrolledCourses => List.unmodifiable(_enrolledCourses);
  List<Course> get favoriteCourses => List.unmodifiable(_favoriteCourses);
  int get totalXP => _totalXP;

  void enrollInCourse(Course course) {
    if (!_enrolledCourses.any((c) => c.id == course.id)) {
      _enrolledCourses.add(course);
      notifyListeners();
    }
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
}