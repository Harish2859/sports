import 'package:flutter/material.dart';
import '../models/performance_model.dart';

class PerformanceCard extends StatelessWidget {
  final Performance performance;

  const PerformanceCard({Key? key, required this.performance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  performance.exerciseType.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getScoreColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getScoreColor()),
                  ),
                  child: Text(
                    '${performance.scoreOutOf10.toStringAsFixed(1)}/10',
                    style: TextStyle(
                      color: _getScoreColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.fitness_center, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Reps: ${performance.repCount}'),
                const SizedBox(width: 16),
                Icon(Icons.assessment, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Form: ${(performance.formScore * 100).toInt()}%'),
              ],
            ),
            const SizedBox(height: 8),
            if (performance.cheatDetected)
              Row(
                children: [
                  Icon(Icons.warning, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text('Cheat Detected', style: TextStyle(color: Colors.red)),
                ],
              ),
            Text(
              performance.timestamp.toString().split('.')[0],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor() {
    if (performance.scoreOutOf10 >= 8) return Colors.green;
    if (performance.scoreOutOf10 >= 6) return Colors.orange;
    return Colors.red;
  }
}