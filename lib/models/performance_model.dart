class Performance {
  final String id;
  final String userId;
  final String exerciseType;
  final int repCount;
  final double formScore;
  final double scoreOutOf10;
  final double estimatedHeight;
  final DateTime timestamp;
  final List<Map<String, dynamic>> keypoints;
  final bool cheatDetected;

  Performance({
    required this.id,
    required this.userId,
    required this.exerciseType,
    required this.repCount,
    required this.formScore,
    required this.scoreOutOf10,
    required this.estimatedHeight,
    required this.timestamp,
    required this.keypoints,
    this.cheatDetected = false,
  });

  factory Performance.fromJson(Map<String, dynamic> json) {
    return Performance(
      id: json['id'],
      userId: json['userId'],
      exerciseType: json['exerciseType'],
      repCount: json['repCount'],
      formScore: json['formScore'].toDouble(),
      scoreOutOf10: json['scoreOutOf10'].toDouble(),
      estimatedHeight: json['estimatedHeight'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      keypoints: List<Map<String, dynamic>>.from(json['keypoints']),
      cheatDetected: json['cheatDetected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'exerciseType': exerciseType,
      'repCount': repCount,
      'formScore': formScore,
      'scoreOutOf10': scoreOutOf10,
      'estimatedHeight': estimatedHeight,
      'timestamp': timestamp.toIso8601String(),
      'keypoints': keypoints,
      'cheatDetected': cheatDetected,
    };
  }
}