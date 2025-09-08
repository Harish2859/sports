import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'course.dart';
import 'profile.dart';
import 'explore.dart';
import 'main_layout.dart';
import 'event.dart';
import 'theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Pages for each tab
  List<Widget> get _pages => [
    const HomeContent(),
    ExplorePage(),
    const SportsEventPage(),
    const CoursePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: _currentIndex,
      onTabChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      child: _pages[_currentIndex],
    );
  }
}



// Home Content Widget
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      decoration: themeProvider.isGamified
          ? const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1a237e), Color(0xFF000000)],
              ),
            )
          : null,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isGamified ? Colors.white : Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Find the perfect talent for your needs',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Actions Section
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.isGamified ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.search,
                  title: 'Find Talent',
                  subtitle: 'Search for professionals',
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.work_outline,
                  title: 'Post Job',
                  subtitle: 'Create job posting',
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent Activity Section
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.isGamified ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildActivityCard(
            context,
            'New application received',
            'John Doe applied for Frontend Developer position',
            '2 hours ago',
          ),

          const SizedBox(height: 12),

          _buildActivityCard(
            context,
            'Interview scheduled',
            'Meeting with Sarah Johnson tomorrow at 2 PM',
            '1 day ago',
          ),

          const SizedBox(height: 12),

          _buildActivityCard(
            context,
            'Profile view',
            'Your profile was viewed by 5 recruiters',
            '2 days ago',
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, String title, String description, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}



// Add Page
class AddPage extends StatelessWidget {
  const AddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle,
            size: 64,
            color: Color(0xFF2563EB),
          ),
          SizedBox(height: 16),
          Text(
            'Create New',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add new job postings or content',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}



