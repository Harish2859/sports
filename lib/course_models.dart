import 'package:flutter/material.dart';

enum UnitStatus { completed, inProgress, notStarted }

class Unit {
  final String title;
  final String description;
  final UnitStatus status;
  final IconData icon;

  Unit(this.title, this.description, this.status, this.icon);
}

class CourseSection {
  final String title;
  final String description;
  final double progress;
  final Color color;

  CourseSection({
    required this.title,
    required this.description,
    required this.progress,
    required this.color,
  });
}
