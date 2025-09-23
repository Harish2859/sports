import 'package:flutter/material.dart';

class ModuleDetailPage extends StatefulWidget {
  final Map<String, dynamic> module;
  
  const ModuleDetailPage({super.key, required this.module});

  @override
  State<ModuleDetailPage> createState() => _ModuleDetailPageState();
}

class _ModuleDetailPageState extends State<ModuleDetailPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.module['title'] ?? 'Sports Module'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotificationDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportReports(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Module Image Card
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  widget.module['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.green,
                      child: const Icon(
                        Icons.sports,
                        color: Colors.white,
                        size: 60,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Module Header Section
            _buildModuleHeader(context),
            const SizedBox(height: 20),
            
            // Enrollment Stats Card
            _buildEnrollmentStats(context),
            const SizedBox(height: 20),
            
            // Filter Bar
            _buildFilterBar(context),
            const SizedBox(height: 20),
            
            // Leaderboard Section
            _buildLeaderboardSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.module['title'] ?? 'Football Training',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Season 2024 - Advanced Level',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildQuickStat('Enrollments', '156', Icons.people, Colors.white),
                _buildQuickStat('Active Players', '142', Icons.sports, Colors.white),
                _buildQuickStat('Sessions', '28', Icons.event, Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color.withOpacity(0.8), size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentStats(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enrollment Distribution',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.manage_accounts, size: 20),
                  label: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildGenderStat('Male', '89', const Color(0xFF2196F3), 0.57),
                _buildGenderStat('Female', '58', const Color(0xFFE91E63), 0.37),
                _buildGenderStat('Trans', '9', const Color(0xFFFF9800), 0.06),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderStat(String gender, String count, Color color, double percentage) {
    return Expanded(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(
                  value: percentage,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeWidth: 6,
                ),
              ),
              Text(
                count,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            gender,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final filters = ['All', 'This Week', 'This Month', 'Top Performers'];
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            const Icon(Icons.filter_list, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filters.map((filter) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(filter),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = selected ? filter : 'All';
                        });
                      },
                      selectedColor: const Color(0xFF2E7D32).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF2E7D32),
                    ),
                  )).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Leaderboard',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Male'),
              Tab(text: 'Female'),
              Tab(text: 'Trans'),
            ],
            labelColor: const Color(0xFF2E7D32),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF2E7D32),
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboardList(_getMaleLeaders()),
                _buildLeaderboardList(_getFemaleLeaders()),
                _buildLeaderboardList(_getTransLeaders()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(List<Map<String, dynamic>> leaders) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaders.length,
      itemBuilder: (context, index) {
        final leader = leaders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: index < 3 ? _getMedalColor(index).withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: index < 3 ? _getMedalColor(index) : Colors.grey.withOpacity(0.3),
              width: index < 3 ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Rank
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: index < 3 ? _getMedalColor(index) : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: index < 3
                      ? Text(
                          _getMedalEmoji(index),
                          style: const TextStyle(fontSize: 20),
                        )
                      : Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: Text(
                  leader['name'][0],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              
              // Name and Team
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leader['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      leader['team'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              // Score
              Column(
                children: [
                  Text(
                    '${leader['score']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const Text(
                    'points',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }



  Color _getMedalColor(int index) {
    switch (index) {
      case 0: return const Color(0xFFFFD700); // Gold
      case 1: return const Color(0xFFC0C0C0); // Silver
      case 2: return const Color(0xFFCD7F32); // Bronze
      default: return Colors.grey;
    }
  }

  String _getMedalEmoji(int index) {
    switch (index) {
      case 0: return '🥇';
      case 1: return '🥈';
      case 2: return '🥉';
      default: return '';
    }
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Notification'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification sent!')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _exportReports(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Export Reports',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF export started!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Export as CSV'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CSV export started!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Mock data methods
  List<Map<String, dynamic>> _getMaleLeaders() {
    return [
      {'name': 'Alex Johnson', 'team': 'Thunder Hawks', 'score': 2450},
      {'name': 'Marcus Smith', 'team': 'Lightning Bolts', 'score': 2380},
      {'name': 'David Chen', 'team': 'Fire Dragons', 'score': 2290},
      {'name': 'James Wilson', 'team': 'Storm Eagles', 'score': 2150},
      {'name': 'Ryan Martinez', 'team': 'Thunder Hawks', 'score': 2080},
    ];
  }

  List<Map<String, dynamic>> _getFemaleLeaders() {
    return [
      {'name': 'Sarah Williams', 'team': 'Lightning Bolts', 'score': 2390},
      {'name': 'Emma Thompson', 'team': 'Fire Dragons', 'score': 2320},
      {'name': 'Olivia Davis', 'team': 'Storm Eagles', 'score': 2280},
      {'name': 'Sophia Brown', 'team': 'Thunder Hawks', 'score': 2190},
      {'name': 'Isabella Garcia', 'team': 'Lightning Bolts', 'score': 2140},
    ];
  }

  List<Map<String, dynamic>> _getTransLeaders() {
    return [
      {'name': 'Taylor Jordan', 'team': 'Storm Eagles', 'score': 2340},
      {'name': 'Casey Morgan', 'team': 'Fire Dragons', 'score': 2220},
      {'name': 'Alex Rivera', 'team': 'Thunder Hawks', 'score': 2180},
      {'name': 'Jamie Parker', 'team': 'Lightning Bolts', 'score': 2090},
      {'name': 'Riley Cooper', 'team': 'Storm Eagles', 'score': 2010},
    ];
  }


}