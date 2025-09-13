import 'package:flutter/material.dart';
import 'bid_model.dart';
import 'models/performance_model.dart';
import 'services/performance_service.dart';
import 'widgets/performance_card.dart';

class PerformanceBidScreen extends StatelessWidget {
  final Bid bid;

  const PerformanceBidScreen({Key? key, required this.bid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final performances = PerformanceService.getAllPerformances();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Performance Bid'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bid.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(bid.description),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Amount: \$${bid.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      if (bid.requiredScore != null)
                        Text(
                          'Required Score: ${bid.requiredScore!.toStringAsFixed(1)}/10',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: performances.isEmpty
                ? const Center(child: Text('No performance data available'))
                : ListView.builder(
                    itemCount: performances.length,
                    itemBuilder: (context, index) {
                      return PerformanceCard(performance: performances[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startPerformanceTest(context),
        child: const Icon(Icons.play_arrow),
      ),
    );
  }

  void _startPerformanceTest(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Performance Test'),
        content: const Text('This would launch the camera-based performance analysis'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Integration point for camera-based analysis
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}