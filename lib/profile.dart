import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'app_state.dart';
import 'theme_provider.dart';
import 'performance_videos_manager.dart';
import 'upload_page.dart'; 
import 'post_manager.dart';
import 'achievement.dart';
import 'profile_structure_screen.dart';
import 'daily_tasks_screen.dart';

// (Ensure all other necessary import statements for your project are present)

enum ProfileSection { XP, Activity, Streak }
enum PortfolioTab { Posts, Performances }

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
  late TabController _tabController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _breathingAnimation;
  final AppState _appState = AppState.instance;
  final PostManager _postManager = PostManager();
  final PerformanceVideosManager _videosManager = PerformanceVideosManager();

  ProfileSection _selectedSection = ProfileSection.Activity;

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
    _tabController.dispose();
    super.dispose();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _tabController = TabController(length: 2, vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _breathingController.repeat(reverse: true);
  }

  void _onAppStateChanged() {
    if (mounted) setState(() {});
  }
  
  void _onSectionSelected(ProfileSection section) {
    setState(() {
      _selectedSection = section;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DailyTasksScreen()),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        child: const Icon(Icons.task_alt, color: Colors.white),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Layer 1: Fixed black background that never moves
            Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF121212),
            ),
            
            // Layer 2: Fixed header content that stays in place
            SafeArea(
              child: _buildProfileHeaderContent(isDarkMode),
            ),
            
            // Layer 3: Scrollable white card overlay
            DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.6,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    child: _buildScrollableContent(isDarkMode),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildProfileHeaderContent(bool isDarkMode) {
    final displayName = widget.isOwnProfile ? _appState.userName : (widget.userName ?? 'Unknown User');
    final profileImage = widget.isOwnProfile ? _appState.profileImagePath : widget.userProfileImage;
    final followingCount = widget.friendsCount ?? 387;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // THIS IS THE RESTORED RGB THEME ICON
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.green, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileStructureScreen()),
                    );
                  },
                  icon: const Icon(Icons.palette, color: Colors.white),
                  iconSize: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: _showProfileMenu,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[800],
                backgroundImage: profileImage != null
                    ? (widget.isOwnProfile ? FileImage(File(profileImage)) : NetworkImage(profileImage) as ImageProvider)
                    : null,
                child: profileImage == null ? const Icon(Icons.person, size: 35, color: Colors.white70) : null,
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[400], size: 16),
                      const SizedBox(width: 4),
                      Text('New York, USA', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('17K', 'followers'),
              _buildStatItem('$followingCount', 'following'),
              widget.isOwnProfile
                  ? _buildProfileActionButton('Edit Profile', null, isDarkMode)
                  : _buildProfileActionButton('Follow', null, isDarkMode),
            ],
          ),
          const SizedBox(height: 15),
          _buildSectionSelector(),
        ],
      ),
    );
  }
  
  Widget _buildSectionSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSectionButton("XP", ProfileSection.XP),
        _buildSectionButton("Activity", ProfileSection.Activity),
        _buildSectionButton("Streak", ProfileSection.Streak),
      ],
    );
  }
  
  Widget _buildSectionButton(String title, ProfileSection section) {
    bool isSelected = _selectedSection == section;
    return GestureDetector(
      onTap: () => _onSectionSelected(section),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected ? const LinearGradient(colors: [Colors.purpleAccent, Colors.blueAccent]) : null,
          border: isSelected ? null : Border.all(color: Colors.grey[700]!),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[300],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileActionButton(String text, IconData? icon, bool isDarkMode) {
    bool isFollow = text == 'Follow';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
        gradient: isFollow ? const LinearGradient(colors: [Colors.purpleAccent, Colors.blueAccent]) : null,
        color: isFollow ? null : Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[400])),
      ],
    );
  }

  Widget _buildScrollableContent(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _buildConditionalContent(isDarkMode),
        
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 12, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Portfolio',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.deepPurpleAccent),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UploadPage()),
                  );
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        
        TabBar(
          controller: _tabController,
          indicatorColor: Colors.deepPurpleAccent,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Posts"),
            Tab(text: "Performances"),
          ],
        ),

        // Use IndexedStack for TabBarView content to preserve state
        IndexedStack(
          index: _tabController.index,
          children: [
            Visibility(
              visible: _tabController.index == 0,
              maintainState: true,
              child: _buildPostSection(),
            ),
            Visibility(
              visible: _tabController.index == 1,
              maintainState: true,
              child: _buildPerformanceSection(),
            ),
          ],
        ),
        const SizedBox(height: 100), // Extra space at bottom
      ],
    );
  }
 
  Widget _buildConditionalContent(bool isDarkMode) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(_selectedSection),
        child: _getContentForSection(_selectedSection, isDarkMode),
      ),
    );
  }

  Widget _getContentForSection(ProfileSection section, bool isDarkMode) {
    switch (section) {
      case ProfileSection.XP:
        return _buildXPBar(isDarkMode);
      case ProfileSection.Activity:
        return _buildStatsCards(isDarkMode);
      case ProfileSection.Streak:
        return _buildStreakCard(isDarkMode);
    }
  }

  Widget _buildXPBar(bool isDarkMode) {
    final int currentXP = _appState.totalXP;
    final int currentLevel = (currentXP / 100).floor() + 1;
    final int xpForCurrentLevel = (currentLevel - 1) * 100;
    final int xpForNextLevel = currentLevel * 100;
    final double progress = (currentXP - xpForCurrentLevel) / (xpForNextLevel - xpForCurrentLevel);

    String getBadgeImage(int level) => 'assets/images/champ.png';
    String getLevelName(int level) {
      if (level >= 10) return 'Diamond';
      if (level >= 7) return 'Champion';
      if (level >= 5) return 'Silver';
      return 'Beginner';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _breathingAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _breathingAnimation.value,
                    child: Image.asset(
                      getBadgeImage(currentLevel),
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.emoji_events, color: Colors.blue, size: 50),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${getLevelName(currentLevel)} Level $currentLevel',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$currentXP XP',
                        style: const TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                minHeight: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildModernStatCard('Tests', '5', Icons.quiz_outlined, Colors.blue)),
          const SizedBox(width: 12),
          Expanded(child: _buildModernStatCard('Rating', '8.7/10', Icons.trending_up, Colors.green)),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToAchievements(),
              child: _buildModernStatCard('Badges', '1', Icons.emoji_events, Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => _appState.updateStreak(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_fire_department, color: _appState.isStreakActive ? Colors.orange : Colors.grey, size: 28),
              const SizedBox(width: 12),
              Text(
                '${_appState.streakCount} Day Streak',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
 
  Widget _buildPostSection() {
    final allPosts = _getAllPosts();
    if (allPosts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Center(child: Text("No posts yet. Tap '+' to add one!", style: TextStyle(color: Colors.grey[600]))),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: _buildPostImage(allPosts[0]),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: _buildPostImage(allPosts.length > 1 ? allPosts[1] : allPosts[0]),
                    ),
                    const SizedBox(height: 8),
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: _buildPostImage(allPosts.length > 2 ? allPosts[2] : allPosts[0]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: _buildPostImage(allPosts.length > 3 ? allPosts[3] : allPosts[0]),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: _buildPostImage(allPosts.length > 4 ? allPosts[4] : allPosts[0]),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: _buildPostImage(allPosts.length > 5 ? allPosts[5] : allPosts[0]),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
 
  Widget _buildPostImage(Map<String, dynamic> post) {
    return GestureDetector(
      onTap: () => _showPostDetail(post),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: post['isDummy'] == true
            ? Image.asset(
                post['imagePath'],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey[200],
                ),
              )
            : Image.file(
                File(post['imagePath']),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey[200],
                ),
              ),
      ),
    );
  }

  Widget _buildPerformanceSection() {
    if (!_videosManager.hasVideos()) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Center(child: Text("No performance videos yet. Tap '+' to add one!", style: TextStyle(color: Colors.grey[600]))),
      );
    }
    return Column(
      children: _videosManager.videos.map((video) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.play_circle_fill, color: Colors.deepPurpleAccent, size: 40),
              title: Text(video.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Recorded: ${_formatDate(video.recordedAt)}'),
              onTap: () => _playVideo(video),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.black),
              title: const Text('Edit Profile', style: TextStyle(color: Colors.black)),
              onTap: () { Navigator.pop(context); _editProfile(); },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.black),
              title: const Text('Settings', style: TextStyle(color: Colors.black)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.black),
              title: const Text('Share Profile', style: TextStyle(color: Colors.black)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
 
  List<Map<String, dynamic>> _getAllPosts() {
    List<Map<String, dynamic>> allPosts = [];
    allPosts.addAll(_postManager.posts.map((p) => {
      'id': p.id, 'imagePath': p.imagePath, 'description': p.description,
      'likes': p.likes, 'comments': p.comments, 'isDummy': false,
    }));
    final dummyPosts = [
      {'id': 'dummy1', 'description': 'Neon vibes!', 'likes': 124, 'comments': [], 'isDummy': true, 'imagePath': 'assets/images/event 1.jpg'},
      {'id': 'dummy2', 'description': 'Street art.', 'likes': 98, 'comments': [], 'isDummy': true, 'imagePath': 'assets/images/event 2.jpg'},
      {'id': 'dummy3', 'description': 'Nightlife.', 'likes': 210, 'comments': [], 'isDummy': true, 'imagePath': 'assets/images/event 3.jpg'},
      {'id': 'dummy4', 'description': 'Urban exploration.', 'likes': 150, 'comments': [], 'isDummy': true, 'imagePath': 'assets/images/event 4.jpg'},
      {'id': 'dummy5', 'description': 'Portrait mode.', 'likes': 300, 'comments': [], 'isDummy': true, 'imagePath': 'assets/images/event 5.jpg'},
      {'id': 'dummy6', 'description': 'Lights.', 'likes': 180, 'comments': [], 'isDummy': true, 'imagePath': 'assets/images/hurdle.jpg'},
    ];
    allPosts.addAll(dummyPosts);
    return allPosts;
  }
 
  void _editProfile() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit Profile clicked')));
  void _navigateToAchievements() => Navigator.push(context, MaterialPageRoute(builder: (context) => AchievementsPage()));
  void _playVideo(PerformanceVideo video) => Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoPath: video.filePath, title: video.title)));
  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
  void _showPostDetail(Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (context) => Dialog(),
    );
  }
}

class VideoPlayerScreen extends StatelessWidget {
  final String videoPath;
  final String title;
  const VideoPlayerScreen({Key? key, required this.videoPath, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('Video Player - Implementation needed')),
    );
  }
}