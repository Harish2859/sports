import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'course.dart';
import 'main_layout.dart';
import 'gotocourse.dart';
import 'leaderboard.dart';
import 'achievement.dart';
import 'certificate.dart';
import 'certificate_manager.dart';
import 'theme_provider.dart';
import 'performance_videos_page.dart';
import 'performance_videos_manager.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final AppState _appState = AppState.instance;

  @override
  void initState() {
    super.initState();
    _appState.addListener(_onAppStateChanged);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _onAppStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _appState.removeListener(_onAppStateChanged);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

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
      child: Scaffold(
        backgroundColor: themeProvider.isGamified ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildProfileHeader(isDarkMode),
                const SizedBox(height: 20),
                _buildStatsCards(isDarkMode),
                const SizedBox(height: 20),
                _buildXPCard(),
                const SizedBox(height: 20),
                _buildActionButtons(isDarkMode),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDarkMode) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeProvider.isGamified ? Colors.white.withOpacity(0.1) : Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.person, size: 50, color: Colors.blue[800]),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _editProfile,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _appState.userName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeProvider.isGamified ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            '@alex_sports_pro',
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.isGamified ? Colors.white70 : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Gender: ${_appState.userGender}',
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber[800], size: 16),
                const SizedBox(width: 4),
                Text(
                  'Pro Level',
                  style: TextStyle(
                    color: Colors.amber[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isDarkMode) {
    final int totalXP = _appState.totalXP;
    final bool hasBeginnerBadge = totalXP >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Videos Watched', '127', Icons.play_circle_outline, Colors.blue, isDarkMode)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Skill Rating', '8.7/10', Icons.trending_up, Colors.green, isDarkMode)),
          const SizedBox(width: 12),
          Expanded(child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AchievementsPage())),
            child: hasBeginnerBadge ? _buildBadgeStatCard(isDarkMode) : _buildStatCard('Achievements', '0', Icons.emoji_events, Colors.orange, isDarkMode),
          )),
        ],
      ),
    );
  }

  Widget _buildXPCard() {
    final int totalXP = _appState.totalXP;
    final String currentLeague = _getLeague(totalXP);
    final Map<String, dynamic> leagueInfo = _getLeagueInfo(currentLeague);
    final int nextLeagueXP = _getNextLeagueXP(currentLeague);
    final int currentLeagueMinXP = _getLeagueMinXP(currentLeague);
    final double progress = nextLeagueXP > 0 ? (totalXP - currentLeagueMinXP) / (nextLeagueXP - currentLeagueMinXP) : 1.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: leagueInfo['colors'],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: leagueInfo['colors'][0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'XP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total Experience Points',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(leagueInfo['icon'], color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      currentLeague,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (nextLeagueXP > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Progress to next league',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(nextLeagueXP - totalXP)} XP to next league',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _getLeague(int xp) {
    if (xp >= 5000) return 'Champion';
    if (xp >= 3000) return 'Expert';
    if (xp >= 1500) return 'Advanced';
    if (xp >= 500) return 'Intermediate';
    return 'Beginner';
  }

  Map<String, dynamic> _getLeagueInfo(String league) {
    switch (league) {
      case 'Champion':
        return {
          'colors': [const Color(0xFFFFD700), const Color(0xFFFFA500)],
          'icon': Icons.emoji_events,
        };
      case 'Expert':
        return {
          'colors': [const Color(0xFF9C27B0), const Color(0xFF673AB7)],
          'icon': Icons.star,
        };
      case 'Advanced':
        return {
          'colors': [const Color(0xFF2196F3), const Color(0xFF3F51B5)],
          'icon': Icons.trending_up,
        };
      case 'Intermediate':
        return {
          'colors': [const Color(0xFF4CAF50), const Color(0xFF388E3C)],
          'icon': Icons.school,
        };
      default:
        return {
          'colors': [const Color(0xFF9E9E9E), const Color(0xFF616161)],
          'icon': Icons.sports,
        };
    }
  }

  int _getNextLeagueXP(String currentLeague) {
    switch (currentLeague) {
      case 'Beginner': return 500;
      case 'Intermediate': return 1500;
      case 'Advanced': return 3000;
      case 'Expert': return 5000;
      default: return 0;
    }
  }

  int _getLeagueMinXP(String currentLeague) {
    switch (currentLeague) {
      case 'Beginner': return 0;
      case 'Intermediate': return 500;
      case 'Advanced': return 1500;
      case 'Expert': return 3000;
      case 'Champion': return 5000;
      default: return 0;
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDarkMode) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isGamified ? Colors.white.withOpacity(0.1) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.isGamified ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.isGamified ? Colors.white70 : Theme.of(context).textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeStatCard(bool isDarkMode) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isGamified ? Colors.white.withOpacity(0.1) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.orange,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '1',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.isGamified ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            'Achievements',
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.isGamified ? Colors.white70 : Theme.of(context).textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDarkMode) {
    final videosManager = PerformanceVideosManager();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'My Courses',
                  Icons.school_outlined,
                  Colors.blue[600]!,
                  () => _navigateToCourses(),
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Your Performance',
                  Icons.videocam_outlined,
                  Colors.red[600]!,
                  () => _navigateToPerformanceVideos(),
                  isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'My Certificates',
                  Icons.card_membership_outlined,
                  Colors.purple[600]!,
                  () => _navigateToCertificates(),
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Leaderboard',
                  Icons.leaderboard,
                  Colors.orange[600]!,
                  () => _navigateToLeaderboard(),
                  isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Leaderboard',
                Icons.leaderboard,
                Colors.orange[600]!,
                () => _navigateToLeaderboard(),
                isDarkMode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Favorites',
                Icons.favorite_outline,
                Colors.red[600]!,
                () => _navigateToFavorites(),
                isDarkMode,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    ),
  );
}

  Widget _buildRecordPerformanceCard(bool isDarkMode, bool hasVideos) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return _buildActionButton(
      'Your Performance',
      Icons.videocam_outlined,
      Colors.red[600]!,
      () => _navigateToPerformanceVideos(),
      isDarkMode,
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap, bool isDarkMode) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? color.withOpacity(0.2) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  // Navigation methods
  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Profile clicked')),
    );
  }

  void _navigateToCourses() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyCoursesPage()),
    );
  }

  void _navigateToCertificates() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyCertificatesPage()),
    );
  }

  void _uploadVideo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upload Video clicked')),
    );
  }

  void _navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoritesPage()),
    );
  }

  void _navigateToSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings clicked')),
    );
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications clicked')),
    );
  }

  void _navigateToLeaderboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LeaderboardPage()),
    );
  }

  void _navigateToPerformanceVideos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PerformanceVideosPage()),
    );
  }
}

