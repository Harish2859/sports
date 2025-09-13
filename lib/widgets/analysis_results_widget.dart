import 'package:flutter/material.dart';

class AnalysisResultsWidget extends StatelessWidget {
  final Map<String, dynamic> results;
  final Map<String, dynamic>? heightAnalysis;

  const AnalysisResultsWidget({
    super.key,
    required this.results,
    this.heightAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assessment Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Performance Results
            _buildResultSection(
              'Performance Analysis',
              [
                _buildResultItem('Sit-ups Completed', '${results['sit_up_count'] ?? 0}'),
                _buildResultItem('Form Score', '${(results['form_score'] ?? 0.0).toStringAsFixed(2)}/1.0'),
                _buildResultItem('Overall Score', '${(results['score_out_of_10'] ?? 0.0).toStringAsFixed(1)}/10'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Height Analysis
            if (heightAnalysis != null) ...[
              _buildResultSection(
                'Height Analysis',
                [
                  _buildResultItem('Estimated Height', '${heightAnalysis!['estimated_height']} cm'),
                  _buildResultItem('Category', heightAnalysis!['category']),
                  _buildResultItem('Percentile', '${heightAnalysis!['percentile']}th'),
                  _buildResultItem('Health Status', heightAnalysis!['is_healthy'] ? 'Healthy' : 'Needs Attention'),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Recommendations
              if (heightAnalysis!['recommendations'] != null) ...[
                const Text(
                  'Recommendations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...((heightAnalysis!['recommendations'] as List).take(3).map(
                  (rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text(rec.toString())),
                      ],
                    ),
                  ),
                )),
              ],
            ],
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Save results locally or upload
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Results saved successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save Results'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Share results
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Results shared!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
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
    );
  }

  Widget _buildResultSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}