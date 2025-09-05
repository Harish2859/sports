import 'package:flutter/material.dart';
import 'course.dart';

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  final List<Course> _enrolledCourses = [];
  final List<Course> _favoriteCourses = [];

  List<Course> get enrolledCourses => List.unmodifiable(_enrolledCourses);
  List<Course> get favoriteCourses => List.unmodifiable(_favoriteCourses);

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
}