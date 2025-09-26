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
import 'widgets/profile_post_section.dart';
import 'profile_structure_screen.dart';
import 'daily_tasks_screen.dart';
import 'achievement.dart';


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
  bool _isRPGMode = true;

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
      backgroundColor: _isRPGMode ? const Color(0xFF101010) : Colors.white,
      drawer: _buildDrawer(context),

      body: _isRPGMode ? _buildRPGProfile(isDarkMode) : _buildNormalProfile(isDarkMode),
    );
  }

  Widget _buildScrollableContent(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(child: _buildSectionSelector()),
        const SizedBox(height: 16),
        GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              // Swipe right - go to XP
              _onSectionSelected(ProfileSection.XP);
            } else if (details.primaryVelocity! < 0) {
              // Swipe left - go to Activity
              _onSectionSelected(ProfileSection.Activity);
            }
          },
          child: _buildConditionalContent(isDarkMode),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Portfolio',
                    style: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${_combinedMedia.length} items',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurpleAccent, Colors.blueAccent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurpleAccent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white, size: 24),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UploadPage()),
                    );
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ),

        Container(
          height: 400,
          child: ProfilePostSection(
            onPostTap: _showPostDetail,
          ),
        ),
        const SizedBox(height: 120),
        const SizedBox(height: 120), // Extra space for bottom navigation
      ],
    );
  }
  
  Widget _buildMediaControls() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Icon(Icons.grid_view_outlined, color: Colors.grey.shade700, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Grid View',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Icon(Icons.sort, color: Colors.grey.shade700, size: 20),
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
          child: Column(
            children: [
              Icon(Icons.photo_library_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                "No media yet. Tap '+' to add something!", 
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8, 16.0, 0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: StaggeredGrid.count(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: _combinedMedia.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> media = entry.value;
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

  // ENHANCEMENT: The media item widget is redesigned for a cleaner look with better card edges.
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, -2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 0.5,
              ),
            ),
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
                            color: Colors.grey[300],
                            child: Icon(Icons.broken_image, color: Colors.grey[600], size: 32),
                          ),
                        )
                      : Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.broken_image, color: Colors.grey[600], size: 32),
                          ),
                        ),
                ),

                // Enhanced gradient overlay for better visibility
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                      stops: const [0.6, 1.0],
                    ),
                  ),
                ),

                // Centered play icon for videos with enhanced visibility
                if (isVideo)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                    ),
                  ),

                // Top-right gallery indicator with better visibility
                if (isGallery)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.collections_outlined, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${media['imageCount'] ?? 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bottom overlay with likes count for better engagement visibility
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite, color: Colors.red, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${media['likes'] ?? 0}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) => _buildGlassIconButton(Icons.menu, () => Scaffold.of(context).openDrawer()),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'John Doe',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          blurRadius: 2,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildGlassIconButton(
                    Icons.emoji_events,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AchievementsPage()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildGlassIconButton(
                    Icons.palette,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileStructureScreen()),
                    ),
                  ),
                ],
              ),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'John Doe',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.cake, color: Colors.grey[600], size: 14),
                        const SizedBox(width: 4),
                        Text('25 years • Male', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey[600], size: 14),
                        const SizedBox(width: 4),
                        Text('New York, USA', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.sports, color: Colors.grey[600], size: 14),
                        const SizedBox(width: 4),
                        Text('Track & Field Athlete', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.school, color: Colors.grey[600], size: 14),
                        const SizedBox(width: 4),
                        Text('State University', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildSportsDetailsSection(),
          const SizedBox(height: 15),
          _buildAboutSection(),
          const SizedBox(height: 15),
          _buildExperienceSection(),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('$followingCount', 'post'),
              if (!widget.isOwnProfile)
                _buildProfileActionButton('Follow', null, isDarkMode),
            ],
          ),
          const SizedBox(height: 15),
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
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(icon, color: Colors.black87, size: 24),
            ),
          ),
        ),
    );
  }

  Widget _buildSectionSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.deepPurpleAccent : Colors.black,
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

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Passionate athlete and fitness enthusiast 💪',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildInfoChip('🏃‍♂️ Running'),
            _buildInfoChip('🏋️‍♀️ Fitness'),
            _buildInfoChip('⚽ Football'),
            _buildInfoChip('📍 25 years old'),
          ],
        ),
      ],
    );
  }

  Widget _buildSportsDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
          Row(
            children: [
              Icon(Icons.sports, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Athletic Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem('Height', '6\'2"', Icons.height),
              ),
              Expanded(
                child: _buildDetailItem('Weight', '180 lbs', Icons.monitor_weight),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem('Experience', '8 years', Icons.timeline),
              ),
              Expanded(
                child: _buildDetailItem('Coach', 'Mike Johnson', Icons.person_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem('Best Event', 'Javelin Throw', Icons.sports_baseball),
              ),
              Expanded(
                child: _buildDetailItem('PB Record', '65.2m', Icons.emoji_events),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
          Row(
            children: [
              Icon(Icons.work_outline, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Experience',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildExperienceItem(
            'Professional Athlete',
            'State Athletics Team',
            '2020 - Present',
            'Competing in national and international track & field events. Specialized in javelin throw with multiple state records.',
            Icons.emoji_events,
          ),
          const SizedBox(height: 12),
          _buildExperienceItem(
            'Assistant Coach',
            'University Athletics Program',
            '2019 - 2020',
            'Mentored junior athletes in throwing techniques and strength training programs.',
            Icons.sports,
          ),
        ],
      ),
    );
  }





  Widget _buildExperienceItem(String title, String company, String duration, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.blue[600]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                company,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                duration,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }



  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
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
    final int totalXP = _appState.totalXP;
    final int level = (totalXP / 100).floor() + 1;
    const int xpPerLevel = 100;
    final int currentLevelXP = totalXP % xpPerLevel;
    final double progress = currentLevelXP / xpPerLevel;
    final int xpToNextLevel = xpPerLevel - currentLevelXP;

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
                  AnimatedBuilder(
                    animation: _breathingAnimation,
                    builder: (context, child) => Transform.scale(
                      scale: _breathingAnimation.value,
                      child: Image.asset(
                        'assets/images/champ.png',
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) =>
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.emoji_events, color: Colors.amber[400], size: 28),
                          ),
                      ),
                    ),
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
      ),
    );
  }

  Widget _buildStatsCards(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _buildEnhancedStatCard('Tests', '5', Icons.quiz_outlined, Colors.blue)),
          const SizedBox(width: 12),
          Expanded(child: _buildEnhancedStatCard('Rating', '8.7/10', Icons.trending_up, Colors.green)),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatCard(String title, String value, IconData icon, Color color) {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[800]!, Colors.grey[850]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey[700]!, width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3), width: 1),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Consumer<AppState>(
                builder: (context, appState, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                            child: Icon(
                              Icons.person,
                              size: 32,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appState.userName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Findrly - Empowering Talent',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () { Navigator.pop(context); _editProfile(); },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Profile'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
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
                  leading: const Icon(Icons.edit, color: Colors.white),
                  title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
                  onTap: () { Navigator.pop(context); _editProfile(); },
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

  void _playVideo(PerformanceVideo video) => Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoPath: video.filePath, title: video.title)));
  Widget _buildRPGProfile(bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          _buildAnimatedGradientBackground(),
          SafeArea(
            child: SingleChildScrollView(
              child: _buildProfileHeaderContent(isDarkMode),
            ),
          ),
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              return false;
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.1,
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
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: _buildDragHandle(),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              physics: const ClampingScrollPhysics(),
                              child: _buildScrollableContent(isDarkMode),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DailyTasksScreen()),
              ),
              backgroundColor: Colors.deepPurpleAccent,
              child: const Icon(Icons.task_alt, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalProfile(bool isDarkMode) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildNormalProfileHeader(),
          Container(
            height: 400,
            child: ProfilePostSection(
              onPostTap: _showPostDetail,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 40, color: Colors.grey[600]),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'John Doe',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Track & Field Athlete',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatItem('17K', 'Friends'),
                        const SizedBox(width: 20),
                        _buildStatItem('387', 'Posts'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Passionate athlete and fitness enthusiast 💪',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

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
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        border: Border(bottom: BorderSide(color: Colors.grey[800]!, width: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.purpleAccent, Colors.blueAccent],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.black,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: widget.userProfile['image'] != null
                                    ? ((widget.userProfile['isOwnProfile'] as bool) 
                                        ? FileImage(File(widget.userProfile['image'] as String)) 
                                        : NetworkImage(widget.userProfile['image'] as String) as ImageProvider)
                                    : null,
                                child: widget.userProfile['image'] == null 
                                    ? Icon(Icons.person, color: Colors.grey[600]) 
                                    : null,
                              ),
                            ),
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
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        child: Hero(
                          tag: widget.post['id'] ?? 'default',
                          child: (widget.post['isDummy'] == true)
                              ? Image.asset(
                                  widget.post['imagePath'] ?? 'assets/images/event_1.jpg',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.grey[800],
                                    child: const Icon(Icons.image, color: Colors.white, size: 50),
                                  ),
                                )
                              : Image.file(
                                  File(widget.post['imagePath'] ?? ''),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.grey[800],
                                    child: const Icon(Icons.image, color: Colors.white, size: 50),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.9),
                        border: Border(top: BorderSide(color: Colors.grey[800]!, width: 0.5)),
                      ),
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
                              const SizedBox(width: 20),
                              Icon(Icons.chat_bubble_outline, color: Colors.white, size: 26),
                              const SizedBox(width: 20),
                              Icon(Icons.share_outlined, color: Colors.white, size: 26),
                              const Spacer(),
                              Icon(Icons.bookmark_border, color: Colors.white, size: 26),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$_likes likes',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
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
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'View all comments',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
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