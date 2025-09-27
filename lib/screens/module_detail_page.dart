import 'package:flutter/material.dart';
import 'dart:math';
import '../constants/app_constants.dart';

class ModuleDetailPage extends StatefulWidget {
  final Map<String, dynamic> module;

  const ModuleDetailPage({super.key, required this.module});

  @override
  State<ModuleDetailPage> createState() => _ModuleDetailPageState();
}

class _ModuleDetailPageState extends State<ModuleDetailPage> {
  String _selectedFilter = 'All';
  String _selectedGender = 'Male';
  late List<Map<String, dynamic>> _currentLeaders;

  @override
  void initState() {
    super.initState();
    // Initialize with the default leaderboard
    _currentLeaders = _getMaleLeaders();
  }

  // Method to update the leaderboard based on gender selection
  void _updateLeaderboard(String? gender) {
    if (gender == null) return;
    setState(() {
      _selectedGender = gender;
      switch (gender) {
        case 'Male':
          _currentLeaders = _getMaleLeaders();
          break;
        case 'Female':
          _currentLeaders = _getFemaleLeaders();
          break;
        case 'Trans':
          _currentLeaders = _getTransLeaders();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      // Using CustomScrollView for a more dynamic scrolling experience (Slivers)
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 250.0,
            backgroundColor: Color(AppConstants.primaryColorValue),
            foregroundColor: Colors.white,
            elevation: 2,
            title: Text(widget.module['title'] ?? 'Sports Module'),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => _showNotificationDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.file_download_outlined),
                onPressed: () => _exportReports(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: _buildHeaderContent(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _buildEnrollmentStats(context),
                  const SizedBox(height: 20),
                  _buildFilterBar(context),
                  const SizedBox(height: 20),
                  _buildLeaderboardSection(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Combined header content for the SliverAppBar background
  Widget _buildHeaderContent(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(),
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: Image.asset(
                widget.module['image'],
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.4),
                colorBlendMode: BlendMode.darken,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.black.withOpacity(0.4));
                },
              ),
            ),
          ),
          // Gradient Overlay
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black54],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Text Content
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.module['title'] ?? 'Football Training',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [const Shadow(blurRadius: 8, color: Colors.black54)],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Season 2024 - Advanced Level',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEnrollmentStats(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enrollment Distribution',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
    return Column(
      children: [
        SizedBox(
          height: 70,
          width: 70,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: percentage),
            duration: const Duration(milliseconds: 1200),
            builder: (context, value, child) {
              return Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: value,
                    backgroundColor: color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Text(
                      count,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: color,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          gender,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final filters = ['All', 'This Week', 'This Month', 'Top Performers'];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          return ChoiceChip(
            label: Text(filter),
            selected: _selectedFilter == filter,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? filter : 'All';
              });
            },
            selectedColor: const Color(0xFF2E7D32),
            labelStyle: TextStyle(
              color: _selectedFilter == filter ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: _selectedFilter == filter ? Colors.transparent : Colors.grey.shade300,
              ),
            ),
            showCheckmark: false,
            elevation: 2,
            pressElevation: 5,
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
      ),
    );
  }

  Widget _buildLeaderboardSection(BuildContext context) {
    final theme = Theme.of(context);
    final topThree = _currentLeaders.take(3).toList();
    final others = _currentLeaders.skip(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Leaderboard Header with Dropdown ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Performance Leaderboard',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGender,
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2E7D32)),
                  items: ['Male', 'Female', 'Trans'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: _updateLeaderboard,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // --- AnimatedSwitcher for Smooth Transitions ---
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Column(
            key: ValueKey<String>(_selectedGender), // Key to trigger animation
            children: [
              // --- Top 3 Performers (Horizontal Scroll) ---
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: topThree.length,
                  itemBuilder: (context, index) {
                    return _buildTopPlayerCard(topThree[index], index);
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // --- Rest of the Leaderboard (Vertical List) ---
              Text(
                'All Players',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: others.length,
                itemBuilder: (context, index) {
                  return _buildLeaderboardListItem(others[index], index + 4);
                },
                separatorBuilder: (context, index) => const SizedBox(height: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopPlayerCard(Map<String, dynamic> leader, int index) {
    final rank = index + 1;
    final color = _getMedalColor(index);
    final emoji = _getMedalEmoji(index);

    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              leader['name'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              "${leader['score']} pts",
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardListItem(Map<String, dynamic> leader, int rank) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '$rank',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 22,
            backgroundColor: _getRandomColor(leader['name']),
            child: Text(
              leader['name'][0],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leader['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  leader['team'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${leader['score']}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMedalColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFD4AF37); // Gold
      case 1:
        return const Color(0xFFB4B8B9); // Silver
      case 2:
        return const Color(0xFFA97142); // Bronze
      default:
        return Colors.grey;
    }
  }

  String _getMedalEmoji(int index) {
    switch (index) {
      case 0:
        return '🥇';
      case 1:
        return '🥈';
      case 2:
        return '🥉';
      default:
        return '';
    }
  }
  
  Color _getRandomColor(String seed) {
    final random = Random(seed.hashCode);
    return Color.fromARGB(
      255,
      random.nextInt(200),
      random.nextInt(200),
      random.nextInt(200),
    );
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Send Notification'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'Message',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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

  // --- Mock Data Methods ---
  List<Map<String, dynamic>> _getMaleLeaders() {
    return [
      {'name': 'Alex Johnson', 'team': 'Thunder Hawks', 'score': 2450},
      {'name': 'Marcus Smith', 'team': 'Lightning Bolts', 'score': 2380},
      {'name': 'David Chen', 'team': 'Fire Dragons', 'score': 2290},
      {'name': 'James Wilson', 'team': 'Storm Eagles', 'score': 2150},
      {'name': 'Ryan Martinez', 'team': 'Thunder Hawks', 'score': 2080},
      {'name': 'Chris Lee', 'team': 'Fire Dragons', 'score': 1990},
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
      {'name': 'Drew Evans', 'team': 'Thunder Hawks', 'score': 1950},
    ];
  }
}