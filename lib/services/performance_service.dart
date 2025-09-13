import '../models/performance_model.dart';

class PerformanceService {
  static final List<Performance> _performances = [];

  static List<Performance> getAllPerformances() => List.from(_performances);

  static void addPerformance(Performance performance) => _performances.add(performance);

  static List<Performance> getPerformancesByUser(String userId) =>
      _performances.where((p) => p.userId == userId).toList();

  static List<Performance> getPerformancesByExercise(String exerciseType) =>
      _performances.where((p) => p.exerciseType == exerciseType).toList();

  static double getAverageScore(String userId) {
    final userPerformances = getPerformancesByUser(userId);
    if (userPerformances.isEmpty) return 0.0;
    return userPerformances.map((p) => p.scoreOutOf10).reduce((a, b) => a + b) / userPerformances.length;
  }
}