// Enrolled courses page
class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState appState = AppState.instance;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return MainLayout(
      currentIndex: 4, // Profile tab
      onTabChanged: (index) {
        if (index != 4) {
          Navigator.pop(context);
        }
      },
      child: Container(
        decoration: themeProvider.isGamified
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1a237e), Color(0xFF000000)],
                ),
              )
            : null,
        child: Scaffold(
          backgroundColor: themeProvider.isGamified ? Colors.transparent : null,
        body: appState.enrolledCourses.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No enrolled courses yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: appState.enrolledCourses.length,
                itemBuilder: (context, index) {
                  final course = appState.enrolledCourses[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: themeProvider.isGamified ? Colors.white.withOpacity(0.1) : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isGamified ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          course.summary,
                          style: TextStyle(color: themeProvider.isGamified ? Colors.white70 : Theme.of(context).textTheme.bodyMedium?.color),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: 0.3,
                          backgroundColor: themeProvider.isGamified ? Colors.white.withOpacity(0.2) : (isDarkMode ? Colors.grey[700] : Colors.grey[200]),
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '30% Complete',
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GotoCoursePage(courseName: course.title),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Go to Course'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      )
      ),
    );
  }
}

// Favorites page
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState appState = AppState.instance;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return MainLayout(
      currentIndex: 4, // Profile tab
      onTabChanged: (index) {
        if (index != 4) {
          Navigator.pop(context);
        }
      },
      child: Container(
        decoration: themeProvider.isGamified
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1a237e), Color(0xFF000000)],
                ),
              )
            : null,
        child: Scaffold(
          backgroundColor: themeProvider.isGamified ? Colors.transparent : null,
        body: appState.favoriteCourses.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_outline, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No favorite courses yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: appState.favoriteCourses.length,
                itemBuilder: (context, index) {
                  final course = appState.favoriteCourses[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: themeProvider.isGamified ? Colors.white.withOpacity(0.1) : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.school, color: Colors.blue[600]),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.isGamified ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                course.instructor,
                                style: TextStyle(color: themeProvider.isGamified ? Colors.white70 : Theme.of(context).textTheme.bodyMedium?.color),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.favorite, color: Colors.red[600]),
                          onPressed: () {
                            appState.removeFromFavorites(course);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Removed from favorites')),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      )
      ),
    );
  }
}

class MyCertificatesPage extends StatelessWidget {
  const MyCertificatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final certificateManager = CertificateManager();
    final certificates = certificateManager.certificates;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return MainLayout(
      currentIndex: 4, // Profile tab
      onTabChanged: (index) {
        if (index != 4) {
          Navigator.pop(context);
        }
      },
      child: Container(
        decoration: themeProvider.isGamified
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1a237e), Color(0xFF000000)],
                ),
              )
            : null,
        child: Scaffold(
          backgroundColor: themeProvider.isGamified ? Colors.transparent : null,
          body: certificates.isEmpty
          ? Center(
              child: Text(
                'No certificates earned yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: certificates.length,
              itemBuilder: (context, index) {
                final cert = certificates[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.deepPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.card_membership, color: Colors.white, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              cert.courseTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Issued by Fair Play Academy',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Completed on: ${cert.completionDate.day}/${cert.completionDate.month}/${cert.completionDate.year}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Certificate ID: ${cert.id}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // TODO: Implement share functionality
                            },
                            icon: const Icon(Icons.share, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ),
      ),
    );
  }
}