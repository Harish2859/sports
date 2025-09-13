class FraudUser {
  final String id;
  final String name;
  final String email;
  final int fraudCount;
  final String lastVideoPath;
  final DateTime lastFraudDate;
  final bool isBanned;

  FraudUser({
    required this.id,
    required this.name,
    required this.email,
    required this.fraudCount,
    required this.lastVideoPath,
    required this.lastFraudDate,
    this.isBanned = false,
  });

  factory FraudUser.fromJson(Map<String, dynamic> json) {
    return FraudUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      fraudCount: json['fraudCount'],
      lastVideoPath: json['lastVideoPath'],
      lastFraudDate: DateTime.parse(json['lastFraudDate']),
      isBanned: json['isBanned'] ?? false,
    );
  }
}

class LeaderboardUser {
  final String id;
  final String name;
  final String gender;
  final int score;
  final String profileImage;

  LeaderboardUser({
    required this.id,
    required this.name,
    required this.gender,
    required this.score,
    required this.profileImage,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      id: json['id'],
      name: json['name'],
      gender: json['gender'],
      score: json['score'],
      profileImage: json['profileImage'] ?? '',
    );
  }
}