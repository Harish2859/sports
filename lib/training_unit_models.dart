import 'package:flutter/material.dart';

enum UnitStage { overview, recording, analysis, results, completed }

class TrainingUnit {
  final String name;
  final String description;
  final List<String> dos;
  final List<String> donts;
  final IconData icon;
  final Color color;

  TrainingUnit({
    required this.name,
    required this.description,
    required this.dos,
    required this.donts,
    required this.icon,
    required this.color,
  });
}