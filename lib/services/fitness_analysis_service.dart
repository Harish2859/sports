import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FitnessAnalysisService {
  static const String _baseUrl = 'http://localhost:8000';
  
  static Future<Map<String, dynamic>?> analyzeHeight({
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
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Height analysis error: $e');
      return null;
    }
  }

  static Future<bool> startPythonServer() async {
    try {
      // Start the Python height assessment server
      await Process.start(
        'python',
        ['python_reference/launcher.py', 'server'],
        workingDirectory: Directory.current.path,
      );
      
      // Wait a moment for server to start
      await Future.delayed(const Duration(seconds: 3));
      
      // Check if server is running
      final response = await http.get(Uri.parse('$_baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      print('Failed to start Python server: $e');
      return false;
    }
  }

  static Future<Process?> startFitnessTracker() async {
    try {
      // Start the Python fitness tracker
      final process = await Process.start(
        'python',
        ['python_reference/launcher.py', 'tracker'],
        workingDirectory: Directory.current.path,
      );
      return process;
    } catch (e) {
      print('Failed to start fitness tracker: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> loadAnalysisResults() async {
    try {
      final file = File('blazepose_outputs.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = jsonDecode(contents) as List;
        
        if (data.isNotEmpty) {
          final lastFrame = data.last;
          return {
            'sit_up_count': lastFrame['sit_up_count'] ?? 0,
            'form_score': lastFrame['form_score'] ?? 0.0,
            'score_out_of_10': lastFrame['score_out_of_10'] ?? 0.0,
            'estimated_height_cm': lastFrame['estimated_height_cm'] ?? 0.0,
            'total_frames': data.length,
            'analysis_complete': true,
          };
        }
      }
      return null;
    } catch (e) {
      print('Failed to load analysis results: $e');
      return null;
    }
  }
}