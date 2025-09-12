import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> with TickerProviderStateMixin {
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
              leading: Icon(Icons.dashboard, color: Theme.of(context).primaryColor),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.group, color: Theme.of(context).primaryColor),
              title: const Text('Manage Athletes'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.schedule, color: Theme.of(context).primaryColor),
              title: const Text('Training Schedule'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.assessment, color: Theme.of(context).primaryColor),
              title: const Text('Performance Analytics'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.event, color: Theme.of(context).primaryColor),
              title: const Text('Competitions'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.fitness_center, color: Theme.of(context).primaryColor),
              title: const Text('Equipment Management'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.medical_services, color: Theme.of(context).primaryColor),
              title: const Text('Health & Safety'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.bar_chart, color: Theme.of(context).primaryColor),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
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
                                  color: Theme.of(context).primaryColor,
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
                                  Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
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
              leading: Icon(Icons.settings, color: Theme.of(context).primaryColor),
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
              'Admin Profile',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Admin Info
            _buildAdminHeader(),
            
            const SizedBox(height: 20),
            
            // Quick Stats Cards
            _buildQuickStats(),
            
            const SizedBox(height: 20),
            
            // Main Action Buttons
            _buildMainActions(),
            
            const SizedBox(height: 20),
            
            // Analytics Dashboard
            _buildAnalyticsDashboard(),
            
            const SizedBox(height: 20),
            
            // Recent Activity & Notifications
            // Removed Management Sections and Recent Activity as per request
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Profile Picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).primaryColor, width: 3),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Icon(
              Icons.person,
              size: 50,
              color: Theme.of(context).primaryColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Admin Name & Title
          Text(
            'Coach Alex Thompson',
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            'Head Coach & Assessment Admin',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Contact Info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email, color: Theme.of(context).textTheme.bodyMedium?.color, size: 16),
              const SizedBox(width: 4),
              Text(
                'alex.thompson@findrly.com',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Bio
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Empowering athletes with AI-powered fair assessments and personalized training programs.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Active Modules', '12', Icons.school, const Color(0xFF059669))),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Total Athletes', '284', Icons.people, const Color(0xFF7C3AED))),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Certificates', '156', Icons.workspace_premium, const Color(0xFFDC2626))),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 2),
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

  Widget _buildMainActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildActionCard('modules Provided', Icons.library_books, const Color(0xFF059669), () {
                // Navigate to courses list
              }),
              _buildActionCard('Events Posted', Icons.calendar_month, const Color(0xFFDC2626), () {
                // Navigate to events list
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsDashboard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analytics Dashboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'AI Powered',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Analytics metrics
          Row(
            children: [
              Expanded(child: _buildMetric('Course Completion', '78%', Icons.trending_up, Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetric('Event Participation', '85%', Icons.people, Colors.blue)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetric('Avg Performance', '8.2/10', Icons.star, Colors.orange)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetric('AI Insights Generated', '342', Icons.psychology, Colors.purple)),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // AI Recommendations
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: Color(0xFF2563EB), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI Suggestion: Add agility drills to improve athlete performance gaps',
                    style: TextStyle(
                      color: const Color(0xFF2563EB),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildRecentActivity() {
    return Container();
  }



  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Handle logout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}