import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../widgets/video_recorder.dart';
import '../widgets/analysis_results_widget.dart';
import '../services/fitness_analysis_service.dart';
import '../main.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  String? _videoPath;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResults;

  void _onVideoSaved(String videoPath) {
    setState(() {
      _videoPath = videoPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cameras.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Standard Assessment'),
        ),
        body: const Center(
          child: Text(
            'No camera available',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Standard Assessment'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Standard Assessment',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Record your assessment video for evaluation',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            VideoRecorder(
              title: 'Standard Assessment',
              description: 'Record your performance with full body visible. Ensure good lighting and clear view of your movements.',
              camera: cameras.first,
              onVideoSaved: _onVideoSaved,
            ),
            
            if (_videoPath != null) ...[
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assessment Options',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        const Text('Video recorded successfully'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isAnalyzing ? null : _startKivyAssessment,
                            icon: _isAnalyzing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.analytics),
                            label: Text(_isAnalyzing ? 'Analyzing...' : 'Take Assessment'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Assessment submitted!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            icon: const Icon(Icons.upload),
                            label: const Text('Submit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            
            if (_analysisResults != null)
              AnalysisResultsWidget(
                results: _analysisResults!,
                heightAnalysis: null,
              ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _startKivyAssessment() async {
    setState(() => _isAnalyzing = true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mock assessment started (5 seconds for testing)'),
        backgroundColor: Colors.blue,
      ),
    );
    
    await Future.delayed(const Duration(seconds: 5));
    
    final mockResults = {
      'sit_up_count': 8,
      'form_score': 0.75,
      'score_out_of_10': 7.5,
      'estimated_height_cm': 165.0,
      'total_frames': 1800,
      'analysis_complete': true,
    };
    
    setState(() {
      _analysisResults = mockResults;
      _isAnalyzing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mock assessment completed! Results loaded.'),
        backgroundColor: Colors.green,
      ),
    );
  }
}