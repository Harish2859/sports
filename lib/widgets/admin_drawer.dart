import 'package:flutter/material.dart';
import '../admin_leaderboard_page.dart';
import '../admin_community_page.dart';
import '../screens/admin_home_screen.dart';
import '../screens/admin_events_view_page.dart';
import '../screens/admin_modules_page.dart';
import '../screens/admin_dashboard.dart';
import '../admin_event_management_page.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            leading: Icon(Icons.home, color: Theme.of(context).primaryColor),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.dashboard, color: Theme.of(context).primaryColor),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminDashboard()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.event, color: Theme.of(context).primaryColor),
            title: const Text('Events'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminEventsViewPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.school, color: Theme.of(context).primaryColor),
            title: const Text('Modules'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminModulesPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people, color: Theme.of(context).primaryColor),
            title: const Text('Community'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminCommunityPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.leaderboard, color: Theme.of(context).primaryColor),
            title: const Text('Leaderboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LeaderboardPage()),
              );
            },
          ),

          const Divider(),
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
    );
  }
}