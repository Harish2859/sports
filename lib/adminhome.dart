import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'adminprofile.dart';
import 'adminevents.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    AdminDashboard(),
    // Removed AdminCoursePage
    AdminEventsPage(),
    AdminProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          // Removed Add Course tab
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Add Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with TickerProviderStateMixin {
  late AnimationController _themeController;
  Animation<double>? _themeExpandAnimation;
  Animation<double>? _floatingAnimation;
  bool _isThemeExpanded = false;

  @override
  void initState() {
    super.initState();
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
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.sports_soccer,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Coach Portal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Findrly - Empowering Talent',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Color(0xFF2563EB)),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Color(0xFF2563EB)),
              title: const Text('Manage Athletes'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Athletes management
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Color(0xFF2563EB)),
              title: const Text('Training Schedule'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Training Schedule
              },
            ),
            ListTile(
              leading: const Icon(Icons.assessment, color: Color(0xFF2563EB)),
              title: const Text('Performance Analytics'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Performance Analytics
              },
            ),
            ListTile(
              leading: const Icon(Icons.event, color: Color(0xFF2563EB)),
              title: const Text('Competitions'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Competitions
              },
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center, color: Color(0xFF2563EB)),
              title: const Text('Equipment Management'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Equipment Management
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_services, color: Color(0xFF2563EB)),
              title: const Text('Health & Safety'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Health & Safety
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Color(0xFF2563EB)),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Reports
              },
            ),
            const Divider(),
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
                                  color: const Color(0xFF2563EB),
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
              leading: const Icon(Icons.settings, color: Color(0xFF2563EB)),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Findrly',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Admin Dashboard',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // Handle notifications
            },
          ),
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ),
    );
  }
}

class AddCoursePage extends StatelessWidget {
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
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.sports_soccer,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Coach Portal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Findrly - Empowering Talent',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Color(0xFF2563EB)),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Color(0xFF2563EB)),
              title: const Text('Manage Athletes'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Color(0xFF2563EB)),
              title: const Text('Training Schedule'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.assessment, color: Color(0xFF2563EB)),
              title: const Text('Performance Analytics'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event, color: Color(0xFF2563EB)),
              title: const Text('Competitions'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center, color: Color(0xFF2563EB)),
              title: const Text('Equipment Management'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_services, color: Color(0xFF2563EB)),
              title: const Text('Health & Safety'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Color(0xFF2563EB)),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF2563EB)),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Findrly',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Add Course',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // Handle notifications
            },
          ),
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Text(
          'Add Course Page',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ),
    );
  }
}

class UploadEventPage extends StatelessWidget {
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
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.sports_soccer,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Coach Portal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Findrly - Empowering Talent',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Color(0xFF2563EB)),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Color(0xFF2563EB)),
              title: const Text('Manage Athletes'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Color(0xFF2563EB)),
              title: const Text('Training Schedule'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.assessment, color: Color(0xFF2563EB)),
              title: const Text('Performance Analytics'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event, color: Color(0xFF2563EB)),
              title: const Text('Competitions'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center, color: Color(0xFF2563EB)),
              title: const Text('Equipment Management'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_services, color: Color(0xFF2563EB)),
              title: const Text('Health & Safety'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Color(0xFF2563EB)),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF2563EB)),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Findrly',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Upload Event',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // Handle notifications
            },
          ),
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Text(
          'Upload Event Page',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ),
    );
  }
}
