import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
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
import 'my_certificates_page.dart';
import 'favorites_page.dart';
import 'post_manager.dart';
import 'post_upload_page.dart';
import 'performance_upload_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _breathingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _breathingAnimation;
  final AppState _appState = AppState.instance;
  final PostManager _postManager = PostManager();
  final PerformanceVideosManager _videosManager = PerformanceVideosManager();

  // Lifecycle Methods
  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _appState.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    _appState.removeListener(_onAppStateChanged);
    _animationController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  // Private Methods
  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _breathingAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  void _onAppStateChanged() {
    if (mounted) setState(() {});
  }

  // Main Build Method
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      decoration: _buildBackgroundDecoration(themeProvider),
      child: Scaffold(
        backgroundColor: themeProvider.isGamified ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: _buildProfileContent(isDarkMode),
          ),
        ),
      ),
    );
  }

  // UI Building Methods
  BoxDecoration? _buildBackgroundDecoration(ThemeProvider themeProvider) {
    return themeProvider.isGamified
        ? const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1a237e), Color(0xFF000000)],
            ),
          )
        : null;
  }

  Widget _buildProfileContent(bool isDarkMode) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isGamified = themeProvider.isGamified;

    return DefaultTabController(
      length: 2,
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
          TabBar(
            tabs: [
              Tab(
                child: Text(
                  'Posts',
                  style: TextStyle(
                    color: isGamified ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Performance',
                  style: TextStyle(
                    color: isGamified ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 2000, // Increased height to support up to 10 rows of posts
            child: TabBarView(
              children: [
                _buildPostSection(),
                _buildPerformanceSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isDarkMode) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Picture with Badge Overlay
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue[100],
                backgroundImage: _appState.profileImagePath != null
                    ? FileImage(File(_appState.profileImagePath!))
                    : null,
                child: _appState.profileImagePath == null
                    ? Icon(Icons.person, size: 50, color: Colors.blue[800])
                    : null,
              ),
              // Animated Badge at top right
              Positioned(
                top: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _breathingAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _breathingAnimation.value,
                      child: Container(
                        width: 40,
                        height: 40,
                        child: Image.asset(
                          'assets/images/champ.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.emoji_events, color: Colors.amber, size: 30);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Edit button at bottom right
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
          const SizedBox(width: 24),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          Expanded(
            child: _buildStatCard(
              'test taken', 
              '5', 
              Icons.play_circle_outline, 
              Colors.blue, 
              isDarkMode
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Skill Rating', 
              '8.7/10', 
              Icons.trending_up, 
              Colors.green, 
              isDarkMode
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToAchievements(),
              child: hasBeginnerBadge 
                  ? _buildBadgeStatCard(isDarkMode) 
                  : _buildStatCard('Achievement', '0', Icons.emoji_events, Colors.orange, isDarkMode),
            ),
          ),
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

  // League System Helper Methods
  String _getLeague(int xp) {
    if (xp >= 5000) return 'Champion';
    if (xp >= 3000) return 'Expert';
    if (xp >= 1500) return 'Advanced';
    if (xp >= 500) return 'Intermediate';
    return 'Beginner';
  }

  Map<String, dynamic> _getLeagueInfo(String league) {
    const leagueData = {
      'Champion': {
        'colors': [Color(0xFFFFD700), Color(0xFFFFA500)],
        'icon': Icons.emoji_events,
      },
      'Expert': {
        'colors': [Color(0xFF9C27B0), Color(0xFF673AB7)],
        'icon': Icons.star,
      },
      'Advanced': {
        'colors': [Color(0xFF2196F3), Color(0xFF3F51B5)],
        'icon': Icons.trending_up,
      },
      'Intermediate': {
        'colors': [Color(0xFF4CAF50), Color(0xFF388E3C)],
        'icon': Icons.school,
      },
    };
    
    return leagueData[league] ?? {
      'colors': [const Color(0xFF9E9E9E), const Color(0xFF616161)],
      'icon': Icons.sports,
    };
  }

  int _getNextLeagueXP(String currentLeague) {
    const xpThresholds = {
      'Beginner': 500,
      'Intermediate': 1500,
      'Advanced': 3000,
      'Expert': 5000,
    };
    return xpThresholds[currentLeague] ?? 0;
  }

  int _getLeagueMinXP(String currentLeague) {
    const minXpThresholds = {
      'Beginner': 0,
      'Intermediate': 500,
      'Advanced': 1500,
      'Expert': 3000,
      'Champion': 5000,
    };
    return minXpThresholds[currentLeague] ?? 0;
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
          Icon(Icons.emoji_events, color: Colors.orange, size: 32),
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
            'Achievement',
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 'My Certificate' moved to drawer
          // 'Leaderboard' moved to drawer
        ],
      ),
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

  // Navigation Methods
  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Profile clicked')),
    );
  }

  

  void _navigateToCertificates() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyCertificatesPage()),
    );
  }

  void _navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FavoritesPage()),
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

  void _navigateToAchievements() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AchievementsPage()),
    );
  }

  Widget _buildPostSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final isGamified = themeProvider.isGamified;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Posts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isGamified ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PostUploadPage()),
                  );
                  setState(() {});
                },
                icon: Icon(
                  Icons.add,
                  color: isGamified ? Colors.white : Theme.of(context).iconTheme.color,
                ),
              ),
            ],
          ),
          if (_postManager.hasPosts())
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: _postManager.posts.length,
              itemBuilder: (context, index) {
                final post = _postManager.posts[index];
                return Container(
                  decoration: BoxDecoration(
                    color: isGamified ? Colors.white.withOpacity(0.1) : Theme.of(context).cardColor,
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
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.file(
                            File(post.imagePath),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey,
                              child: const Center(child: Text('Image not found')),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: isGamified ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        _postManager.likePost(post.id);
                                        setState(() {});
                                      },
                                      icon: Icon(
                                        Icons.favorite_border,
                                        color: isGamified ? Colors.white : Theme.of(context).iconTheme.color,
                                        size: 16,
                                      ),
                                    ),
                                    Text(
                                      '${post.likes}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isGamified ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => _addComment(post.id),
                                      icon: Icon(
                                        Icons.comment,
                                        color: isGamified ? Colors.white : Theme.of(context).iconTheme.color,
                                        size: 16,
                                      ),
                                    ),
                                    Text(
                                      '${post.comments.length}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isGamified ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          else
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Text(
                'No posts yet',
                style: TextStyle(
                  color: isGamified ? Colors.white.withOpacity(0.6) : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final isGamified = themeProvider.isGamified;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Performance Videos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isGamified ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PerformanceUploadPage()),
                  );
                  setState(() {});
                },
                icon: Icon(
                  Icons.add,
                  color: isGamified ? Colors.white : Theme.of(context).iconTheme.color,
                ),
              ),
            ],
          ),
          if (_videosManager.hasVideos())
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _videosManager.videos.length,
              itemBuilder: (context, index) {
                final video = _videosManager.videos[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isGamified ? Colors.white.withOpacity(0.1) : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isGamified ? Colors.red.withOpacity(0.2) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.play_circle_filled,
                        color: isGamified ? Colors.red[300] : Colors.red,
                        size: 32,
                      ),
                    ),
                    title: Text(
                      video.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isGamified ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    subtitle: Text(
                      'Recorded: ${_formatDate(video.recordedAt)}',
                      style: TextStyle(
                        color: isGamified ? Colors.white.withOpacity(0.8) : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    onTap: () => _playVideo(video),
                  ),
                );
              },
            )
          else
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Text(
                'No performance videos yet',
                style: TextStyle(
                  color: isGamified ? Colors.white.withOpacity(0.6) : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _addComment(String postId) {
    final TextEditingController commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(hintText: 'Write a comment...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (commentController.text.isNotEmpty) {
                _postManager.addComment(postId, commentController.text);
                setState(() {});
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _playVideo(PerformanceVideo video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoPath: video.filePath, title: video.title),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

