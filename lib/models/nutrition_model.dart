class AthleteProfile {
  final String id;
  final String name;
  final String sport;
  final double weight;
  final double height;
  final int age;
  final String trainingGoal;
  final String? photoUrl;

  AthleteProfile({
    required this.id,
    required this.name,
    required this.sport,
    required this.weight,
    required this.height,
    required this.age,
    required this.trainingGoal,
    this.photoUrl,
  });
}

class NutritionSuggestion {
  final String id;
  final String query;
  final String foodName;
  final String portionSize;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String reason;
  final DateTime timestamp;
  bool isSaved;
  bool isLiked;

  NutritionSuggestion({
    required this.id,
    required this.query,
    required this.foodName,
    required this.portionSize,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.reason,
    required this.timestamp,
    this.isSaved = false,
    this.isLiked = false,
  });
}

class LocationContext {
  final String city;
  final String country;
  final String climate;
  final List<String> localFoods;
  final bool isAutoDetected;

  LocationContext({
    required this.city,
    required this.country,
    required this.climate,
    required this.localFoods,
    this.isAutoDetected = false,
  });
}