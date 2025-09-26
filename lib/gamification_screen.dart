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
    const int xpPerLevel = 100;
    final int currentLevelXP = totalXP % xpPerLevel;
    final double progress = currentLevelXP / xpPerLevel;
    final int xpToNextLevel = xpPerLevel - currentLevelXP;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[800]!, Colors.grey[850]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.star_rounded, color: Colors.amber[400], size: 28),
                ),
                const SizedBox(width: 12),
                Text(
                  'Level $level',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Total XP: $totalXP',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 20,
                    backgroundColor: Colors.black.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[400]!),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      '$currentLevelXP / $xpPerLevel XP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 2),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$xpToNextLevel XP to next level',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[400],
                ),
              ),
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