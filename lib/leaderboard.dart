import 'package:flutter/material.dart';
import 'main_layout.dart';
import 'myleague.dart';

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  String activeTab = 'global';
  String selectedLeague = 'all';

  final List<Map<String, dynamic>> users = [
    {
      'id': 1,
      'username': 'Alex Champion',
      'avatar': '🏆',
      'totalXP': 15420,
      'strength': 95,
      'stamina': 88,
      'agility': 92,
      'skills': 90,
      'isCurrentUser': false,
    },
    {
      'id': 2,
      'username': 'Sarah Runner',
      'avatar': '🏃♀️',
      'totalXP': 14850,
      'strength': 85,
      'stamina': 98,
      'agility': 89,
      'skills': 87,
      'isCurrentUser': false,
    },
    {
      'id': 3,
      'username': 'Mike Strong',
      'avatar': '💪',
      'totalXP': 14200,
      'strength': 99,
      'stamina': 82,
      'agility': 85,
      'skills': 88,
      'isCurrentUser': false,
    },
    {
      'id': 4,
      'username': 'You',
      'avatar': '👤',
      'totalXP': 8750,
      'strength': 75,
      'stamina': 80,
      'agility': 78,
      'skills': 82,
      'isCurrentUser': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final sortedUsers = List.from(users)..sort((a, b) => b['totalXP'].compareTo(a['totalXP']));
    final topThree = sortedUsers.take(3).toList();

    return MainLayout(
      currentIndex: -1,
      onTabChanged: (index) {},
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Leaderboard'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F2937),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header with tabs
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Sports Champions Leaderboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTabButton('global', 'Global', Icons.public),
                          const SizedBox(width: 8),
                          _buildTabButton('league', 'My League', Icons.emoji_events),
                          const SizedBox(width: 8),
                          _buildTabButton('friends', 'Friends', Icons.people),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Champions Podium
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      '🏆 Champions Podium 🏆',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (topThree.length > 1) _buildPodiumCard(topThree[1], 2),
                          const SizedBox(width: 16),
                          if (topThree.isNotEmpty) _buildPodiumCard(topThree[0], 1),
                          const SizedBox(width: 16),
                          if (topThree.length > 2) _buildPodiumCard(topThree[2], 3),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Leaderboard List
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Full Rankings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...sortedUsers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final user = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildUserCard(user, index + 1),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String tabId, String label, IconData icon) {
    final isActive = activeTab == tabId;
    return GestureDetector(
      onTap: () {
        setState(() => activeTab = tabId);
        if (tabId == 'league') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyLeaguePage()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2563EB) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumCard(Map<String, dynamic> user, int rank) {
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
            color: Colors.white,
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
                  Icons.emoji_events,
                  color: Color(0xFFFFD700),
                  size: 24,
                ),
              const SizedBox(height: 8),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colors[rank]![0].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: colors[rank]![0], width: 2),
                ),
                child: Center(
                  child: Text(
                    user['avatar'],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user['username'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${user['totalXP']} XP',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
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

  Widget _buildUserCard(Map<String, dynamic> user, int rank) {
    final league = _getLeague(user['totalXP']);
    final leagueInfo = _getLeagueInfo(league);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: user['isCurrentUser'] ? const Color(0xFFEEF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: user['isCurrentUser']
              ? const Color(0xFF6366F1)
              : const Color(0xFFE5E7EB),
          width: user['isCurrentUser'] ? 2 : 1,
        ),
        boxShadow: user['isCurrentUser'] ? [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Display
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: rank <= 3
                  ? _getRankColor(rank)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: rank <= 3
                    ? _getRankColor(rank).withOpacity(0.3)
                    : const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: rank <= 3 ? Colors.white : const Color(0xFF6B7280),
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

          const SizedBox(width: 16),

          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                user['avatar'],
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user['username'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF1F2937),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user['isCurrentUser'])
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            leagueInfo['icon'],
                            size: 14,
                            color: const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            league,
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bolt,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${user['totalXP']} XP',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  String _getLeague(int xp) {
    if (xp >= 5000) return 'Legend';
    if (xp >= 3000) return 'Champion';
    if (xp >= 2000) return 'Diamond';
    if (xp >= 1000) return 'Gold';
    if (xp >= 500) return 'Silver';
    return 'Rookie';
  }

  Map<String, dynamic> _getLeagueInfo(String league) {
    switch (league) {
      case 'Legend':
        return {
          'colors': [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          'icon': Icons.auto_awesome,
        };
      case 'Champion':
        return {
          'colors': [Color(0xFFFFD700), Color(0xFFFFA500)],
          'icon': Icons.emoji_events,
        };
      case 'Diamond':
        return {
          'colors': [Color(0xFF74B9FF), Color(0xFF0984E3)],
          'icon': Icons.diamond,
        };
      case 'Gold':
        return {
          'colors': [Color(0xFFFDCB6E), Color(0xFFE17055)],
          'icon': Icons.star,
        };
      case 'Silver':
        return {
          'colors': [Color(0xFFDDD6FE), Color(0xFF8B5CF6)],
          'icon': Icons.trending_up,
        };
      default:
        return {
          'colors': [Color(0xFF81C784), Color(0xFF4CAF50)],
          'icon': Icons.sports,
        };
    }
  }

  void _showMyLeagueDetails() {
    final currentUser = users.firstWhere((user) => user['isCurrentUser']);
    final league = _getLeague(currentUser['totalXP']);
    final leagueInfo = _getLeagueInfo(league);
    final nextLeagueXP = _getNextLeagueXP(league);
    final currentXP = currentUser['totalXP'];
    final leagueUsers = users.where((u) => _getLeague(u['totalXP']) == league).length;
    final userRankInLeague = users.where((u) => _getLeague(u['totalXP']) == league && u['totalXP'] > currentXP).length + 1;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Container(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: leagueInfo['colors']),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(leagueInfo['icon'], color: Colors.white, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          '$league League',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getLeagueDescription(league),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Stats
                        _buildInfoCard(
                          'Your Stats',
                          Icons.person,
                          [
                            _buildStatRow('Current XP', '$currentXP', Icons.flash_on, Colors.orange),
                            _buildStatRow('League Rank', '#$userRankInLeague', Icons.emoji_events, leagueInfo['colors'][0]),
                            _buildStatRow('League Members', '$leagueUsers players', Icons.people, Colors.blue),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // League Benefits
                        _buildInfoCard(
                          'League Benefits',
                          Icons.card_giftcard,
                          _getLeagueBenefits(league).map((benefit) => 
                            _buildBenefitRow(benefit['title'], benefit['description'], benefit['icon'])
                          ).toList(),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Progress to Next League
                        if (nextLeagueXP > 0) ...[
                          _buildProgressCard(league, currentXP, nextLeagueXP, leagueInfo),
                          const SizedBox(height: 16),
                        ],
                        
                        // League Requirements
                        _buildInfoCard(
                          'League Requirements',
                          Icons.rule,
                          [
                            _buildStatRow('Minimum XP', '${_getLeagueMinXP(league)}', Icons.flash_on, Colors.green),
                            _buildStatRow('Weekly Activity', '3+ workouts', Icons.fitness_center, Colors.purple),
                            _buildStatRow('Skill Level', _getSkillLevel(league), Icons.star, Colors.amber),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  int _getNextLeagueXP(String currentLeague) {
    switch (currentLeague) {
      case 'Rookie': return 500;
      case 'Silver': return 1000;
      case 'Gold': return 2000;
      case 'Diamond': return 3000;
      case 'Champion': return 5000;
      default: return 0;
    }
  }
  
  int _getLeagueMinXP(String league) {
    switch (league) {
      case 'Rookie': return 0;
      case 'Silver': return 500;
      case 'Gold': return 1000;
      case 'Diamond': return 2000;
      case 'Champion': return 3000;
      case 'Legend': return 5000;
      default: return 0;
    }
  }
  
  String _getLeagueDescription(String league) {
    switch (league) {
      case 'Rookie': return 'Starting your fitness journey';
      case 'Silver': return 'Building consistent habits';
      case 'Gold': return 'Achieving fitness goals';
      case 'Diamond': return 'Elite performance level';
      case 'Champion': return 'Master of multiple sports';
      case 'Legend': return 'Ultimate fitness champion';
      default: return 'Keep pushing forward!';
    }
  }
  
  String _getSkillLevel(String league) {
    switch (league) {
      case 'Rookie': return 'Beginner';
      case 'Silver': return 'Intermediate';
      case 'Gold': return 'Advanced';
      case 'Diamond': return 'Expert';
      case 'Champion': return 'Master';
      case 'Legend': return 'Legendary';
      default: return 'Beginner';
    }
  }
  
  List<Map<String, dynamic>> _getLeagueBenefits(String league) {
    switch (league) {
      case 'Rookie':
        return [
          {'title': 'Welcome Bonus', 'description': '+50 XP for first workout', 'icon': Icons.celebration},
          {'title': 'Basic Tracking', 'description': 'Track your progress', 'icon': Icons.analytics},
        ];
      case 'Silver':
        return [
          {'title': 'Workout Streaks', 'description': '+10% XP bonus for 3+ day streaks', 'icon': Icons.local_fire_department},
          {'title': 'Custom Plans', 'description': 'Access to personalized workouts', 'icon': Icons.fitness_center},
        ];
      case 'Gold':
        return [
          {'title': 'Premium Features', 'description': 'Advanced analytics & insights', 'icon': Icons.insights},
          {'title': 'Community Access', 'description': 'Join exclusive groups', 'icon': Icons.group},
          {'title': 'Nutrition Guide', 'description': 'Meal planning assistance', 'icon': Icons.restaurant},
        ];
      case 'Diamond':
        return [
          {'title': 'Personal Coach', 'description': 'AI-powered coaching tips', 'icon': Icons.psychology},
          {'title': 'Priority Support', 'description': '24/7 premium support', 'icon': Icons.support_agent},
          {'title': 'Equipment Discounts', 'description': '15% off partner stores', 'icon': Icons.discount},
        ];
      case 'Champion':
        return [
          {'title': 'VIP Status', 'description': 'Exclusive events & challenges', 'icon': Icons.star},
          {'title': 'Mentor Program', 'description': 'Help guide other athletes', 'icon': Icons.school},
          {'title': 'Gear Rewards', 'description': 'Free premium equipment', 'icon': Icons.card_giftcard},
        ];
      case 'Legend':
        return [
          {'title': 'Hall of Fame', 'description': 'Permanent recognition', 'icon': Icons.emoji_events},
          {'title': 'Beta Access', 'description': 'First access to new features', 'icon': Icons.new_releases},
          {'title': 'Ambassador Program', 'description': 'Represent our community', 'icon': Icons.campaign},
        ];
      default:
        return [];
    }
  }
  
  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBenefitRow(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressCard(String league, int currentXP, int nextLeagueXP, Map<String, dynamic> leagueInfo) {
    final nextLeague = _getNextLeague(league);
    final progress = (currentXP - _getLeagueMinXP(league)) / (nextLeagueXP - _getLeagueMinXP(league));
    final xpNeeded = nextLeagueXP - currentXP;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [leagueInfo['colors'][0].withOpacity(0.1), leagueInfo['colors'][1].withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: leagueInfo['colors'][0].withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: leagueInfo['colors'][0]),
              const SizedBox(width: 8),
              Text(
                'Progress to $nextLeague',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getLeagueMinXP(league)} XP',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '$nextLeagueXP XP',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(leagueInfo['colors'][0]),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '$xpNeeded XP needed to reach $nextLeague League',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getNextLeague(String currentLeague) {
    switch (currentLeague) {
      case 'Rookie': return 'Silver';
      case 'Silver': return 'Gold';
      case 'Gold': return 'Diamond';
      case 'Diamond': return 'Champion';
      case 'Champion': return 'Legend';
      default: return 'Max Level';
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return const Color(0xFFFFD700); // Gold
      case 2: return const Color(0xFFC0C0C0); // Silver
      case 3: return const Color(0xFFCD7F32); // Bronze
      default: return const Color(0xFFF3F4F6);
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
}
