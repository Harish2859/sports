import 'package:flutter/material.dart';
import 'profile.dart';

class PlayerSearchPage extends StatefulWidget {
  const PlayerSearchPage({super.key});

  @override
  State<PlayerSearchPage> createState() => _PlayerSearchPageState();
}

class _PlayerSearchPageState extends State<PlayerSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<PlayerProfile> _searchResults = [];
  bool _isSearching = false;

  final List<PlayerProfile> _allPlayers = [
    PlayerProfile(id: '1', name: 'Alex Johnson', username: 'alex_runner', sport: 'Running', profileImage: 'https://i.pravatar.cc/100?img=1', friendsCount: 234, isVerified: true),
    PlayerProfile(id: '2', name: 'Sarah Wilson', username: 'sarah_swimmer', sport: 'Swimming', profileImage: 'https://i.pravatar.cc/100?img=2', friendsCount: 189, isVerified: false),
    PlayerProfile(id: '3', name: 'Mike Chen', username: 'mike_boxer', sport: 'Boxing', profileImage: 'https://i.pravatar.cc/100?img=3', friendsCount: 156, isVerified: true),
    PlayerProfile(id: '4', name: 'Emma Davis', username: 'emma_tennis', sport: 'Tennis', profileImage: 'https://i.pravatar.cc/100?img=4', friendsCount: 298, isVerified: false),
    PlayerProfile(id: '5', name: 'James Rodriguez', username: 'james_soccer', sport: 'Soccer', profileImage: 'https://i.pravatar.cc/100?img=5', friendsCount: 445, isVerified: true),
    PlayerProfile(id: '6', name: 'Lisa Thompson', username: 'lisa_yoga', sport: 'Yoga', profileImage: 'https://i.pravatar.cc/100?img=6', friendsCount: 167, isVerified: false),
  ];

  @override
  void initState() {
    super.initState();
    _searchResults = _allPlayers;
  }

  void _performSearch(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _searchResults = _allPlayers;
      } else {
        _searchResults = _allPlayers.where((player) =>
          player.name.toLowerCase().contains(query.toLowerCase()) ||
          player.username.toLowerCase().contains(query.toLowerCase()) ||
          player.sport.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Discover Players',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search players, sports...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
                filled: true,
                fillColor: const Color(0xFFF3F2EF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: _performSearch,
            ),
          ),
          
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          
          // Results
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final player = _searchResults[index];
                return _buildPlayerCard(player);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(PlayerProfile player) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            isOwnProfile: false,
            userId: player.id,
            userName: player.name,
            userProfileImage: player.profileImage,
            friendsCount: player.friendsCount,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Profile section
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[400]!, Colors.blue[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(player.profileImage),
                          ),
                        ),
                        if (player.isVerified)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.check, size: 12, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        player.sport,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info section
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        player.name,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '@${player.username}',
                        style: TextStyle(
                          fontSize: 7,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '${player.friendsCount} friends',
                        style: TextStyle(
                          fontSize: 7,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 19,
                    child: ElevatedButton(
                      onPressed: () => _addFriend(player),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Add', style: TextStyle(fontSize: 8)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addFriend(PlayerProfile player) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Friend request sent to ${player.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class PlayerProfile {
  final String id;
  final String name;
  final String username;
  final String sport;
  final String profileImage;
  final int friendsCount;
  final bool isVerified;

  PlayerProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.sport,
    required this.profileImage,
    required this.friendsCount,
    required this.isVerified,
  });
}