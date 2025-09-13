import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gamification'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final level = (appState.totalXP / 100).floor() + 1;
          final streakCount = appState.streakCount;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLevelCard(level, appState.totalXP),
                const SizedBox(height: 16),
                _buildStreakCard(streakCount, appState.isStreakActive),
                const SizedBox(height: 16),
                _buildAchievementsCard(appState.totalXP),
                const SizedBox(height: 16),
                _buildRewardsCard(level),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelCard(int level, int totalXP) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Level $level',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Total XP: $totalXP', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (totalXP % 100) / 100,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(int streakCount, bool isActive) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department,
              color: isActive ? Colors.orange : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streakCount Day Streak',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  isActive ? 'Keep it up!' : 'Start your streak today!',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsCard(int totalXP) {
    final achievements = [
      {'name': 'First Steps', 'desc': 'Complete first task', 'unlocked': totalXP >= 10},
      {'name': 'Dedicated', 'desc': '7-day streak', 'unlocked': totalXP >= 50},
      {'name': 'Champion', 'desc': 'Reach level 5', 'unlocked': totalXP >= 500},
    ];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Achievements',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...achievements.map((achievement) => ListTile(
              leading: Icon(
                achievement['unlocked'] as bool ? Icons.emoji_events : Icons.lock,
                color: achievement['unlocked'] as bool ? Colors.amber : Colors.grey,
              ),
              title: Text(achievement['name'] as String),
              subtitle: Text(achievement['desc'] as String),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsCard(int level) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Level Rewards',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Current Level: $level'),
            const SizedBox(height: 8),
            Text('Next Reward at Level ${level + 1}:'),
            const SizedBox(height: 4),
            Text('🏆 Special Badge', style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}