import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'daily_tasks_screen.dart';


// Color constants to easily manage the theme
const Color kBackgroundColor = Color(0xFF121212);
const Color kPrimaryColor = Color(0xFFE88A6E);
const Color kCircleColor = Color(0xFFD9D9D9);
const Color kCardBackgroundColor = Color(0xFF1E1E1E);

class ProfileStructureScreen extends StatefulWidget {
  const ProfileStructureScreen({super.key});

  @override
  State<ProfileStructureScreen> createState() => _ProfileStructureScreenState();
}

class _ProfileStructureScreenState extends State<ProfileStructureScreen> with TickerProviderStateMixin {
  int currentPage = 0;
  bool showPostsSection = false;
  final PageController _pageController = PageController(
    initialPage: 0,
    viewportFraction: 0.35,
  );
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  // ADDED: Animation controller for the profile ring
  late AnimationController _ringController;


  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _breathingAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
    _breathingController.repeat(reverse: true);

    // ADDED: Initialize the ring animation controller
    _ringController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  // MODIFIED: Data structure for the pages - Added ACHIEVEMENTS
  final List<Map<String, dynamic>> _pageData = [
    {
      'title': 'PROFILE',
      'content': {
        'Name': 'Tyler Mavericks',
        'About': 'Cosmic explorer & stargazing enthusiast.',
        'Posts': 150,
        'Friends': 250,
      }
    },
    {
      'title': 'ACTIVITY',
      'content': {
        'About': 'Track your daily progress and streaks.',
        'StreakDays': 12,
        'Last Active': 'Today, 9:34 PM',
      }
    },
    {
      'title': 'XP GAINED',
      'content': {
        'About': 'Your experience points for the week.',
        'XP': 1240,
        'MaxXP': 2000,
      }
    },
    {
      'title': 'STATS',
      'content': {
        'About': 'A summary of your player statistics.',
        'Level': 7,    // Changed to int for the chart
        'Rank': 1203,  // Changed to int for the chart
        'Win Rate': 78, // Changed to int for the chart
      }
    },
    // ADDED: New section for achievements
    {
      'title': 'ACHIEVEMENTS',
      'content': {
        'About': 'Showcase your most impressive milestones.',
        'Badges': [
          {'name': '10-Day Streak', 'asset': 'assets/images/badge_streak.png'},
          {'name': 'Perfect Week', 'asset': 'assets/images/badge_perfect_week.png'},
          {'name': 'First Victory', 'asset': 'assets/images/badge_first_win.png'},
        ]
      }
    },
    {
      'title': 'SETTINGS',
      'content': {
        'About': 'Manage your account and app settings.',
        'Account': 'ty_mav',
        'Privacy': 'Friends Only',
        'Notifications': 'Enabled',
      }
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _breathingController.dispose();
    _ringController.dispose(); // ADDED: Dispose the new controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double largeCircleDiameter = screenSize.width * 0.6;
    final double sideCircleLarge = screenSize.width * 0.18;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        currentIndex: 4,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_outlined),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            label: 'Fitness',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            label: 'Assessment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          // This is placeholder navigation. In a real app, use a router.
          switch (index) {
            case 0:
            // Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
            // Navigator.pushReplacementNamed(context, '/nutrition');
              break;
            case 2:
            // Navigator.pushReplacementNamed(context, '/fitness');
              break;
            case 3:
            // Navigator.pushReplacementNamed(context, '/assessment');
              break;
            case 4:
            // Already on profile
              break;
          }
        },
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ClipPath(
              clipper: BackgroundClipper(),
              child: Container(
                height: screenSize.height * 0.55,
                color: kPrimaryColor,
              ),
            ),

