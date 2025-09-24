import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:ui'; // Needed for ImageFilter
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
  late AnimationController _gradientController; // For background gradient animation
  late TabController _tabController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _scaleAnimation; // For interactive elements
  final AppState _appState = AppState.instance;
  final PostManager _postManager = PostManager();
  final PerformanceVideosManager _videosManager = PerformanceVideosManager();
  final ScrollController _scrollController = ScrollController();

  ProfileSection _selectedSection = ProfileSection.Activity;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _appState.addListener(_onAppStateChanged);
    _tabController.addListener(() => setState(() {})); // Rebuild on tab change
  }

  @override
  void dispose() {
    _appState.removeListener(_onAppStateChanged);
    _animationController.dispose();
    _breathingController.dispose();
    _gradientController.dispose();
    _tabController.dispose();
    _scrollController.dispose();
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
    )..repeat(reverse: true);
    _gradientController = AnimationController(
        duration: const Duration(seconds: 10),
        vsync: this,
    )..repeat(reverse: true);


    _tabController = TabController(length: 2, vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
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
      backgroundColor: const Color(0xFF101010),
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
            // Layer 1: Animated Gradient Background
            _buildAnimatedGradientBackground(),

            // Layer 2: Fixed header content that stays in place (with Parallax)
            SafeArea(
              child: AnimatedBuilder(
                animation: _scrollController,
                builder: (context, child) {
                  // Parallax effect
                  final offset = _scrollController.hasClients ? _scrollController.offset : 0;
                  return Transform.translate(
                    offset: Offset(0, -offset * 0.3),
                    child: child,
                  );
                },
                child: _buildProfileHeaderContent(isDarkMode),
              ),
            ),

            // Layer 3: Scrollable glassmorphism card overlay
            DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.6,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                // Link the sheet's controller to our parallax controller
                if (_scrollController.hasClients) {
                  // This is a simple way to sync them. A more robust solution might use a custom controller.
                }
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                        border: Border.all(color: Colors.white.withOpacity(0.1))
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        physics: const ClampingScrollPhysics(),
                        child: _buildScrollableContent(isDarkMode),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
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
              _buildGlassIconButton(Icons.palette, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileStructureScreen()));
              }),
              _buildGlassIconButton(Icons.more_vert, _showProfileMenu),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Enhanced Profile Picture with Gradient Border
               AnimatedBuilder(
                  animation: _breathingController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            Colors.purpleAccent.withOpacity(0.8),
                            Colors.blueAccent.withOpacity(0.8),
                            Colors.purpleAccent.withOpacity(0.8),
                          ],
                          transform: GradientRotation(_breathingController.value * 3.14 * 2),
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: profileImage != null
                            ? (widget.isOwnProfile ? FileImage(File(profileImage)) : NetworkImage(profileImage) as ImageProvider)
                            : null,
                        child: profileImage == null ? const Icon(Icons.person, size: 35, color: Colors.white70) : null,
                      ),
                    );
                  },
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Text('New York, USA', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
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

  Widget _buildGlassIconButton(IconData icon, VoidCallback onPressed) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: IconButton(
                    onPressed: onPressed,
                    icon: Icon(icon, color: Colors.black, size: 24),
                ),
            ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected ? const LinearGradient(colors: [Colors.purpleAccent, Colors.blueAccent]) : null,
          color: isSelected ? null : Colors.white.withOpacity(0.1),
          border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.black,
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
        color: isFollow ? null : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2))
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  // A reusable glass container widget
  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: child,
            ),
        ),
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
                icon: const Icon(Icons.add_circle_outline, color: Colors.deepPurpleAccent, size: 28),
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
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.deepPurpleAccent,
          ),
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey[600],
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Posts"),
            Tab(text: "Performances"),
          ],
        ),

        SizedBox(
          // Set a fixed height for the TabBarView content
          height: 500, // Adjust this height as needed
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPostSection(),
              _buildPerformanceSection(),
            ],
          ),
        ),
        const SizedBox(height: 100), // Extra space at bottom
      ],
    );
  }

  Widget _buildConditionalContent(bool isDarkMode) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
              position: Tween<Offset>(
                  begin: const Offset(0.0, 0.2),
                  end: Offset.zero
              ).animate(animation),
              child: child
          ),
        );
      },
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
      child: _buildGlassContainer(
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
                        '$currentXP / $xpForNextLevel XP',
                        style: const TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Custom, thicker progress bar
            Container(
              height: 12,
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6)
              ),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                      width: MediaQuery.of(context).size.width * progress * 0.7, // Adjust width factor
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.deepPurpleAccent])
                      ),
                  ),
              ),
            )
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
    return _buildGlassContainer(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.6), color.withOpacity(0.9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
              ),
              child: Icon(icon, color: Colors.white, size: 24)
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
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
        child: _buildGlassContainer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_fire_department, color: _appState.isStreakActive ? Colors.orangeAccent : Colors.grey, size: 28),
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
      return Center(child: Text("No posts yet. Tap '+' to add one!", style: TextStyle(color: Colors.grey[600])));
    }
    // Use a GridView for a more dynamic and clean layout
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allPosts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return _buildPostImage(allPosts[index]);
      },
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
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800]),
              )
            : Image.file(
                File(post['imagePath']),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800]),
              ),
      ),
    );
  }
  
  Widget _buildPerformanceSection() {
    if (!_videosManager.hasVideos()) {
      return Center(child: Text("No performances yet. Tap '+' to add one!", style: TextStyle(color: Colors.grey[600])));
    }
    // Revamped to a horizontal list of cards
    return SizedBox(
      height: 180, // Define height for horizontal list
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _videosManager.videos.length,
        itemBuilder: (context, index) {
          final video = _videosManager.videos[index];
          return _buildPerformanceCard(video);
        },
      ),
    );
  }

  Widget _buildPerformanceCard(PerformanceVideo video) {
      return GestureDetector(
        onTap: () => _playVideo(video),
        child: Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                // Using a dummy image as a placeholder thumbnail
                image: DecorationImage(
                    image: const AssetImage('assets/images/event_5.jpg'), // Placeholder
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                ),
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              const Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
                              const SizedBox(height: 8),
                              Text(video.title,
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                              ),
                          ],
                      ),
                    )
                ],
            ),
        ),
      );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Make it transparent for glass effect
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.grey.shade900.withOpacity(0.8),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20))
              ),
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: _buildPostImage(post), // Simple preview for now
      ),
    );
  }
}

// Dummy VideoPlayerScreen - No changes needed here
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