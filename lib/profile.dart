import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:ui'; // Needed for ImageFilter
import 'dart:math'; // For shuffling media
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'; // Import the package

// (Ensure all other necessary import statements for your project are present)
import 'app_state.dart';
import 'theme_provider.dart';
import 'performance_videos_manager.dart';
import 'upload_page.dart';
import 'post_manager.dart';
import 'achievement.dart';
import 'profile_structure_screen.dart';
import 'daily_tasks_screen.dart';


enum ProfileSection { XP, Activity }

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
  late AnimationController _gradientController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _scaleAnimation;
  final AppState _appState = AppState.instance;
  final PostManager _postManager = PostManager();
  final PerformanceVideosManager _videosManager = PerformanceVideosManager();
  final ScrollController _scrollController = ScrollController();

  ProfileSection _selectedSection = ProfileSection.Activity;

  // A combined list to hold both posts and videos
  List<Map<String, dynamic>> _combinedMedia = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _appState.addListener(_onAppStateChanged);
    // Load and combine media on initialization
    _loadAndCombineMedia();
  }

  @override
  void dispose() {
    _appState.removeListener(_onAppStateChanged);
    _animationController.dispose();
    _breathingController.dispose();
    _gradientController.dispose();
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

  // Method to combine posts and videos into a single list
  void _loadAndCombineMedia() {
    // Assuming Post object has a method to convert to map, or you can map it manually
    final List<Map<String, dynamic>> posts = _postManager.posts.map((p) => {
          'id': p.id,
          'imagePath': p.imagePath,
          'description': p.description,
          'likes': p.likes,
          'comments': p.comments,
          'type': 'image',
          'isDummy': false,
        }).toList();

    // ENHANCEMENT: Added 'isGallery' and 'imageCount' to simulate gallery posts from the UI design.
    final List<Map<String, dynamic>> dummyPosts = [
        {'id': 'dummy1', 'description': 'Coastal views.', 'likes': 255, 'comments': [], 'isDummy': true, 'imagePath': 'assets/images/coast_1.jpg', 'type': 'image', 'isGallery': true, 'imageCount': 5},
        {'id': 'dummy2', 'description': 'Misty mornings.', 'likes': 189, 'comments': [], 'isDummy': true, 'imagePath': 'assets/images/forest_mist.jpg', 'type': 'image'},
        {'id': 'dummy3', 'description': 'Healthy start!', 'likes': 310, 'comments': [], 'isDummy': true, 'imagePath': 'assets/images/food_bowls.jpg', 'type': 'image', 'isGallery': true, 'imageCount': 3},
        {'id': 'dummy4', 'description': 'Cliffs of Møn.', 'likes': 420, 'comments': [], 'isDummy': true, 'imagePath': 'assets/images/white_cliffs.jpg', 'type': 'image'},
        {'id': 'dummy5', 'description': 'Breakfast goals.', 'likes': 150, 'comments': [], 'isDummy': true, 'imagePath': 'assets/images/food_flatlay.jpg', 'type': 'image'},
    ];

    final List<Map<String, dynamic>> videos = _videosManager.videos.map((v) => {
          'id': v.filePath,
          'title': v.title,
          'filePath': v.filePath,
          'thumbnailPath': 'assets/images/coast_video_thumb.jpg', // Placeholder thumbnail for video
          'type': 'video',
          'isDummy': true, // For asset-based thumbnail
        }).toList();

    // Combine all sources and shuffle for a dynamic look
    setState(() {
        _combinedMedia = [...posts, ...dummyPosts, ...videos]..shuffle(Random());
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
            _buildAnimatedGradientBackground(),
            SafeArea(
              child: AnimatedBuilder(
                animation: _scrollController,
                builder: (context, child) {
                  final offset = _scrollController.hasClients ? _scrollController.offset : 0;
                  return Transform.translate(
                    offset: Offset(0, -offset * 0.3),
                    child: child,
                  );
                },
                child: _buildProfileHeaderContent(isDarkMode),
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.6,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
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
        _buildMediaControls(),
        _buildMediaGrid(),
        const SizedBox(height: 100), // Extra space at bottom
      ],
    );
  }
  
  Widget _buildMediaControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.grid_view_outlined, color: Colors.grey.shade700),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.sort, color: Colors.grey.shade700),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ENHANCEMENT: The entire media grid has been updated for a more dynamic and visually appealing layout.
  Widget _buildMediaGrid() {
    if (_combinedMedia.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Text("No media yet. Tap '+' to add something!", style: TextStyle(color: Colors.grey[600])),
        ),
      );
    }
  
    // Define a repeating pattern of tile sizes to match the reference UI.
    final pattern = [
      {'crossAxis': 2, 'mainAxis': 2}, // Large item
      {'crossAxis': 1, 'mainAxis': 2}, // Tall item
      {'crossAxis': 1, 'mainAxis': 1}, // Small square
      {'crossAxis': 1, 'mainAxis': 1}, // Small square
      {'crossAxis': 2, 'mainAxis': 1}, // Wide item
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      // Using StaggeredGrid with a custom pattern
      child: StaggeredGrid.count(
        crossAxisCount: 3, // A 3-column layout provides flexibility for patterns
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: _combinedMedia.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> media = entry.value;

          // Apply the repeating pattern to each item
          final tilePattern = pattern[index % pattern.length];

          return StaggeredGridTile.count(
            crossAxisCellCount: tilePattern['crossAxis']!,
            mainAxisCellCount: tilePattern['mainAxis']!,
            child: _buildMediaItem(media),
          );
        }).toList(),
      ),
    );
  }

  // ENHANCEMENT: The media item widget is redesigned for a cleaner look.
  Widget _buildMediaItem(Map<String, dynamic> media) {
    final bool isVideo = media['type'] == 'video';
    final bool isGallery = media['isGallery'] == true;
    final String imagePath = isVideo ? media['thumbnailPath'] : media['imagePath'];
    
    return GestureDetector(
      onTap: () {
        if (isVideo) {
          _playVideo(PerformanceVideo(id: media['id'], title: media['title'], filePath: media['filePath'], recordedAt: DateTime.now()));
        } else {
          _showPostDetail(media);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // Increased border radius for a softer look
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image/Thumbnail background
              Hero(
                tag: media['id'],
                child: media['isDummy']
                    ? Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      )
                    : Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
              ),

              // Subtle gradient for better text readability, can be removed if not desired
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),

              // --- UI ENHANCEMENTS START HERE ---

              // Centered play icon for videos, as seen in the reference UI
              if (isVideo)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
                  ),
                ),

              // Top-right icon for galleries, as seen in the reference UI
              if (isGallery)
                 Positioned(
                   top: 12,
                   right: 12,
                   child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     decoration: BoxDecoration(
                       color: Colors.black.withOpacity(0.6),
                       borderRadius: BorderRadius.circular(10),
                     ),
                     child: Icon(Icons.collections_outlined, color: Colors.white, size: 16),
                   ),
                 ),

              // --- UI ENHANCEMENTS END HERE ---
            ],
          ),
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildGlassIconButton(Icons.more_vert, _showProfileMenu),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                        backgroundColor: Colors.grey[200],
                        backgroundImage: profileImage != null
                            ? (widget.isOwnProfile ? FileImage(File(profileImage)) : NetworkImage(profileImage) as ImageProvider)
                            : null,
                        child: profileImage == null ? Icon(Icons.person, size: 35, color: Colors.grey.shade700) : null,
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
              _buildStatItem('17K', 'friends'),
              _buildStatItem('$followingCount', 'post'),
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
          color: isSelected ? null : Colors.black.withOpacity(0.1),
          border: isSelected ? null : Border.all(color: Colors.black.withOpacity(0.3)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
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
        color: isFollow ? null : Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.2))
      ),
      child: Text(
        text,
        style: TextStyle(color: isFollow ? Colors.white : Colors.black, fontWeight: FontWeight.w600),
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.withOpacity(0.8), Colors.blue.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: AnimatedBuilder(
                    animation: _breathingAnimation,
                    builder: (context, child) => Transform.scale(
                      scale: _breathingAnimation.value,
                      child: Image.asset(
                        getBadgeImage(currentLevel),
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.emoji_events, color: Colors.white, size: 40),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${getLevelName(currentLevel)} Level $currentLevel',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$currentXP / $xpForNextLevel XP',
                        style: const TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  width: MediaQuery.of(context).size.width * progress * 0.7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [Colors.white, Colors.white70],
                    ),
                  ),
                ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20))
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.palette, color: Colors.white),
                  title: const Text('Theme', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileStructureScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.white),
                  title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
                  onTap: () { Navigator.pop(context); _editProfile(); },
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white),
                  title: const Text('Settings', style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.share, color: Colors.white),
                  title: const Text('Share Profile', style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editProfile() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit Profile clicked')));
  void _navigateToAchievements() => Navigator.push(context, MaterialPageRoute(builder: (context) => AchievementsPage()));
  void _playVideo(PerformanceVideo video) => Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoPath: video.filePath, title: video.title)));
  void _showPostDetail(Map<String, dynamic> post) {
    try {
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          barrierColor: Colors.black87,
          pageBuilder: (context, animation, secondaryAnimation) => PostDetailOverlay(
            post: post, 
            userProfile: {
              'name': widget.isOwnProfile ? (_appState.userName ?? 'User') : (widget.userName ?? 'Unknown User'),
              'image': widget.isOwnProfile ? _appState.profileImagePath : widget.userProfileImage,
              'isOwnProfile': widget.isOwnProfile,
            }
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening post: $e')),
      );
    }
  }
}

