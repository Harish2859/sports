import 'package:flutter/material.dart';
import 'daily_tasks_screen.dart';
import 'dart:math' as math;

// Solo Leveling inspired color scheme
const Color kBackgroundColor = Color(0xFF0D0A1C);
const Color kCardBackgroundColor = Color(0xFF16112A);
const Color kPrimaryColor = Color(0xFFC964EC);
const Color kGlowColor = Color(0xFFC964EC);
const Color kSecondaryTextColor = Color(0xFF8E88A3);
const Color kCircleColor = Color(0xFF2A1F3D);
const Color kArcColor = Color(0xFF00C6E0);

class ProfileStructureScreen extends StatefulWidget {
  const ProfileStructureScreen({super.key});

  @override
  State<ProfileStructureScreen> createState() => _ProfileStructureScreenState();
}

class _ProfileStructureScreenState extends State<ProfileStructureScreen> with TickerProviderStateMixin {
  int currentPage = 0;
  bool showPostsSection = false;
  int _currentBadgeIndex = 0;
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _breathingAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    _startBadgeLoop();
  }

  final List<Map<String, dynamic>> _pageData = [
    {
      'title': 'HUNTER PROFILE',
      'content': {
        'Name': 'Shadow Hunter',
        'Class': 'S-Rank Hunter',
        'Guild': 'Solo Leveling',
        'Email': 'shadow@hunter.com',
        'Phone': '+1 234 567 8900',
        'Location': 'Seoul, Korea',
        'JoinDate': 'Jan 2024',
        'Level': 87,
        'Mana': 2450,
        'Strength': 156,
        'Agility': 142,
        'Intelligence': 189,
        'Vitality': 134,
      }
    },
    {
      'title': 'BODY STATS',
      'content': {
        'HeartRate': 72,
        'Steps': 8540,
        'Hydration': 2.1,
        'Weight': 75.5,
        'Height': 180,
        'Strength': 85,
      }
    },
    {
      'title': 'EXPERIENCE POINTS',
      'content': {
        'About': 'Hunter experience and progression.',
        'XP': 1240,
        'MaxXP': 2000,
        'NextLevel': 760,
        'TotalXP': 45680,
      }
    },
    {
      'title': 'DAILY PROGRESS',
      'content': {
        'CurrentStreak': 7,
        'LongestStreak': 14,
        'TasksCompletedToday': 3,
        'TotalTasksToday': 5,
        'LastCompletedTime': '2h ago',
        'ActivityLog': [
          {'day': 'MON', 'date': '15', 'completed': true},
          {'day': 'TUE', 'date': '16', 'completed': true},
          {'day': 'WED', 'date': '17', 'completed': true},
          {'day': 'THU', 'date': '18', 'completed': false},
          {'day': 'FRI', 'date': '19', 'completed': true},
          {'day': 'SAT', 'date': '20', 'completed': true},
          {'day': 'SUN', 'date': '21', 'completed': false},
        ]
      }
    },
    {
      'title': 'ACHIEVEMENTS',
      'content': {
        'League': 'Shadow Monarch League',
        'Badges': [
          {
            'name': 'Iron Will Conqueror',
            'image': 'assets/images/dbi.png',
            'story': 'The hunter who never yields, forged in the fires of determination. Your unwavering spirit has earned you this legendary badge.',
          },
          {
            'name': 'Velocity Master',
            'image': 'assets/images/dimond.png',
            'story': 'Swift as lightning, precise as thunder. You have mastered the art of speed and earned the respect of all hunters.',
          },
          {
            'name': 'Shadow Sovereign',
            'image': 'assets/images/champ.png',
            'story': 'From the depths of darkness, you have risen to command the shadows themselves. A true master of the hunt.',
          },
        ],
      }
    },
    {
      'title': 'SKILLS & ABILITIES',
      'content': {
        'About': 'Unlocked skills and their levels.',
        'Shadow Extraction': 'MAX',
        'Shadow Exchange': 'Level 8',
        'Shadow Preserve': 'Level 6',
        'Ruler\'s Authority': 'Level 4',
      }
    },
  ];

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  void _startBadgeLoop() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _currentBadgeIndex = (_currentBadgeIndex + 1) % 3;
        });
        _startBadgeLoop();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hunter Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: kPrimaryColor,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),

      body: Stack(
        alignment: Alignment.center, // Center the main content
        children: [
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

            if (showPostsSection)
              DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.3,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  return Container(
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
                  );
                },
              ),
            if (!showPostsSection)
              Positioned(
                top: screenSize.height * 0.08,
                bottom: 80,
                left: 0,
                right: 0,
                child: PageView.builder(
                  itemCount: _pageData.length,
                  controller: PageController(viewportFraction: 0.9),
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.symmetric(
                        horizontal: index == currentPage ? 8 : 16,
                        vertical: index == currentPage ? 0 : 20,
                      ),
                      child: Transform.scale(
                        scale: index == currentPage ? 1.0 : 0.9,
                        child: _buildPageContent(index),
                      ),
                    );
                  },
                ),
              ),
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: _showProfileOptions,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2C2C2C),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
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

  Widget _buildPageContent(int index) {
    if (index < 0 || index >= _pageData.length) {
      return const SizedBox.shrink();
    }
    
    final data = _pageData[index];
    final title = data['title'] as String;
    final content = data['content'] as Map<String, dynamic>;
    final Size screenSize = MediaQuery.of(context).size;

    return Container(
      key: ValueKey<String>(title),
      width: screenSize.width * 0.9,
      child: switch (title) {
        'HUNTER PROFILE' => _buildHunterProfileCard(content),
        'BODY STATS' => _buildBodyStatsCard(content),
        'EXPERIENCE POINTS' => _buildExperienceCard(content),
        'DAILY PROGRESS' => _buildDailyProgressCard(content),
        'ACHIEVEMENTS' => _buildAchievementsCard(content),
        'SKILLS & ABILITIES' => _buildSkillsCard(content),
        _ => const SizedBox.shrink(),
      },
    );
  }

