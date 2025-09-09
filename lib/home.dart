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
            // Sports News Header
            Text(
              'Sports News',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeProvider.isGamified ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Featured News
            _buildNewsCard(
              context,
              'Champions League Final Set for This Weekend',
              'The biggest match of the season approaches as two powerhouse teams prepare for the ultimate showdown.',
              '2 hours ago',
              Icons.sports_soccer,
            ),

            const SizedBox(height: 12),

            _buildNewsCard(
              context,
              'Olympic Training Camp Opens',
              'Athletes from around the world gather for intensive preparation ahead of the upcoming games.',
              '4 hours ago',
              Icons.sports_gymnastics,
            ),

            const SizedBox(height: 12),

            _buildNewsCard(
              context,
              'Basketball Season Playoffs Begin',
              'Top teams advance to the playoff rounds with exciting matchups scheduled throughout the month.',
              '6 hours ago',
              Icons.sports_basketball,
            ),

            const SizedBox(height: 12),

            _buildNewsCard(
              context,
              'Tennis Championship Results',
              'Surprising upsets and stellar performances mark the latest tournament rounds.',
              '8 hours ago',
              Icons.sports_tennis,
            ),

            const SizedBox(height: 12),

            _buildNewsCard(
              context,
              'Swimming Records Broken',
              'New world records set at the international swimming competition this week.',
              '1 day ago',
              Icons.pool,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, String title, String description, String time, IconData icon) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isGamified ? Colors.white.withOpacity(0.1) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: themeProvider.isGamified ? Border.all(color: Colors.white.withOpacity(0.2), width: 1) : Border.all(color: Colors.transparent, width: 0),
        boxShadow: themeProvider.isGamified ? [] : [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
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
              icon,
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
                    color: themeProvider.isGamified 
                        ? Colors.white 
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.isGamified 
                        ? Colors.white70 
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.isGamified 
                  ? Colors.white70 
                  : Theme.of(context).textTheme.bodySmall?.color,
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