class PostDetailOverlay extends StatefulWidget {
  final Map<String, dynamic> post;
  final Map<String, dynamic> userProfile;

  const PostDetailOverlay({Key? key, required this.post, required this.userProfile}) : super(key: key);

  @override
  State<PostDetailOverlay> createState() => _PostDetailOverlayState();
}

class _PostDetailOverlayState extends State<PostDetailOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLiked = false;
  int _likes = 0;

  @override
  void initState() {
    super.initState();
    _likes = widget.post['likes'] ?? 0;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.black87,
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white,
                              backgroundImage: widget.userProfile['image'] != null
                                  ? (widget.userProfile['isOwnProfile'] 
                                      ? FileImage(File(widget.userProfile['image'])) 
                                      : NetworkImage(widget.userProfile['image']) as ImageProvider)
                                  : null,
                              child: widget.userProfile['image'] == null 
                                  ? Icon(Icons.person, color: Colors.grey[600]) 
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.userProfile['name']?.toString() ?? 'User',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '2 hours ago',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: Hero(
                              tag: widget.post['id'] ?? 'default',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: (widget.post['isDummy'] == true)
                                    ? Image.asset(
                                        widget.post['imagePath'] ?? 'assets/images/event_1.jpg',
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          height: 300,
                                          color: Colors.grey[800],
                                          child: const Icon(Icons.image, color: Colors.white, size: 50),
                                        ),
                                      )
                                    : Image.file(
                                        File(widget.post['imagePath'] ?? ''),
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          height: 300,
                                          color: Colors.grey[800],
                                          child: const Icon(Icons.image, color: Colors.white, size: 50),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isLiked = !_isLiked;
                                      _likes += _isLiked ? 1 : -1;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      _isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: _isLiked ? Colors.red : Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.chat_bubble_outline, color: Colors.white, size: 26),
                                const SizedBox(width: 16),
                                Icon(Icons.share_outlined, color: Colors.white, size: 26),
                                const Spacer(),
                                Icon(Icons.bookmark_border, color: Colors.white, size: 26),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '$_likes likes',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (widget.post['description'] != null && widget.post['description'].isNotEmpty)
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${widget.userProfile['name']?.toString() ?? 'User'} ',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextSpan(
                                      text: widget.post['description']?.toString() ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              'View all comments',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Dummy VideoPlayerScreen (no changes needed)
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