// SOLO LEVELING THEMED CARDS

  Widget _buildHunterProfileCard(Map<String, dynamic> content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: kGlowColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Section: Avatar and Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHunterAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content['Name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        content['Class'],
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Guild: ${content['Guild']}',
                        style: TextStyle(
                          color: kSecondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Middle Section: Stats Grid
            _buildHunterStatGrid(content),
            const SizedBox(height: 24),
            // Bottom Section: Profile Details
            _buildProfileDetails(content),
          ],
        ),
      );
  }

  Widget _buildHunterAvatar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            kPrimaryColor.withOpacity(0.8),
            kGlowColor.withOpacity(0.8),
            kPrimaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: CircleAvatar(
        radius: 40,
        backgroundColor: kCardBackgroundColor,
        child: CircleAvatar(
          radius: 36,
          backgroundColor: kPrimaryColor.withOpacity(0.2),
          child: Icon(
            Icons.person,
            color: kPrimaryColor,
            size: 40,
          ),
        ),
      ),
    );
  }
  
  Widget _buildXpBar(int currentXp, int maxXp) {
    double progress = (currentXp / maxXp).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "XP",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              "$currentXp / $maxXp",
              style: TextStyle(
                color: kSecondaryTextColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: kBackgroundColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: kGlowColor.withOpacity(0.7),
                            blurRadius: 8.0,
                            spreadRadius: 1.0,
                          ),
                        ]
                      ),
                    );
                  }
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHunterStatGrid(Map<String, dynamic> content) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildHunterStatItem('Level', content['Level'].toString(), Icons.star)),
            Expanded(child: _buildHunterStatItem('STR', content['Strength'].toString(), Icons.fitness_center)),
            Expanded(child: _buildHunterStatItem('AGI', content['Agility'].toString(), Icons.speed)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildHunterStatItem('INT', content['Intelligence'].toString(), Icons.psychology)),
            Expanded(child: _buildHunterStatItem('VIT', content['Vitality'].toString(), Icons.favorite)),
            Expanded(child: _buildHunterStatItem('Mana', content['Mana'].toString(), Icons.auto_awesome)),
          ],
        ),
      ],
    );
  }

  Widget _buildHunterStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: kBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: kPrimaryColor, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: kSecondaryTextColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // OTHER THEMED CARDS

  Widget _buildBodyStatsCard(Map<String, dynamic> content) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _breathingAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _breathingAnimation.value,
                    child: Image.asset(
                      'assets/images/3d_human.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: kCardBackgroundColor,
                          child: Icon(
                            Icons.person,
                            color: kPrimaryColor.withOpacity(0.6),
                            size: 180,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: [
                  Text(
                    'BODY STATS',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: kGlowColor.withOpacity(0.7),
                          blurRadius: 10.0,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildBodyStatItem(Icons.favorite_border, '${content['HeartRate']}', 'bpm'),
                              _buildBodyStatItem(Icons.directions_walk, '${content['Steps']}', 'steps'),
                              _buildBodyStatItem(Icons.water_drop_outlined, '${content['Hydration']}L', 'hydration'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 120),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildBodyStatItem(Icons.scale_outlined, '${content['Weight']}kg', 'weight'),
                              _buildBodyStatItem(Icons.height, '${content['Height']}cm', 'height'),
                              _buildBodyStatItem(Icons.fitness_center, '${content['Strength']}%', 'strength'),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyStatItem(IconData icon, String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kPrimaryColor, size: 30, shadows: [
            Shadow(
              color: kGlowColor.withOpacity(0.9),
              blurRadius: 15.0,
            )
          ]),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (label.isNotEmpty)
            Text(
              label,
              style: const TextStyle(color: kSecondaryTextColor, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(Map<String, dynamic> content) {
    final int currentXp = content['XP'] as int;
    final int maxXp = content['MaxXP'] as int;
    final double progress = (currentXp / maxXp).clamp(0.0, 1.0);
    final int minXpForLevel = 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 280,
            width: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CustomPaint(
                    painter: ExperienceArcPainter(
                      progress: progress,
                      backgroundColor: kCircleColor,
                      progressColor: kPrimaryColor,
                      strokeWidth: 18,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 10,
                  child: Text(
                    minXpForLevel.toString(),
                    style: TextStyle(color: kSecondaryTextColor, fontSize: 14),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 10,
                  child: Text(
                    maxXp.toString(),
                    style: TextStyle(color: kSecondaryTextColor, fontSize: 14),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _breathingAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _breathingAnimation.value,
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimaryColor.withOpacity(0.5),
                                  blurRadius: 30 * _breathingAnimation.value,
                                  spreadRadius: 8 * _breathingAnimation.value,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/dimond.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.diamond,
                                    color: kPrimaryColor,
                                    size: 60,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentXp.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'XP',
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Top Player',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Current Rank',
            style: TextStyle(
              color: kSecondaryTextColor,
              fontSize: 14,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: kSecondaryTextColor, height: 1),
          ),
          InkWell(
            onTap: () {},
            child: Row(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 32),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rankings',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'All Ranks',
                      style: TextStyle(color: kSecondaryTextColor, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, color: kSecondaryTextColor, size: 16),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDailyProgressCard(Map<String, dynamic> content) {
    final int currentStreak = content['CurrentStreak'] as int;
    final int longestStreak = content['LongestStreak'] as int;
    final int tasksCompletedToday = content['TasksCompletedToday'] as int;
    final int totalTasksToday = content['TotalTasksToday'] as int;
    final String lastCompletedTime = content['LastCompletedTime'] as String;
    final List<Map<String, dynamic>> activityLog = content['ActivityLog'] as List<Map<String, dynamic>>;

    double progress = (tasksCompletedToday / totalTasksToday).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: kGlowColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DAILY PROGRESS',
            style: TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: kGlowColor.withOpacity(0.7),
                  blurRadius: 10.0,
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: SpeedometerPainter(
                  progress: progress,
                  backgroundColor: kCircleColor,
                  progressColor: kPrimaryColor,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$tasksCompletedToday',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '/ $totalTasksToday',
                        style: TextStyle(
                          color: kSecondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Last activity: $lastCompletedTime',
            style: TextStyle(color: kSecondaryTextColor.withOpacity(0.8), fontSize: 12),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.local_fire_department,
                label: 'Current Streak',
                value: '$currentStreak days',
              ),
              _buildStatItem(
                icon: Icons.stacked_line_chart,
                label: 'Longest Streak',
                value: '$longestStreak days',
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            'Activity Log',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: activityLog.length,
              itemBuilder: (context, index) {
                final dayData = activityLog[index];
                final bool completed = dayData['completed'] as bool;
                final String day = dayData['day'] as String;
                final String date = dayData['date'] as String;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: completed
                        ? LinearGradient(
                            colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: completed ? null : kCardBackgroundColor,
                    boxShadow: completed
                        ? [
                            BoxShadow(
                              color: kPrimaryColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: completed ? Colors.white70 : kSecondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: completed ? Colors.white : kSecondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsCard(Map<String, dynamic> content) {
    final badges = content['Badges'] as List<Map<String, dynamic>>;
    final league = content['League'] as String;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: kGlowColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            league,
            style: TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1,
              shadows: [
                Shadow(
                  color: kGlowColor.withOpacity(0.7),
                  blurRadius: 10.0,
                )
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.3, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    )),
                    child: child,
                  ),
                );
              },
              child: Column(
                key: ValueKey(_currentBadgeIndex),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _breathingAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _breathingAnimation.value,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                kPrimaryColor.withOpacity(0.8),
                                kPrimaryColor.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: kPrimaryColor.withOpacity(0.6),
                                blurRadius: 50 * _breathingAnimation.value,
                                spreadRadius: 12 * _breathingAnimation.value,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              badges[_currentBadgeIndex]['image'] as String,
                              width: 120,
                              height: 120,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 90,
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    badges[_currentBadgeIndex]['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      badges[_currentBadgeIndex]['story'] as String,
                      style: TextStyle(
                        color: kSecondaryTextColor,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              badges.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == _currentBadgeIndex ? kPrimaryColor : kSecondaryTextColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard(Map<String, dynamic> content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SKILLS & ABILITIES',
            style: TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          _buildSkillItem('Shadow Extraction', content['Shadow Extraction']),
          _buildSkillItem('Shadow Exchange', content['Shadow Exchange']),
          _buildSkillItem('Shadow Preserve', content['Shadow Preserve']),
          _buildSkillItem('Ruler\'s Authority', content['Ruler\'s Authority']),
        ],
      ),
    );
  }

  Widget _buildActivityStat(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: kPrimaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItem(IconData icon, String count) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kPrimaryColor, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillItem(String skill, String level) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: level == 'MAX' ? Colors.amber : kPrimaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              skill,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Text(
            level,
            style: TextStyle(
              color: level == 'MAX' ? Colors.amber : kPrimaryColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 20),
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
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[600]!, width: 1),
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





class ExperienceArcPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  ExperienceArcPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    this.strokeWidth = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    const startAngle = 3 * math.pi / 4;
    const sweepAngle = 3 * math.pi / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, backgroundPaint);
    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class SpeedometerPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  SpeedometerPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    const startAngle = math.pi;
    const sweepAngle = math.pi;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [progressColor.withOpacity(0.6), progressColor],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, backgroundPaint);
    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, progressPaint);

    // Draw needle
    final needleAngle = startAngle + (sweepAngle * progress);
    final needleLength = radius - 10;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = progressColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);
    canvas.drawCircle(center, 4, Paint()..color = progressColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
  Widget _buildProfileDetails(Map<String, dynamic> content) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDetailItem('Email', content['Email'], Icons.email)),
            Expanded(child: _buildDetailItem('Phone', content['Phone'], Icons.phone)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDetailItem('Location', content['Location'], Icons.location_on)),
            Expanded(child: _buildDetailItem('Joined', content['JoinDate'], Icons.calendar_today)),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: kBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: kSecondaryTextColor,
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String taskName, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? Colors.green : kSecondaryTextColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              taskName,
              style: TextStyle(
                color: completed ? Colors.white : kSecondaryTextColor,
                fontSize: 14,
                decoration: completed ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }


