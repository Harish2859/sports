import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'notification_manager.dart';
import 'notifications_page.dart';
import 'theme_provider.dart';
import 'app_state.dart';
import 'my_courses_page.dart';
import 'performance_videos_page.dart';
import 'my_certificates_page.dart';
import 'leaderboard.dart';
import 'community_page.dart';
import 'screens/nutrition_screen.dart';
import 'gamification_screen.dart';
import 'message_page.dart';

class MainLayout extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabChanged;
  final Widget child;

  const MainLayout({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.child,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _themeController;
  Animation<double>? _themeExpandAnimation;
  Animation<double>? _floatingAnimation;
  bool _isThemeExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;

    _themeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _themeExpandAnimation = CurvedAnimation(
      parent: _themeController,
      curve: Curves.elasticOut,
    );

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _themeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  void _toggleThemeMenu() {
    setState(() {
      _isThemeExpanded = !_isThemeExpanded;
    });

    if (_isThemeExpanded) {
      _themeController.forward();
    } else {
      _themeController.reverse();
    }
  }

  void _handleTabChanged(int index) {
    if (index >= 0 && index < 5) {
      setState(() {
        _currentIndex = index;
      });
      widget.onTabChanged(index);
    }
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildCommunityPostsSection() {
    final samplePosts = [
      {
        'author': 'John Doe',
        'content': 'Just crushed my morning workout! 💪 Nothing beats that post-gym feeling.',
        'likes': 24,
        'time': '2h',
      },
      {
        'author': 'Mike Johnson',
        'content': '30-day transformation complete! 🙏 Lost 15 pounds and gained confidence.',
        'likes': 156,
        'time': '1h',
      },
      {
        'author': 'Lisa Chen',
        'content': 'Just launched my new AI-powered fitness app! 🚀 Beta testers wanted!',
        'likes': 67,
        'time': '6h',
      },
    ];

    return Container(
      height: 200,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: samplePosts.length,
        itemBuilder: (context, index) {
          final post = samplePosts[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.green,
                        child: Text(
                          post['author'].toString()[0],
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post['author'].toString(),
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                            Text(
                              post['time'].toString(),
                              style: TextStyle(color: Colors.grey[600], fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post['content'].toString(),
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.favorite_border, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${post['likes']}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Comment',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommunityProfilesSection() {
    final sampleProfiles = [
      {
        'name': 'Sports Enthusiasts',
        'members': 245,
        'description': 'Connect with fellow sports lovers',
        'icon': '🏆',
      },
      {
        'name': 'Fitness Goals',
        'members': 189,
        'description': 'Share your fitness journey',
        'icon': '💪',
      },
      {
        'name': 'Tech Innovators',
        'members': 156,
        'description': 'Latest in technology',
        'icon': '💻',
      },
    ];

    return Container(
      height: 180,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: sampleProfiles.length,
        itemBuilder: (context, index) {
          final profile = sampleProfiles[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green,
                child: Text(
                  profile['icon'].toString(),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              title: Text(
                profile['name'].toString(),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${profile['members']} members',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    profile['description'].toString(),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CommunityPage()),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: Drawer(
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
                    final themeProvider = Provider.of<ThemeProvider>(context);
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
                        const SizedBox(height: 4),
                        Text(
                          'Gender: ${appState.userGender}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              
              _buildDrawerItem(
                context,
                Icons.school,
                'My Modules',
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyCoursesPage()),
                  );
                },
              ),
              _buildDrawerItem(
                context,
                Icons.videocam_outlined,
                'Your Performance',
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PerformanceVideosPage()),
                  );
                },
              ),
              _buildDrawerItem(
                context,
                Icons.card_membership_outlined,
                'My Certificate',
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyCertificatesPage()),
                  );
                },
              ),
              _buildDrawerItem(
                context,
                Icons.leaderboard,
                'Leaderboard',
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LeaderboardPage()),
                  );
                },
              ),
              _buildDrawerItem(
                context,
                Icons.people,
                'Community',
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CommunityPage()),
                  );
                },
              ),
              _buildDrawerItem(
                context,
                Icons.games,
                'Gamification',
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GamificationScreen()),
                  );
                },
              ),
              _buildDrawerItem(
                context,
                Icons.restaurant_menu,
                'Nutrition',
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NutritionScreen()),
                  );
                },
              ),

              
              const Divider(),
              _buildDrawerItem(
                context,
                Icons.logout,
                'Logout',
                () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
                },
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Main Theme Button
                    Positioned(
                      child: GestureDetector(
                        onTap: () {
                          _toggleThemeMenu();
                        },
                        child: AnimatedBuilder(
                          animation: _themeController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _themeController.value * 3.1415 / 4,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.palette,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Day Theme Button
                    AnimatedBuilder(
                      animation: _themeController,
                      builder: (context, child) {
                        final expandValue = (_themeExpandAnimation?.value ?? 0).clamp(0.0, 1.0);
                        final offset = Offset(
                          80 * expandValue * math.cos(-math.pi / 2),
                          80 * expandValue * math.sin(-math.pi / 2) - 20 * (_floatingAnimation?.value ?? 0),
                        );
                        return Transform.translate(
                          offset: offset,
                          child: Transform.scale(
                            scale: expandValue,
                            child: Opacity(
                              opacity: expandValue,
                              child: GestureDetector(
                                onTap: () {
                                  Provider.of<ThemeProvider>(context, listen: false).setDayTheme();
                                  _toggleThemeMenu();
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.wb_sunny,
                                    color: Colors.black,
                                    size: 25,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Dark Theme Button
                    AnimatedBuilder(
                      animation: _themeController,
                      builder: (context, child) {
                        final expandValue = (_themeExpandAnimation?.value ?? 0).clamp(0.0, 1.0);
                        final offset = Offset(
                          80 * expandValue * math.cos(math.pi / 6),
                          80 * expandValue * math.sin(math.pi / 6) - 20 * (_floatingAnimation?.value ?? 0),
                        );
                        return Transform.translate(
                          offset: offset,
                          child: Transform.scale(
                            scale: expandValue,
                            child: Opacity(
                              opacity: expandValue,
                              child: GestureDetector(
                                onTap: () {
                                  Provider.of<ThemeProvider>(context, listen: false).setDarkTheme();
                                  _toggleThemeMenu();
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.nightlight_round,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
              _buildDrawerItem(
                context,
                Icons.settings,
                'Settings',
                () {
                  Navigator.pop(context);
                  // TODO: Navigate to Settings page
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Findrly',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  Text(
                    'Empowering Your Fair Quest for Talent',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).iconTheme.color,
                  size: 24,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: AnimatedBuilder(
                  animation: NotificationManager.instance,
                  builder: (context, child) {
                    final unreadCount = NotificationManager.instance.unreadCount;
                    if (unreadCount == 0) return const SizedBox.shrink();

                    return Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MessagePage()),
              );
            },
            icon: Icon(
              Icons.message_outlined,
              color: Theme.of(context).iconTheme.color,
              size: 24,
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(
                Icons.menu,
                color: Theme.of(context).iconTheme.color,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex.clamp(0, 4),
        onTap: _handleTabChanged,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Modules',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