            // MODIFIED: Wrapped profile picture with an animated ring
            Positioned(
              top: screenSize.height * 0.08 - 5,
              left: (screenSize.width / 2) - (largeCircleDiameter / 2) + 25,
              child: RotationTransition(
                turns: _ringController,
                child: Container(
                  width: largeCircleDiameter + 10,
                  height: largeCircleDiameter + 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      center: FractionalOffset.center,
                      colors: <Color>[
                        kPrimaryColor.withOpacity(0.8),
                        kPrimaryColor.withOpacity(0.2),
                        kPrimaryColor.withOpacity(0.8),
                      ],
                      stops: const <double>[0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: screenSize.height * 0.08,
              left: (screenSize.width / 2) - (largeCircleDiameter / 2) + 30,
              child: Container(
                width: largeCircleDiameter,
                height: largeCircleDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/Profile_picture.jpg',
                    width: largeCircleDiameter,
                    height: largeCircleDiameter,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: kCircleColor,
                        child: Icon(
                          Icons.person,
                          size: largeCircleDiameter * 0.5,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DailyTasksScreen()),
                    );
                  },
                  child: const Icon(
                    Icons.task_alt,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      showPostsSection = !showPostsSection;
                    });
                  },
                  child: const Icon(
                    Icons.apps,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
            if (!showPostsSection)
              Align(
                alignment: Alignment.bottomLeft,
                child: GestureDetector(
                  onTap: _showProfileOptions,
                  child: Container(
                    margin: const EdgeInsets.only(left: 30, bottom: 30),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kPrimaryColor.withOpacity(0.5), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.more_horiz,
                      color: kPrimaryColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
            if (!showPostsSection)
              Positioned(
                top: screenSize.height * 0.35,
                right: -25,
                height: 280,
                width: 120,
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemCount: _pageData.length,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double pageOffset = 0.0;
                        if (_pageController.position.haveDimensions) {
                          pageOffset = index - (_pageController.page ?? 0);
                        }
                        final double scale = (1 - (pageOffset.abs() * 0.6)).clamp(0.4, 1.0);
                        final double opacity = (1 - (pageOffset.abs() * 0.7)).clamp(0.0, 1.0);
                        return _buildAnimatedCircle(index, scale, opacity, sideCircleLarge);
                      },
                    );
                  },
                ),
              ),
            if (showPostsSection)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: screenSize.height * 0.6,
                child: Container(
                  decoration: const BoxDecoration(
                    color: kBackgroundColor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const TabBar(
                          labelColor: kPrimaryColor,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: kPrimaryColor,
                          tabs: [
                            Tab(text: 'Posts', icon: Icon(Icons.grid_on)),
                            Tab(text: 'Performance', icon: Icon(Icons.play_circle_outline)),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildPostsGrid(),
                              _buildPerformanceList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (!showPostsSection)
              Positioned(
                bottom: screenSize.height * 0.10,
                left: 30,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.5),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _buildPageContent(currentPage),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showProfileOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: kCardBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildOptionItem(Icons.edit, 'Edit Profile', () => Navigator.pop(context)),
            _buildOptionItem(Icons.settings, 'Settings', () => Navigator.pop(context)),
            _buildOptionItem(Icons.share, 'Share Profile', () => Navigator.pop(context)),
            _buildOptionItem(Icons.bookmark, 'Saved Posts', () => Navigator.pop(context)),
            _buildOptionItem(Icons.logout, 'Logout', () => Navigator.pop(context)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: kPrimaryColor),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }

  //-- WIDGET BUILDER HELPERS --//

  // MODIFIED: Added case for ACHIEVEMENTS
  Widget _buildPageContent(int index) {
    final data = _pageData[index];
    final title = data['title'] as String;
    final content = data['content'] as Map<String, dynamic>;
    final Size screenSize = MediaQuery.of(context).size;

    return Container(
      key: ValueKey<String>(title),
      width: screenSize.width * 0.7,
      child: switch (title) {
        'PROFILE' => _buildProfileCard(content),
        'ACTIVITY' => _buildActivityCard(content),
        'XP GAINED' => _buildXpCard(content),
        'STATS' => _buildStatsCard(content),
        'ACHIEVEMENTS' => _buildAchievementsCard(content), // ADDED
        'SETTINGS' => _buildSettingsCard(content),
        _ => const SizedBox.shrink(),
      },
    );
  }

  // --- UNIFIED CARD DESIGNS ---

  Widget _buildProfileCard(Map<String, dynamic> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content['Name'],
          style: const TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.verified, color: Colors.blue, size: 16),
            const SizedBox(width: 4),
            Text(
              'Verified Athlete',
              style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content['About'],
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.white54, size: 14),
            const SizedBox(width: 4),
            Text(
              'Los Angeles, CA',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
            const SizedBox(width: 16),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Online',
              style: TextStyle(color: Colors.green, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.all(16),
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(icon: Icons.grid_on_outlined, label: 'Posts', value: content['Posts'].toString()),
                VerticalDivider(color: Colors.white.withOpacity(0.2), thickness: 1, indent: 8, endIndent: 8),
                _buildStatItem(icon: Icons.people_alt_outlined, label: 'Friends', value: content['Friends'].toString()),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialIcon(Icons.sports_basketball, 'Basketball'),
            _buildSocialIcon(Icons.fitness_center, 'Fitness'),
            _buildSocialIcon(Icons.directions_run, 'Running'),
            _buildSocialIcon(Icons.pool, 'Swimming'),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String sport) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kPrimaryColor, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          sport,
          style: TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  // MODIFIED: Added a Heatmap calendar to the activity card
  Widget _buildActivityCard(Map<String, dynamic> content) {


    return Column(
      key: const ValueKey<String>('activity_v3'), // Updated key
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACTIVITY',
          style: TextStyle(
              color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2),
        ),
        const SizedBox(height: 15),
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [kPrimaryColor, Color(0xFFF0A28A)],
                      ).createShader(bounds),
                      child: Text(
                        '${content['StreakDays']}',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Text(
                      'DAY STREAK',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              VerticalDivider(color: Colors.white.withOpacity(0.15), thickness: 1, indent: 10, endIndent: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'LAST ACTIVE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      content['Last Active'].toString().split(', ').first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content['Last Active'].toString().split(', ').last,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Divider(color: Colors.white.withOpacity(0.1)),
        const SizedBox(height: 10),
        Container(
          height: 100,
          child: TableCalendar<int>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.week,
            headerVisible: false,
            daysOfWeekVisible: false,
            calendarStyle: CalendarStyle(
              cellMargin: EdgeInsets.all(2),
              defaultDecoration: BoxDecoration(
                color: Color(0x33E88A6E),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(4),
              ),
              todayDecoration: BoxDecoration(
                color: Color(0xFFE88A6E),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildXpCard(Map<String, dynamic> content) {
    final double progress = (content['XP'] as int) / (content['MaxXP'] as int);
    final Size screenSize = MediaQuery.of(context).size;
    final double smallCircleDiameter = screenSize.width * 0.18;
    final int currentLevel = ((content['XP'] as int) / 500).floor() + 1;
    final int xpToNextLevel = (currentLevel * 500) - (content['XP'] as int);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'XP GAINED',
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 10),
            AnimatedBuilder(
              animation: _breathingAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _breathingAnimation.value,
                  child: Image.asset(
                    'assets/images/champ.png',
                    width: smallCircleDiameter * 0.6,
                    height: smallCircleDiameter * 0.6,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.emoji_events,
                        color: kPrimaryColor,
                        size: smallCircleDiameter * 0.5,
                      );
                    },
                  ),
                );
              },
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kPrimaryColor.withOpacity(0.5)),
              ),
              child: Text(
                'Level $currentLevel',
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFC700), size: 20),
                  const SizedBox(width: 8),
                  const Text('Experience', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Text('${content['XP']} / ${content['MaxXP']}', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildXpStat('Weekly Goal', '1800/2000', Icons.flag),
                  _buildXpStat('Next Level', '$xpToNextLevel XP', Icons.trending_up),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildXpBreakdown('Workouts', '+320', Colors.blue),
                    _buildXpBreakdown('Challenges', '+180', Colors.green),
                    _buildXpBreakdown('Streaks', '+240', Colors.orange),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildXpStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildXpBreakdown(String source, String xp, Color color) {
    return Column(
      children: [
        Text(
          xp,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          source,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // MODIFIED: Compact stats section with radar chart
  Widget _buildStatsCard(Map<String, dynamic> content) {
    final int level = content['Level'];
    final int winRate = content['Win Rate'];
    final int rank = content['Rank'];
    final double rankScore = ((5000 - rank) / 5000) * 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'PLAYER STATS',
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getRankColor(rank).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getRankTier(rank),
                style: TextStyle(
                  color: _getRankColor(rank),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: RadarChart(
            RadarChartData(
              radarTouchData: RadarTouchData(enabled: false),
              dataSets: [
                RadarDataSet(
                  fillColor: kPrimaryColor.withOpacity(0.4),
                  borderColor: kPrimaryColor,
                  borderWidth: 2,
                  dataEntries: [
                    RadarEntry(value: level.toDouble()),
                    RadarEntry(value: rankScore),
                    RadarEntry(value: winRate.toDouble() / 10),
                  ],
                ),
              ],
              radarBorderData: BorderSide(color: Colors.white.withOpacity(0.4), width: 1),
              titlePositionPercentageOffset: 0.15,
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 10),
              getTitle: (index, angle) {
                switch (index) {
                  case 0:
                    return RadarChartTitle(text: 'Level');
                  case 1:
                    return RadarChartTitle(text: 'Rank');
                  case 2:
                    return RadarChartTitle(text: 'Win %');
                  default:
                    return RadarChartTitle(text: '');
                }
              },
              tickCount: 3,
              ticksTextStyle: TextStyle(color: Colors.transparent, fontSize: 8),
              tickBorderData: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
              gridBorderData: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCompactStat('156', 'Games', Icons.sports_esports, Colors.blue),
            _buildCompactStat('8.7', 'Score', Icons.star, Colors.yellow),
            _buildCompactStat('12', 'Streak', Icons.local_fire_department, Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactStat(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int rank) {
    if (rank <= 500) return Colors.blue;
    if (rank <= 1000) return Colors.cyan;
    if (rank <= 2000) return Colors.green;
    return Colors.orange;
  }

  String _getRankTier(int rank) {
    if (rank <= 500) return 'DIAMOND';
    if (rank <= 1000) return 'PLATINUM';
    if (rank <= 2000) return 'GOLD';
    return 'SILVER';
  }

  // ADDED: Enhanced achievements section with progress and rarity
  Widget _buildAchievementsCard(Map<String, dynamic> content) {
    final List<Map<String, String>> badges = List.from(content['Badges']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'ACHIEVEMENTS',
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '3/12',
                style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: badges.asMap().entries.map((entry) {
            final badge = entry.value;
            final rarity = _getBadgeRarity(entry.key);
            return Column(
              children: [
                Stack(
                  children: [
                    AnimatedBuilder(
                      animation: _breathingAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _breathingAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: rarity['color'].withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: rarity['color'].withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Image.asset(
                              badge['asset']!,
                              width: 32,
                              height: 32,
                              errorBuilder: (context, err, stack) => Icon(
                                Icons.military_tech,
                                color: rarity['color'],
                                size: 32,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: rarity['color'],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  badge['name']!,
                  style: const TextStyle(color: Colors.white70, fontSize: 9),
                  textAlign: TextAlign.center,
                ),
                Text(
                  rarity['name'],
                  style: TextStyle(
                    color: rarity['color'],
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAchievementStat('Total', '3', Icons.emoji_events),
            _buildAchievementStat('Rare', '1', Icons.diamond),
            _buildAchievementStat('Recent', '2d', Icons.schedule),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getBadgeRarity(int index) {
    switch (index) {
      case 0:
        return {'name': 'COMMON', 'color': Colors.grey};
      case 1:
        return {'name': 'RARE', 'color': Colors.blue};
      case 2:
        return {'name': 'EPIC', 'color': Colors.purple};
      default:
        return {'name': 'COMMON', 'color': Colors.grey};
    }
  }

  Widget _buildSettingsCard(Map<String, dynamic> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'SETTINGS',
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Synced',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSettingItem(icon: Icons.person_outline, label: 'Account', value: content['Account']),
            _buildSettingItem(icon: Icons.lock_outline_rounded, label: 'Privacy', value: 'Friends'),
            _buildSettingItem(icon: Icons.notifications_none_rounded, label: 'Notifications', value: 'On'),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickSetting('Dark Mode', true, Icons.dark_mode),
                  _buildQuickSetting('Auto Sync', true, Icons.sync),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickSetting('Sound', false, Icons.volume_up),
                  _buildQuickSetting('WiFi Only', true, Icons.wifi),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.language, color: Colors.white70, size: 14),
            const SizedBox(width: 6),
            Text(
              'Language: English',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
            const Spacer(),
            Text(
              'v2.1.0',
              style: TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingItem({required IconData icon, required String label, required String value}) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSetting(String label, bool isEnabled, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isEnabled ? kPrimaryColor : Colors.white54,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: isEnabled ? Colors.white : Colors.white54,
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isEnabled ? kPrimaryColor : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }


  Widget _buildStatItem({required IconData icon, required String label, required String value}) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ---UNCHANGED WIDGETS---
  Widget _buildAnimatedCircle(int index, double scale, double opacity, double maxDiameter) {
    final bool isActive = index == currentPage;
    return Center(
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: maxDiameter,
            height: maxDiameter,
            decoration: BoxDecoration(
              color: kCircleColor,
              shape: BoxShape.circle,
              border: isActive ? Border.all(color: kPrimaryColor.withOpacity(0.8), width: 2) : null,
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(Icons.image, color: Colors.grey[600], size: 40),
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
                        '${24 + index * 3}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerformanceList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.play_circle_filled,
                  color: kPrimaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Video ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recorded: ${DateTime.now().subtract(Duration(days: index)).day}/${DateTime.now().month}/${DateTime.now().year}',
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
    );
  }
}

class BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.45);
    path.quadraticBezierTo(
        size.width * 0.5, size.height * 0.8, size.width, size.height * 0.55);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}