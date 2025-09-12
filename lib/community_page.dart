import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: isDarkMode ? Colors.grey[800] : null,
        foregroundColor: isDarkMode ? Colors.white : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCommunityCard(
            'Sports Discussion',
            'Join discussions about various sports',
            Icons.sports,
            Colors.blue,
            isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildCommunityCard(
            'Training Tips',
            'Share and learn training techniques',
            Icons.fitness_center,
            Colors.green,
            isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildCommunityCard(
            'Events & Competitions',
            'Stay updated on upcoming events',
            Icons.event,
            Colors.orange,
            isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildCommunityCard(
            'Success Stories',
            'Celebrate achievements together',
            Icons.emoji_events,
            Colors.purple,
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityCard(String title, String subtitle, IconData icon, Color color, bool isDarkMode) {
    return Card(
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isDarkMode ? Colors.white54 : Colors.grey,
        ),
        onTap: () {
          // Handle community section tap
        },
      ),
    );
  }
}