import 'package:flutter/material.dart';
import '../models/fraud_user_model.dart';

class AdminLeaderboardScreen extends StatefulWidget {
  const AdminLeaderboardScreen({super.key});

  @override
  State<AdminLeaderboardScreen> createState() => _AdminLeaderboardScreenState();
}

class _AdminLeaderboardScreenState extends State<AdminLeaderboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  final List<LeaderboardUser> maleUsers = [
    LeaderboardUser(id: '1', name: 'Alex Champion', gender: 'male', score: 5420, profileImage: 'assets/images/champ.png'),
    LeaderboardUser(id: '2', name: 'Mike Strong', gender: 'male', score: 5100, profileImage: 'assets/images/intermediate.png'),
    LeaderboardUser(id: '3', name: 'David Wilson', gender: 'male', score: 4890, profileImage: 'assets/images/beginner.png'),
    LeaderboardUser(id: '4', name: 'John Runner', gender: 'male', score: 4750, profileImage: 'assets/images/silver.png'),
    LeaderboardUser(id: '5', name: 'Tom Athlete', gender: 'male', score: 4600, profileImage: 'assets/images/ruby.png'),
  ];

  final List<LeaderboardUser> femaleUsers = [
    LeaderboardUser(id: '6', name: 'Sarah Runner', gender: 'female', score: 5200, profileImage: 'assets/images/champ.png'),
    LeaderboardUser(id: '7', name: 'Emma Brown', gender: 'female', score: 4910, profileImage: 'assets/images/intermediate.png'),
    LeaderboardUser(id: '8', name: 'Lisa Garcia', gender: 'female', score: 4880, profileImage: 'assets/images/beginner.png'),
    LeaderboardUser(id: '9', name: 'Anna Swift', gender: 'female', score: 4720, profileImage: 'assets/images/silver.png'),
    LeaderboardUser(id: '10', name: 'Kate Power', gender: 'female', score: 4650, profileImage: 'assets/images/ruby.png'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _scaleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(begin: -0.2, end: 0.2).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Leaderboard'),
        backgroundColor: Colors.amber,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.admin_panel_settings),
            onSelected: (value) {
              if (value == 'export') {
                _exportLeaderboard();
              } else if (value == 'reset') {
                _resetRankings();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Reset Rankings'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Male Champions', icon: Icon(Icons.male)),
            Tab(text: 'Female Champions', icon: Icon(Icons.female)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboard(maleUsers, Colors.blue, 'Male'),
          _buildLeaderboard(femaleUsers, Colors.pink, 'Female'),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(List<LeaderboardUser> users, Color accentColor, String gender) {
    final topThree = users.take(3).toList();
    
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '🏆 $gender Champions Podium 🏆',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (topThree.length > 1) _buildPodiumCard(topThree[1], 2, accentColor),
                      const SizedBox(width: 16),
                      if (topThree.isNotEmpty) _buildPodiumCard(topThree[0], 1, accentColor),
                      const SizedBox(width: 16),
                      if (topThree.length > 2) _buildPodiumCard(topThree[2], 3, accentColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Full Rankings',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _manageUser(gender),
                      icon: const Icon(Icons.person_add, size: 16),
                      label: const Text('Manage'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...users.asMap().entries.map((entry) {
                  final index = entry.key;
                  final user = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildUserCard(user, index + 1, accentColor),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumCard(LeaderboardUser user, int rank, Color accentColor) {
    final heights = {1: 120.0, 2: 100.0, 3: 80.0};
    final colors = {
      1: [const Color(0xFFFFD700), const Color(0xFFFFA500)],
      2: [const Color(0xFFC0C0C0), const Color(0xFF808080)],
      3: [const Color(0xFFCD7F32), const Color(0xFF8B4513)],
    };

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors[rank]![0],
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              if (rank == 1)
                const Icon(
                  Icons.sports_kabaddi,
                  color: Color(0xFFFFD700),
                  size: 24,
                ),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        user.profileImage,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.emoji_events,
                            color: colors[rank]![0],
                            size: 24,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${user.score} XP',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: heights[rank]!,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors[rank]!,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(LeaderboardUser user, int rank, Color accentColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _getRankColor(rank),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: rank <= 3 ? Colors.white : Colors.black,
                ),
              ),
              if (rank <= 3)
                Icon(
                  _getRankIcon(rank),
                  size: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
            ],
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Gender: ${user.gender} • ${user.score} XP'),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'view') {
              _viewUserDetails(user);
            } else if (value == 'edit') {
              _editUser(user);
            } else if (value == 'remove') {
              _removeUser(user);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit Score'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Remove', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return const Color(0xFFFFD700);
      case 2: return const Color(0xFFC0C0C0);
      case 3: return const Color(0xFFCD7F32);
      default: return Colors.grey.shade300;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1: return Icons.emoji_events;
      case 2: return Icons.military_tech;
      case 3: return Icons.workspace_premium;
      default: return Icons.star;
    }
  }

  void _exportLeaderboard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.download, color: Colors.white),
            SizedBox(width: 8),
            Text('Leaderboard data exported successfully!'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _resetRankings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Rankings'),
        content: const Text('Are you sure you want to reset all rankings? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rankings reset successfully!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _manageUser(String gender) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Managing $gender users...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _viewUserDetails(LeaderboardUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${user.id}'),
            Text('Gender: ${user.gender}'),
            Text('Score: ${user.score} XP'),
            Text('Profile: ${user.profileImage}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editUser(LeaderboardUser user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing ${user.name}...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _removeUser(LeaderboardUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove User'),
        content: Text('Are you sure you want to remove ${user.name} from the leaderboard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.name} removed from leaderboard'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}