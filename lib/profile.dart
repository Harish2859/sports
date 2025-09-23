import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:math' as math;
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
import 'bid_screen.dart';
import 'daily_tasks_screen.dart';
import 'profile_structure_screen.dart';

class ProfilePage extends StatefulWidget {
  final bool isOwnProfile;
  final String? userId;
  final String? userName;
  final String? userProfileImage;
  final int? friendsCount;
  
  const ProfilePage({
    super.key,
    this.isOwnProfile = true,
    this.userId,
    this.userName,
    this.userProfileImage,
    this.friendsCount,
  });

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
  bool _isSoloLevelingMode = false;

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
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _breathingAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _breathingController.repeat(reverse: true);
  }

  void _onAppStateChanged() {
    if (mounted) setState(() {});
  }

  // Main Build Method
  @override
  Widget build(BuildContext context) {
    return _buildNormalProfile();
  }

  Widget _buildNormalProfile() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      decoration: _buildBackgroundDecoration(themeProvider),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: _buildProfileContent(isDarkMode),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DailyTasksScreen()),
            );
          },
          child: const Icon(Icons.task_alt),
        ),
      ),
    );
  }

  // UI Building Methods
  BoxDecoration? _buildBackgroundDecoration(ThemeProvider themeProvider) {
    return null;
  }

  Widget _buildProfileContent(bool isDarkMode) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          _buildProfileHeader(isDarkMode),
          const SizedBox(height: 20),
          _buildXPBar(isDarkMode),
          const SizedBox(height: 20),
          _buildStatsCards(isDarkMode),
          const SizedBox(height: 20),
          _buildActionButtons(isDarkMode),
          const SizedBox(height: 20),
          // Instagram/Threads style tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(25),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.grid_on, size: 18),
                        const SizedBox(width: 8),
                        const Text('Posts'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_circle_outline, size: 18),
                        const SizedBox(width: 8),
                        const Text('Videos'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
    final displayName = widget.isOwnProfile ? _appState.userName : (widget.userName ?? 'Unknown User');
    final profileImage = widget.isOwnProfile ? _appState.profileImagePath : widget.userProfileImage;
    final friendsCount = widget.friendsCount ?? 156;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          // Cover photo area (Instagram/Twitter style)
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.purple[400]!],
              ),
            ),
            child: Stack(
              children: [
                // RGB button (top left)
                Positioned(
                  top: 40,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red, Colors.green, Colors.blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileStructureScreen()),
                        );
                      },
                      icon: const Icon(Icons.palette, color: Colors.white),
                    ),
                  ),
                ),
                // Settings/Menu button (Discord style)
                if (widget.isOwnProfile)
                  Positioned(
                    top: 40,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: _showProfileMenu,
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Profile info section
          Transform.translate(
            offset: const Offset(0, -40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Profile picture with border (Instagram style)
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: profileImage != null
                              ? (widget.isOwnProfile ? FileImage(File(profileImage)) : NetworkImage(profileImage) as ImageProvider)
                              : null,
                          child: profileImage == null
                              ? Icon(Icons.person, size: 45, color: Colors.grey[600])
                              : null,
                        ),
                      ),
                      const Spacer(),
                      // Action buttons (Twitter/Threads style)
                      if (!widget.isOwnProfile) 
                        Row(
                          children: [
                            _buildProfileActionButton('Follow', Icons.person_add, Colors.blue),
                            const SizedBox(width: 8),
                            _buildProfileActionButton('Message', Icons.message, Colors.grey),
                          ],
                        )
                      else 
                        _buildProfileActionButton('Edit Profile', Icons.edit, Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // User info
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Verification badge (Twitter style)
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${displayName.toLowerCase().replaceAll(' ', '_')}_sports',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Bio (Instagram/Twitter style)
                        Text(
                          '🏆 Sports enthusiast | 💪 Fitness lover\n📍 Training hard every day',
                          style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Stats row (Instagram style)
                        Row(
                          children: [
                            _buildStatItem('156', 'Posts'),
                            const SizedBox(width: 24),
                            GestureDetector(
                              onTap: _showFriendsList,
                              child: _buildStatItem('$friendsCount', 'Friends'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActionButton(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color == Colors.blue ? Colors.blue : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: color == Colors.grey ? Border.all(color: Colors.grey[400]!) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            size: 16, 
            color: color == Colors.blue ? Colors.white : Colors.grey[700],
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color == Colors.blue ? Colors.white : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                _editProfile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Profile'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildXPBar(bool isDarkMode) {
    final int currentXP = _appState.totalXP;
    final int currentLevel = (currentXP / 100).floor() + 1;
    final int xpForCurrentLevel = (currentLevel - 1) * 100;
    final int xpForNextLevel = currentLevel * 100;
    final double progress = (currentXP - xpForCurrentLevel) / (xpForNextLevel - xpForCurrentLevel);
    
    String getBadgeImage(int level) {
      return 'assets/images/champ.png';
    }
    
    String getLevelName(int level) {
      if (level >= 10) return 'Diamond';
      if (level >= 7) return 'Champion';
      if (level >= 5) return 'Silver';
      if (level >= 3) return 'Intermediate';
      return 'Beginner';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.purple.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _breathingAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _breathingAnimation.value,
                      child: Image.asset(
                        getBadgeImage(currentLevel),
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.emoji_events,
                            color: Colors.blue,
                            size: 60,
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${getLevelName(currentLevel)} Level $currentLevel',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$currentXP XP',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: [
                    Colors.grey[300]!,
                    Colors.grey[200]!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                    ).colors.first,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(currentXP - xpForCurrentLevel)} / ${(xpForNextLevel - xpForCurrentLevel)} XP to next level',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(bool isDarkMode) {
    final int totalXP = _appState.totalXP;
    final bool hasBeginnerBadge = totalXP >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Discord-style activity cards
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildModernStatCard(
                        'Tests', '5', Icons.quiz_outlined, 
                        Colors.blue, isDarkMode
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModernStatCard(
                        'Rating', '8.7/10', Icons.trending_up, 
                        Colors.green, isDarkMode
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _navigateToAchievements(),
                        child: _buildModernStatCard(
                          'Badges', '1', Icons.emoji_events, 
                          Colors.orange, isDarkMode
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildStreakCard(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(String title, String value, IconData icon, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }





  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeStatCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            'Achievement',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(bool isDarkMode) {
    final bool isActive = _appState.isStreakActive;
    final Color streakColor = isActive ? Colors.orange : Colors.red;
    final IconData streakIcon = isActive ? Icons.local_fire_department : Icons.local_fire_department;
    
    return GestureDetector(
      onTap: () {
        _appState.updateStreak();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(streakIcon, color: streakColor, size: 32),
            const SizedBox(width: 12),
            Column(
              children: [
                Text(
                  '${_appState.streakCount}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  'Day Streak',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ],
        ),
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





  // Navigation Methods
  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Profile clicked')),
    );
  }

  void _addFriend() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Friend request sent to ${widget.userName ?? 'user'}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showFriendsList() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Friends',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Friends list will be implemented here'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildCreatePostCard(isDarkMode),
          // Show posts (real + dummy)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _getAllPosts().length,
            itemBuilder: (context, index) {
              final post = _getAllPosts()[index];
              return GestureDetector(
                onTap: () => _showPostDetail(post),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        post['isDummy'] == true
                          ? Image.asset(
                              post['imagePath'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.image, color: Colors.grey[600]),
                              ),
                            )
                          : Image.file(
                              File(post['imagePath']),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.image, color: Colors.grey[600]),
                              ),
                            ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.favorite, color: Colors.white, size: 12),
                                const SizedBox(width: 2),
                                Text(
                                  '${post['likes']}',
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPostDetail(Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Post image/content
              Expanded(
                child: post['isDummy'] == true
                  ? Image.asset(
                      post['imagePath'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(Icons.image, color: Colors.grey[600], size: 80),
                        ),
                      ),
                    )
                  : Image.file(
                      File(post['imagePath']),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
              ),
              // Post actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (post['isDummy'] != true) {
                              _postManager.likePost(post['id']);
                              setState(() {});
                            }
                          },
                          icon: const Icon(Icons.favorite_border),
                        ),
                        IconButton(
                          onPressed: () {
                            if (post['isDummy'] != true) {
                              _addComment(post['id']);
                            }
                          },
                          icon: const Icon(Icons.comment_outlined),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.share_outlined),
                        ),
                      ],
                    ),
                    Text(
                      '${post['likes']} likes',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(post['description']),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatePostCard(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Icon(Icons.add_photo_alternate, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PostUploadPage()),
                );
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Share your sports moment...',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => _showCreateOptions('photo'),
            icon: Icon(Icons.photo_camera, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAllPosts() {
    List<Map<String, dynamic>> allPosts = [];
    
    // Add real posts
    for (var post in _postManager.posts) {
      allPosts.add({
        'id': post.id,
        'imagePath': post.imagePath,
        'description': post.description,
        'likes': post.likes,
        'comments': post.comments,
        'isDummy': false,
      });
    }
    
    // Add dummy posts
    final dummyPosts = [
      {
        'id': 'dummy1',
        'description': 'Morning workout session 💪',
        'likes': 24,
        'comments': [],
        'isDummy': true,
        'imagePath': 'assets/images/event 1.jpg',
      },
      {
        'id': 'dummy2',
        'description': 'Basketball practice 🏀',
        'likes': 18,
        'comments': [],
        'isDummy': true,
        'imagePath': 'assets/images/event 2.jpg',
      },
      {
        'id': 'dummy3',
        'description': 'Running in the park 🏃‍♂️',
        'likes': 32,
        'comments': [],
        'isDummy': true,
        'imagePath': 'assets/images/event 3.jpg',
      },
      {
        'id': 'dummy4',
        'description': 'Swimming session 🏊‍♂️',
        'likes': 15,
        'comments': [],
        'isDummy': true,
        'imagePath': 'assets/images/event 4.jpg',
      },
      {
        'id': 'dummy5',
        'description': 'Yoga practice 🧘‍♀️',
        'likes': 28,
        'comments': [],
        'isDummy': true,
        'imagePath': 'assets/images/event 5.jpg',
      },
      {
        'id': 'dummy6',
        'description': 'Tennis match 🎾',
        'likes': 21,
        'comments': [],
        'isDummy': true,
        'imagePath': 'assets/images/hurdle.jpg',
      },
    ];
    
    allPosts.addAll(dummyPosts);
    return allPosts;
  }

  void _showCreateOptions(String type) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create $type',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo/Video'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PostUploadPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PostUploadPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

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
                  color: Theme.of(context).textTheme.bodyLarge?.color,
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
                  color: Theme.of(context).iconTheme.color,
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
                    color: Theme.of(context).cardColor,
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
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.play_circle_filled,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),
                    title: Text(
                      video.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    subtitle: Text(
                      'Recorded: ${_formatDate(video.recordedAt)}',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
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
                  color: Theme.of(context).textTheme.bodyMedium?.color,
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

class VideoPlayerScreen extends StatelessWidget {
  final String videoPath;
  final String title;

  const VideoPlayerScreen({
    Key? key,
    required this.videoPath,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Video Player - Implementation needed'),
      ),
    );
  }
}

