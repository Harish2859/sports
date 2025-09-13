import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class HeightAssessmentService {
  static const String _baseUrl = 'http://localhost:8000'; // Python server URL
  
  /// Send height data to Python model for standard assessment
  static Future<HeightAssessmentResult> analyzeHeight({
    required double estimatedHeight,
    required List<double> heightEstimates,
    required int age,
    required String gender,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze_height'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'estimated_height': estimatedHeight,
          'height_estimates': heightEstimates,
          'age': age,
          'gender': gender,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return HeightAssessmentResult.fromJson(data);
      } else {
        throw Exception('Failed to analyze height: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to local assessment if server is unavailable
      return _performLocalAssessment(estimatedHeight, age, gender);
    }
  }

  /// Local fallback assessment based on standard height charts
  static HeightAssessmentResult _performLocalAssessment(
    double height, 
    int age, 
    String gender
  ) {
    // Standard height percentiles (simplified)
    final Map<String, Map<int, List<double>>> heightStandards = {
      'male': {
        18: [160.0, 170.0, 175.0, 180.0, 185.0], // 5th, 25th, 50th, 75th, 95th percentiles
        25: [162.0, 172.0, 177.0, 182.0, 187.0],
        30: [162.0, 172.0, 177.0, 182.0, 187.0],
      },
      'female': {
        18: [150.0, 160.0, 165.0, 170.0, 175.0],
        25: [152.0, 162.0, 167.0, 172.0, 177.0],
        30: [152.0, 162.0, 167.0, 172.0, 177.0],
      },
    };

    final standards = heightStandards[gender.toLowerCase()] ?? heightStandards['male']!;
    final ageGroup = age <= 20 ? 18 : (age <= 27 ? 25 : 30);
    final percentiles = standards[ageGroup] ?? standards[25]!;

    String category;
    double percentile;
    
    if (height < percentiles[0]) {
      category = 'Below Average';
      percentile = 5.0;
    } else if (height < percentiles[1]) {
      category = 'Below Average';
      percentile = 15.0;
    } else if (height < percentiles[2]) {
      category = 'Average';
      percentile = 37.5;
    } else if (height < percentiles[3]) {
      category = 'Average';
      percentile = 62.5;
    } else if (height < percentiles[4]) {
      category = 'Above Average';
      percentile = 85.0;
    } else {
      category = 'Above Average';
      percentile = 95.0;
    }

    return HeightAssessmentResult(
      estimatedHeight: height,
      category: category,
      percentile: percentile,
      isHealthy: percentile >= 10.0 && percentile <= 90.0,
      recommendations: _getRecommendations(category, height, age, gender),
      confidence: 0.85, // Local assessment confidence
    );
  }

  static List<String> _getRecommendations(
    String category, 
    double height, 
    int age, 
    String gender
  ) {
    List<String> recommendations = [];
    
    if (category == 'Below Average') {
      recommendations.addAll([
        'Ensure adequate nutrition with protein-rich foods',
        'Maintain good posture throughout the day',
        'Consider consulting a healthcare provider if concerned',
        'Focus on bone health with calcium and vitamin D',
      ]);
    } else if (category == 'Above Average') {
      recommendations.addAll([
        'Maintain good posture to prevent back issues',
        'Ensure proper ergonomics in workspace',
        'Stay active with appropriate exercises',
      ]);
    } else {
      recommendations.addAll([
        'Maintain current healthy lifestyle',
        'Continue balanced nutrition',
        'Stay physically active',
      ]);
    }

    return recommendations;
  }
}

class HeightAssessmentResult {
  final double estimatedHeight;
  final String category;
  final double percentile;
  final bool isHealthy;
  final List<String> recommendations;
  final double confidence;

  HeightAssessmentResult({
    required this.estimatedHeight,
    required this.category,
    required this.percentile,
    required this.isHealthy,
    required this.recommendations,
    required this.confidence,
  });

  factory HeightAssessmentResult.fromJson(Map<String, dynamic> json) {
    return HeightAssessmentResult(
      estimatedHeight: json['estimated_height']?.toDouble() ?? 0.0,
      category: json['category'] ?? 'Unknown',
      percentile: json['percentile']?.toDouble() ?? 0.0,
      isHealthy: json['is_healthy'] ?? false,
      recommendations: List<String>.from(json['recommendations'] ?? []),
      confidence: json['confidence']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estimated_height': estimatedHeight,
      'category': category,
      'percentile': percentile,
      'is_healthy': isHealthy,
      'recommendations': recommendations,
      'confidence': confidence,
    };
  }
}