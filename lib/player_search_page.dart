import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- Placeholder for your ProfilePage ---
// You can replace this with your actual ProfilePage widget.
class ProfilePage extends StatelessWidget {
  final bool isOwnProfile;
  final String userId;
  final String userName;
  final String userProfileImage;
  final int friendsCount;

  const ProfilePage({
    super.key,
    required this.isOwnProfile,
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    required this.friendsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(userName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userProfileImage),
            ),
            const SizedBox(height: 16),
            Text('Profile of $userName', style: const TextStyle(fontSize: 22)),
            Text('User ID: $userId'),
          ],
        ),
      ),
    );
  }
}

// --- Main Player Search Page Widget ---
class PlayerSearchPage extends StatefulWidget {
  const PlayerSearchPage({super.key});

  @override
  State<PlayerSearchPage> createState() => _PlayerSearchPageState();
}

class _PlayerSearchPageState extends State<PlayerSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<PlayerProfile> _searchResults = [];
  final Set<String> _pendingRequests = {}; // Tracks pending friend requests

  // Hardcoded player data for demonstration
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
    // Initially, show all players
    _searchResults = _allPlayers;
    // Add a listener to rebuild the UI when the search text changes (for the clear button)
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = _allPlayers;
      } else {
        _searchResults = _allPlayers
            .where((player) =>
                player.name.toLowerCase().contains(query.toLowerCase()) ||
                player.username.toLowerCase().contains(query.toLowerCase()) ||
                player.sport.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _addFriend(PlayerProfile player) {
    setState(() {
      _pendingRequests.add(player.id);
    });
    // Show a confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 2,
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        content: Text(
          'Connection request sent to ${player.name}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Use system UI overlay style for better status bar contrast
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: Colors.grey[200],
        title: const Text(
          'Discover',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF1A1A1A),
          ),
        ),
        // Simplified leading back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A1A1A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Simplified filter button
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Color(0xFF1A1A1A), size: 24),
            onPressed: () {
              // TODO: Implement filter logic
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ## 1. Minimalistic Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search players or sports...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 22),
                // Show clear button only when text is entered
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, color: Colors.grey[500]),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                // Use a subtle border instead of shadow
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _performSearch,
            ),
          ),

          // ## 2. Dynamic Results Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _searchController.text.isEmpty
                  ? 'Suggested Players'
                  : 'Results (${_searchResults.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),

          // ## 3. Content Area with Conditional UI
          Expanded(
            child: _searchResults.isEmpty
                ? _buildEmptyState()
                : _buildResultsList(),
          ),
        ],
      ),
    );
  }

  /// A clean list view for displaying results.
  Widget _buildResultsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final player = _searchResults[index];
        return _buildPlayerListItem(player);
      },
      // Add a subtle divider between items
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey[200],
        height: 1,
        indent: 80, // Indent to align with text
        endIndent: 16,
      ),
    );
  }

  /// Refactored player card into a cleaner list item.
  Widget _buildPlayerListItem(PlayerProfile player) {
    final isPending = _pendingRequests.contains(player.id);

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          // Navigate to the player's profile page
          Navigator.push(
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
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // ## Profile Picture with Verified Badge
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(player.profileImage),
                    backgroundColor: Colors.grey[200],
                  ),
                  if (player.isVerified)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, color: Colors.blueAccent, size: 18),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // ## Name and Username
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${player.username}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // ## 'Connect' Button with State
              _buildConnectButton(isPending, player),
            ],
          ),
        ),
      ),
    );
  }

  /// A dedicated builder for the connect button to handle different states.
  Widget _buildConnectButton(bool isPending, PlayerProfile player) {
    return isPending
        ? OutlinedButton.icon(
            onPressed: null, // Disabled
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Pending'),
            style: OutlinedButton.styleFrom(
              disabledForegroundColor: Colors.grey[600],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              side: BorderSide(color: Colors.grey[300]!),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          )
        : ElevatedButton.icon(
            onPressed: () => _addFriend(player),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Connect'),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
  }

  /// Refreshed empty state UI.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Players Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try using different keywords.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Data Model for a Player ---
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