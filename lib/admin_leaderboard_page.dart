import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  String activeCategory = 'Overall';
  String selectedDateRange = 'All-Time';
  String selectedStatus = 'All';
  String searchQuery = '';
  int currentPage = 1;
  int itemsPerPage = 25;
  String sortBy = 'rank';
  bool sortAscending = true;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  final List<Map<String, dynamic>> allUsers = [
    {'id': 'U001', 'name': 'Alex Champion', 'avatar': 'assets/images/champ.png', 'score': 15420, 'gender': 'Male', 'joinDate': '2023-01-15', 'status': 'Active'},
    {'id': 'U002', 'name': 'Sarah Runner', 'avatar': 'assets/images/intermediate.png', 'score': 14200, 'gender': 'Female', 'joinDate': '2023-02-20', 'status': 'Active'},
    {'id': 'U003', 'name': 'Mike Strong', 'avatar': 'assets/images/beginner.png', 'score': 13100, 'gender': 'Male', 'joinDate': '2023-03-10', 'status': 'Active'},
    {'id': 'U004', 'name': 'Emma Swift', 'avatar': 'assets/images/silver.png', 'score': 12800, 'gender': 'Female', 'joinDate': '2023-04-05', 'status': 'Active'},
    {'id': 'U005', 'name': 'Jordan Power', 'avatar': 'assets/images/ruby.png', 'score': 12500, 'gender': 'Other', 'joinDate': '2023-05-12', 'status': 'Active'},
    {'id': 'U006', 'name': 'Lisa Fast', 'avatar': 'assets/images/dimond.png', 'score': 11900, 'gender': 'Female', 'joinDate': '2023-06-18', 'status': 'Banned'},
    {'id': 'U007', 'name': 'Tom Athlete', 'avatar': 'assets/images/white.png', 'score': 11200, 'gender': 'Male', 'joinDate': '2023-07-22', 'status': 'Under Review'},
    {'id': 'U008', 'name': 'Casey Elite', 'avatar': 'assets/images/blue.png', 'score': 10800, 'gender': 'Other', 'joinDate': '2023-08-30', 'status': 'Active'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _scoreController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredUsers {
    var users = List<Map<String, dynamic>>.from(allUsers);
    
    if (activeCategory != 'Overall') {
      users = users.where((user) => user['gender'] == activeCategory).toList();
    }
    
    if (selectedStatus != 'All') {
      users = users.where((user) => user['status'] == selectedStatus).toList();
    }
    
    if (searchQuery.isNotEmpty) {
      users = users.where((user) => 
        user['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
        user['id'].toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }
    
    users.sort((a, b) {
      switch (sortBy) {
        case 'name':
          return sortAscending ? a['name'].compareTo(b['name']) : b['name'].compareTo(a['name']);
        case 'score':
          return sortAscending ? a['score'].compareTo(b['score']) : b['score'].compareTo(a['score']);
        default:
          return sortAscending ? a['score'].compareTo(b['score']) : b['score'].compareTo(a['score']);
      }
    });
    
    return users;
  }

  List<Map<String, dynamic>> get topThree {
    var users = filteredUsers;
    if (users.length >= 3) return users.take(3).toList();
    return users;
  }

  List<Map<String, dynamic>> get paginatedUsers {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return filteredUsers.sublist(
      startIndex,
      endIndex > filteredUsers.length ? filteredUsers.length : endIndex,
    );
  }

  int get totalPages => (filteredUsers.length / itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Leaderboard'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportToCSV,
            tooltip: 'Export to CSV',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMetricsSection(theme),
          _buildCategoryTabs(theme),
          _buildFiltersSection(theme),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildChampionPodium(theme),
                  _buildRankingTable(theme),
                  _buildPagination(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(ThemeData theme) {
    final totalParticipants = filteredUsers.length;
    final averageScore = totalParticipants > 0 
        ? (filteredUsers.map((u) => u['score'] as int).reduce((a, b) => a + b) / totalParticipants).round()
        : 0;
    final newParticipants = filteredUsers.where((u) => 
        DateTime.parse(u['joinDate']).isAfter(DateTime.now().subtract(const Duration(days: 7)))
    ).length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.primaryColor.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricCard('Total Participants', '$totalParticipants', Icons.people, theme),
          _buildMetricCard('Average Score', '$averageScore', Icons.trending_up, theme),
          _buildMetricCard('New (7 days)', '$newParticipants', Icons.person_add, theme),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, color: theme.primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildCategoryTabs(ThemeData theme) {
    final categories = ['Overall', 'Male', 'Female', 'Other'];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) => 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildTabButton(category, theme),
            ),
          ).toList(),
        ),
      ),
    );
  }

  Widget _buildTabButton(String category, ThemeData theme) {
    final isActive = activeCategory == category;
    return GestureDetector(
      onTap: () => setState(() => activeCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.primaryColor),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isActive ? Colors.white : theme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or ID...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) => setState(() => searchQuery = value),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: selectedDateRange,
                items: ['All-Time', 'This Season', 'Last 30 Days', 'This Week']
                    .map((range) => DropdownMenuItem(value: range, child: Text(range)))
                    .toList(),
                onChanged: (value) => setState(() => selectedDateRange = value!),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: selectedStatus,
                items: ['All', 'Active', 'Banned', 'Under Review']
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) => setState(() => selectedStatus = value!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChampionPodium(ThemeData theme) {
    if (topThree.isEmpty) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('🏆 Champions Podium 🏆', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (topThree.length > 1) _buildPodiumPosition(topThree[1], 2, theme),
              const SizedBox(width: 16),
              if (topThree.isNotEmpty) _buildPodiumPosition(topThree[0], 1, theme),
              const SizedBox(width: 16),
              if (topThree.length > 2) _buildPodiumPosition(topThree[2], 3, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition(Map<String, dynamic> user, int position, ThemeData theme) {
    final colors = {1: Colors.amber, 2: Colors.grey, 3: const Color(0xFFCD7F32)};
    final heights = {1: 120.0, 2: 100.0, 3: 80.0};
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors[position]!, width: 2),
          ),
          child: Column(
            children: [
              if (position == 1) const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
              CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage(user['avatar']),
                onBackgroundImageError: (_, __) {},
                child: user['avatar'] == null ? const Icon(Icons.person) : null,
              ),
              const SizedBox(height: 8),
              Text(user['name'], style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text('${user['score']} Points', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: heights[position]!,
          decoration: BoxDecoration(
            color: colors[position]!,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Text('$position', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildRankingTable(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 800),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 60, child: Text('Rank', style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 150, child: Text('User', style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 80, child: Text('Score', style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 80, child: Text('User ID', style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 100, child: Text('Join Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 100, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 150, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              ...paginatedUsers.asMap().entries.map((entry) {
                final index = entry.key + ((currentPage - 1) * itemsPerPage);
                final user = entry.value;
                return _buildUserRow(user, index + 1, theme);
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(String title, String sortKey, ThemeData theme) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          if (sortBy == sortKey) {
            sortAscending = !sortAscending;
          } else {
            sortBy = sortKey;
            sortAscending = true;
          }
        }),
        child: Row(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (sortBy == sortKey)
              Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRow(Map<String, dynamic> user, int rank, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text('#$rank', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            width: 150,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage(user['avatar']),
                  onBackgroundImageError: (_, __) {},
                  child: user['avatar'] == null ? const Icon(Icons.person, size: 16) : null,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(user['name'], overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          SizedBox(width: 80, child: Text('${user['score']}')),
          SizedBox(width: 80, child: Text(user['id'])),
          SizedBox(width: 100, child: Text(user['joinDate'])),
          SizedBox(
            width: 100,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(user['status']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user['status'],
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            width: 150,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, size: 16),
                  onPressed: () => _viewUserProfile(user),
                  tooltip: 'View Profile',
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 16),
                  onPressed: () => _adjustScore(user),
                  tooltip: 'Adjust Score',
                ),
                IconButton(
                  icon: const Icon(Icons.block, size: 16, color: Colors.red),
                  onPressed: () => _banUser(user),
                  tooltip: 'Ban User',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Page $currentPage of $totalPages'),
          Row(
            children: [
              IconButton(
                onPressed: currentPage > 1 ? () => setState(() => currentPage--) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              ...List.generate(
                totalPages > 5 ? 5 : totalPages,
                (index) {
                  final pageNum = index + 1;
                  return GestureDetector(
                    onTap: () => setState(() => currentPage = pageNum),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: currentPage == pageNum ? theme.primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$pageNum',
                        style: TextStyle(
                          color: currentPage == pageNum ? Colors.white : theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                onPressed: currentPage < totalPages ? () => setState(() => currentPage++) : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active': return Colors.green;
      case 'Banned': return Colors.red;
      case 'Under Review': return Colors.orange;
      default: return Colors.grey;
    }
  }

  void _viewUserProfile(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Profile: ${user['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${user['id']}'),
            Text('Score: ${user['score']}'),
            Text('Gender: ${user['gender']}'),
            Text('Join Date: ${user['joinDate']}'),
            Text('Status: ${user['status']}'),
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

  void _adjustScore(Map<String, dynamic> user) {
    _scoreController.clear();
    _reasonController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adjust Score: ${user['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Score: ${user['score']}'),
            const SizedBox(height: 16),
            TextField(
              controller: _scoreController,
              decoration: const InputDecoration(
                labelText: 'Score Adjustment (+/-)',
                hintText: 'e.g., +100 or -50',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Adjustment *',
                hintText: 'Required: Explain the reason',
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
              if (_reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reason is required')),
                );
                return;
              }
              
              final adjustment = int.tryParse(_scoreController.text.replaceAll('+', ''));
              if (adjustment != null) {
                setState(() {
                  user['score'] = (user['score'] as int) + adjustment;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Score adjusted for ${user['name']}')),
                );
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _banUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Action'),
        content: Text('Are you sure you want to ban ${user['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                user['status'] = 'Banned';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user['name']} has been banned')),
              );
            },
            child: const Text('Ban User', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _exportToCSV() {
    final csvData = StringBuffer();
    csvData.writeln('Rank,Name,Score,User ID,Join Date,Status,Gender');
    
    filteredUsers.asMap().forEach((index, user) {
      csvData.writeln('${index + 1},${user['name']},${user['score']},${user['id']},${user['joinDate']},${user['status']},${user['gender']}');
    });
    
    Clipboard.setData(ClipboardData(text: csvData.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV data copied to clipboard')),
    );
  }
}