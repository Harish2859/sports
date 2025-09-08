import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_layout.dart';
import 'myleague.dart';
import 'theme_provider.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with TickerProviderStateMixin {
  String activeTab = 'global';
  String selectedLeague = 'all';

  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  final List<Map<String, dynamic>> users = [
    {
      'id': 1,
      'username': 'Alex Champion',
      'avatar': 'assets/images/champ.png',
      'totalXP': 15420,
      'strength': 95,
      'stamina': 88,
      'agility': 92,
      'skills': 90,
      'isCurrentUser': false,
      'badgeImage': 'assets/images/champ.png',
    },
    {
      'id': 2,
      'username': 'Sarah Runner',
      'avatar': 'assets/images/intermediate.png',
      'totalXP': 14850,
      'strength': 85,
      'stamina': 98,
      'agility': 89,
      'skills': 87,
      'isCurrentUser': false,
      'badgeImage': 'assets/images/intermediate.png',
    },
    {
      'id': 3,
      'username': 'Mike Strong',
      'avatar': 'assets/images/beginner.png',
      'totalXP': 14200,
      'strength': 99,
      'stamina': 82,
      'agility': 85,
      'skills': 88,
      'isCurrentUser': false,
      'badgeImage': 'assets/images/beginner.png',
    },
    {
      'id': 4,
      'username': 'You',
      'avatar': 'assets/images/silver.png',
      'totalXP': 8750,
      'strength': 75,
      'stamina': 80,
      'agility': 78,
      'skills': 82,
      'isCurrentUser': true,
      'badgeImage': 'assets/images/silver.png',
    },
  ];

  @override
  void initState() {
    super.initState();
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
    _rotationController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    List<Map<String, dynamic>> filteredUsers;
    List<Map<String, dynamic>> topThreeFiltered;

    if (activeTab == 'league') {
      // Filter users to show only those in the same league as current user
      final currentUser = users.firstWhere((user) => user['isCurrentUser']);
      final currentUserLeague = _getLeague(currentUser['totalXP']);
      filteredUsers = users.where((user) => _getLeague(user['totalXP']) == currentUserLeague).toList()
        ..sort((a, b) => b['totalXP'].compareTo(a['totalXP']));
      topThreeFiltered = filteredUsers.take(3).toList();
    } else {
      // Global tab - show all users
      filteredUsers = List.from(users)..sort((a, b) => b['totalXP'].compareTo(a['totalXP']));
      topThreeFiltered = filteredUsers.take(3).toList();
    }

    return MainLayout(
      currentIndex: -1,
      onTabChanged: (index) {},
      child: Container(
        decoration: themeProvider.isGamified
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1a237e), Color(0xFF000000)],
                ),
              )
            : null,
        child: Scaffold(
          backgroundColor: themeProvider.isGamified ? Colors.transparent : theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Leaderboard'),
            backgroundColor: themeProvider.isGamified ? Colors.transparent : theme.appBarTheme.backgroundColor,
            flexibleSpace: themeProvider.isGamified
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
            foregroundColor: theme.appBarTheme.foregroundColor,
            elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header with tabs
              Container(
                color: themeProvider.isGamified ? Colors.white.withOpacity(0.1) : theme.colorScheme.surface,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      activeTab == 'league' ? 'My League Leaderboard' :
                      'Sports Champions Leaderboard',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isGamified ? Colors.white : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTabButton('global', 'Global', Icons.public, theme),
                          const SizedBox(width: 8),
                          _buildTabButton('league', 'My League', Icons.emoji_events, theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (activeTab == 'league') ...[
                // League Status Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.asset(
                                'assets/images/champ.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.emoji_events, color: Colors.white, size: 50);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_getLeague(users.firstWhere((user) => user['isCurrentUser'])['totalXP'])} League',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getLeagueDescription(_getLeague(users.firstWhere((user) => user['isCurrentUser'])['totalXP'])),
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Rank', '#4', Colors.white),
                          _buildStatItem('XP', '${users.firstWhere((user) => user['isCurrentUser'])['totalXP']}', Colors.white),
                          _buildStatItem('Members', '${filteredUsers.length}', Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Progress Section
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress to ${_getNextLeague(_getLeague(users.firstWhere((user) => user['isCurrentUser'])['totalXP']))}',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${_getLeagueMinXP(_getLeague(users.firstWhere((user) => user['isCurrentUser'])['totalXP']))} XP',
                                  style: theme.textTheme.bodySmall),
                                Text('${_getNextLeagueXP(_getLeague(users.firstWhere((user) => user['isCurrentUser'])['totalXP']))} XP',
                                  style: theme.textTheme.bodySmall),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: 0.75,
                              backgroundColor: theme.dividerColor,
                              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                              minHeight: 8,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_getNextLeagueXP(_getLeague(users.firstWhere((user) => user['isCurrentUser'])['totalXP'])) - users.firstWhere((user) => user['isCurrentUser'])['totalXP']} XP needed to reach ${_getNextLeague(_getLeague(users.firstWhere((user) => user['isCurrentUser'])['totalXP']))} League',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // League Rankings
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'League Rankings',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: themeProvider.isGamified ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...filteredUsers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final user = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildUserCard(user, index + 1, theme),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ] else ...[
                // Champions Podium
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '🏆 Champions Podium 🏆',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: themeProvider.isGamified ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (topThreeFiltered.length > 1) _buildPodiumCard(topThreeFiltered[1], 2, theme),
                            const SizedBox(width: 16),
                            if (topThreeFiltered.isNotEmpty) _buildPodiumCard(topThreeFiltered[0], 1, theme),
                            const SizedBox(width: 16),
                            if (topThreeFiltered.length > 2) _buildPodiumCard(topThreeFiltered[2], 3, theme),
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
                      Text(
                        'Full Rankings',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: themeProvider.isGamified ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...filteredUsers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final user = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildUserCard(user, index + 1, theme),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildTabButton(String tabId, String label, IconData icon, ThemeData theme) {
    final isActive = activeTab == tabId;
    return GestureDetector(
      onTap: () {
        setState(() => activeTab = tabId);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.primaryColor : theme.dividerColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : theme.textTheme.bodyLarge?.color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumCard(Map<String, dynamic> user, int rank, ThemeData theme) {
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
            color: theme.colorScheme.surface,
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
                        user['badgeImage'],
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
                user['username'],
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${user['totalXP']} XP',
                style: theme.textTheme.bodySmall,
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

  Widget _buildUserCard(Map<String, dynamic> user, int rank, ThemeData theme) {
    final league = _getLeague(user['totalXP']);
    final leagueInfo = _getLeagueInfo(league);
    final isCurrentUser = user['isCurrentUser'] ?? false;

    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.isGamified 
            ? (isCurrentUser ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.1))
            : (isCurrentUser ? theme.primaryColor.withOpacity(0.1) : theme.colorScheme.surface),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser
              ? theme.primaryColor
              : theme.dividerColor,
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentUser ? theme.primaryColor.withOpacity(0.1) : Colors.black.withOpacity(0.04),
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
                  : theme.dividerColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: rank <= 3
                    ? _getRankColor(rank).withOpacity(0.3)
                    : theme.dividerColor,
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
                    color: rank <= 3 ? Colors.white : theme.textTheme.bodyLarge?.color,
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
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    user['badgeImage'],
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.emoji_events,
                        color: theme.dividerColor,
                        size: 28,
                      );
                    },
                  ),
                ),
              );
            },
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: themeProvider.isGamified ? Colors.white : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
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
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            leagueInfo['icon'],
                            size: 14,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            league,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: themeProvider.isGamified ? Colors.white70 : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt,
                          size: 16,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${user['totalXP']} XP',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: themeProvider.isGamified ? Colors.white : null,
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
          'colors': [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
          'icon': Icons.auto_awesome,
        };
      case 'Champion':
        return {
          'colors': [const Color(0xFFFFD700), const Color(0xFFFFA500)],
          'icon': Icons.emoji_events,
        };
      case 'Diamond':
        return {
          'colors': [const Color(0xFF74B9FF), const Color(0xFF0984E3)],
          'icon': Icons.diamond,
        };
      case 'Gold':
        return {
          'colors': [const Color(0xFFFDCB6E), const Color(0xFFE17055)],
          'icon': Icons.star,
        };
      case 'Silver':
        return {
          'colors': [const Color(0xFFDDD6FE), const Color(0xFF8B5CF6)],
          'icon': Icons.trending_up,
        };
      default:
        return {
          'colors': [const Color(0xFF81C784), const Color(0xFF4CAF50)],
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
                      gradient: LinearGradient(colors: leagueInfo['colors'] as List<Color>),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(leagueInfo['icon'] as IconData, color: Colors.white, size: 40),
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
                            _buildStatRow('League Rank', '#$userRankInLeague', Icons.emoji_events, (leagueInfo['colors'] as List<Color>)[0]),
                            _buildStatRow('League Members', '$leagueUsers players', Icons.people, Colors.blue),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // League Benefits
                        _buildInfoCard(
                          'League Benefits',
                          Icons.card_giftcard,
                          _getLeagueBenefits(league).map((benefit) => 
                            _buildBenefitRow(benefit['title'] as String, benefit['description'] as String, benefit['icon'] as IconData)
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.dividerColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.textTheme.bodyLarge?.color),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBenefitRow(String title, String description, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: theme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressCard(String league, int currentXP, int nextLeagueXP, Map<String, dynamic> leagueInfo) {
    final theme = Theme.of(context);
    final nextLeague = _getNextLeague(league);
    final progress = (currentXP - _getLeagueMinXP(league)) / (nextLeagueXP - _getLeagueMinXP(league));
    final xpNeeded = nextLeagueXP - currentXP;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (leagueInfo['colors'] as List<Color>)[0].withOpacity(0.1),
            (leagueInfo['colors'] as List<Color>)[1].withOpacity(0.1)
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (leagueInfo['colors'] as List<Color>)[0].withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: (leagueInfo['colors'] as List<Color>)[0]),
              const SizedBox(width: 8),
              Text(
                'Progress to $nextLeague',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getLeagueMinXP(league)} XP',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                '$nextLeagueXP XP',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>((leagueInfo['colors'] as List<Color>)[0]),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '$xpNeeded XP needed to reach $nextLeague League',
            style: theme.textTheme.bodyMedium,
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
      default: return Colors.transparent;
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

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
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
            color: color.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}