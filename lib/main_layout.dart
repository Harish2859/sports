import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'notification_manager.dart';
import 'notifications_page.dart';
import 'theme_provider.dart';

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
    setState(() {
      _currentIndex = index;
    });
    widget.onTabChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor, // Sports theme color
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.sports_soccer,
                    size: 48,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sports Hub',
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
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.sports_soccer),
              title: const Text('Leagues'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Leagues page
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_basketball),
              title: const Text('Teams'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Teams page
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_baseball),
              title: const Text('Matches'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Matches page
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Statistics'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Statistics page
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
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

                    // Gamified Theme Button
                    AnimatedBuilder(
                      animation: _themeController,
                      builder: (context, child) {
                        final expandValue = (_themeExpandAnimation?.value ?? 0).clamp(0.0, 1.0);
                        final offset = Offset(
                          80 * expandValue * math.cos(-math.pi / 6),
                          80 * expandValue * math.sin(-math.pi / 6) - 20 * (_floatingAnimation?.value ?? 0),
                        );
                        return Transform.translate(
                          offset: offset,
                          child: Transform.scale(
                            scale: expandValue,
                            child: Opacity(
                              opacity: expandValue,
                              child: GestureDetector(
                                onTap: () {
                                  Provider.of<ThemeProvider>(context, listen: false).setGamifiedTheme();
                                  _toggleThemeMenu();
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
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
                                    Icons.games,
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
             ListTile(
               leading: const Icon(Icons.settings),
               title: const Text('Settings'),
               onTap: () {
                 Navigator.pop(context);
                 // TODO: Navigate to Settings page
               },
             ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Provider.of<ThemeProvider>(context).isGamified 
            ? Colors.transparent 
            : null,
        flexibleSpace: Provider.of<ThemeProvider>(context).isGamified
            ? Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1a237e), Color(0xFF000000)],
                  ),
                ),
              )
            : null,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Findrly',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Provider.of<ThemeProvider>(context).isGamified 
                    ? Colors.white 
                    : Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            Text(
              'Empowering Your Fair Quest for Talent',
              style: TextStyle(
                fontSize: 12,
                color: Provider.of<ThemeProvider>(context).isGamified 
                    ? Colors.white70 
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w400,
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
                  color: Provider.of<ThemeProvider>(context).isGamified 
                      ? Colors.white 
                      : Theme.of(context).iconTheme.color,
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
              // Handle messages
            },
            icon: Icon(
              Icons.message_outlined,
              color: Provider.of<ThemeProvider>(context).isGamified 
                  ? Colors.white 
                  : Theme.of(context).iconTheme.color,
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
                color: Provider.of<ThemeProvider>(context).isGamified 
                    ? Colors.white 
                    : Theme.of(context).iconTheme.color,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: Provider.of<ThemeProvider>(context).isGamified
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1a237e), Color(0xFF000000)],
                ),
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white.withOpacity(0.7),
                elevation: 0,
                currentIndex: _currentIndex < 0 ? 0 : _currentIndex,
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
                    label: 'Course',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            )
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex < 0 ? 0 : _currentIndex,
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
                  label: 'Course',
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
