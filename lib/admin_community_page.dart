import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'community_profile_page.dart';
import 'admin_community_profile_page.dart';
import 'theme_provider.dart';

// Reuse the same model classes from community_page.dart
class Member {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isOnline;
  final String role;

  Member({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.isOnline = false,
    this.role = 'Member',
  });
}

class Message {
  final String id;
  final Member sender;
  final String content;
  final DateTime timestamp;
  final bool isMe;

  Message({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.isMe = false,
  });
}

class Post {
  final String id;
  final Member author;
  final String content;
  final DateTime timestamp;
  final int likeCount;
  final int commentCount;

  Post({
    required this.id,
    required this.author,
    required this.content,
    required this.timestamp,
    this.likeCount = 0,
    this.commentCount = 0,
  });
}

class Community {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final int unreadCount;
  final List<Member> members;
  final List<Message> messages;
  final List<Post> posts;
  final Color primaryColor;
  final Color secondaryColor;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    this.unreadCount = 0,
    required this.members,
    required this.messages,
    required this.posts,
    required this.primaryColor,
    required this.secondaryColor,
  });
}

class AdminCommunityPage extends StatefulWidget {
  const AdminCommunityPage({super.key});

  @override
  State<AdminCommunityPage> createState() => _AdminCommunityPageState();
}

class _AdminCommunityPageState extends State<AdminCommunityPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Community> communities = [
    Community(
      id: '1',
      name: 'Sports Enthusiasts',
      description: 'Connect with fellow sports lovers',
      iconUrl: '🏆',
      primaryColor: Color(0xFF25D366),
      secondaryColor: Color(0xFF25D366),
      unreadCount: 3,
      members: [
        Member(id: '1', name: 'John Doe', avatarUrl: '👨', role: 'Admin'),
        Member(id: '2', name: 'Jane Smith', avatarUrl: '👩'),
        Member(id: '3', name: 'Alex Wilson', avatarUrl: '🧑'),
      ],
      messages: [
        Message(
          id: '1',
          sender: Member(id: '2', name: 'Jane Smith', avatarUrl: '👩'),
          content: 'Anyone up for a game this weekend?',
          timestamp: DateTime.now().subtract(Duration(minutes: 15)),
        ),
      ],
      posts: [
        Post(
          id: '1',
          author: Member(id: '1', name: 'John Doe', avatarUrl: '👨', role: 'Admin'),
          content: 'Just crushed my morning workout! 💪 Nothing beats that post-gym feeling.',
          timestamp: DateTime.now().subtract(Duration(hours: 2)),
          likeCount: 24,
          commentCount: 8,
        ),
      ],
    ),
    Community(
      id: '2',
      name: 'Fitness Goals',
      description: 'Share your fitness journey',
      iconUrl: '💪',
      primaryColor: Color(0xFF25D366),
      secondaryColor: Color(0xFF25D366),
      unreadCount: 1,
      members: [
        Member(id: '3', name: 'Mike Johnson', avatarUrl: '👨💼', role: 'Admin'),
        Member(id: '4', name: 'Emily Brown', avatarUrl: '👩💻'),
      ],
      messages: [
        Message(
          id: '2',
          sender: Member(id: '3', name: 'Mike Johnson', avatarUrl: '👨💼', role: 'Admin'),
          content: 'Great workout session today! 💪',
          timestamp: DateTime.now().subtract(Duration(hours: 2)),
        ),
      ],
      posts: [
        Post(
          id: '3',
          author: Member(id: '3', name: 'Mike Johnson', avatarUrl: '👨💼', role: 'Admin'),
          content: '30-day transformation complete! 🙏 Lost 15 pounds and gained confidence.',
          timestamp: DateTime.now().subtract(Duration(hours: 1)),
          likeCount: 156,
          commentCount: 43,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Admin Communities',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showCreateCommunityDialog(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search communities',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF3F2EF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: communities.length,
                itemBuilder: (context, index) {
                  final community = communities[index];
                  return _buildAdminCommunityTile(context, community, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCommunityTile(BuildContext context, Community community, int index) {
    final lastMessage = community.messages.isNotEmpty ? community.messages.last : null;
    final timeString = lastMessage != null ? _formatTime(lastMessage.timestamp) : '';
    
    return Container(
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF25D366),
              child: Text(
                community.iconUrl,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            if (community.unreadCount > 0)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                community.name,
                style: TextStyle(
                  fontWeight: community.unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteCommunity(index);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Community'),
                    ],
                  ),
                ),
              ],
              child: Icon(Icons.more_vert, color: Colors.grey[600]),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${community.members.length} members • ${community.description}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (lastMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${lastMessage.sender.name}: ${lastMessage.content}',
                        style: TextStyle(
                          color: community.unreadCount > 0 
                              ? Colors.black87 
                              : Colors.grey[600],
                          fontWeight: community.unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (community.unreadCount > 0) ...[ 
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.blue[700],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminCommunityChatPage(
                community: community,
                onPostAdded: (post) => _addPostToCommunity(index, post),
                onMessageAdded: (message) => _addMessageToCommunity(index, message),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateCommunityDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedIcon = '🏆';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Community'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Community Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedIcon,
              decoration: const InputDecoration(
                labelText: 'Icon',
                border: OutlineInputBorder(),
              ),
              items: ['🏆', '💪', '⚽', '🏀', '🎾', '🏊', '🚴']
                  .map((icon) => DropdownMenuItem(value: icon, child: Text(icon)))
                  .toList(),
              onChanged: (value) => selectedIcon = value!,
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
              if (nameController.text.isNotEmpty) {
                _createCommunity(nameController.text, descController.text, selectedIcon);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createCommunity(String name, String description, String icon) {
    setState(() {
      communities.add(
        Community(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          description: description,
          iconUrl: icon,
          primaryColor: const Color(0xFF25D366),
          secondaryColor: const Color(0xFF25D366),
          members: [Member(id: 'admin', name: 'Admin', avatarUrl: '👨‍💼', role: 'Admin')],
          messages: [],
          posts: [],
        ),
      );
    });
  }

  void _deleteCommunity(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Community'),
        content: Text('Are you sure you want to delete "${communities[index].name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                communities.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addPostToCommunity(int index, Post post) {
    setState(() {
      communities[index].posts.insert(0, post);
    });
  }

  void _addMessageToCommunity(int index, Message message) {
    setState(() {
      communities[index].messages.add(message);
    });
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

class AdminCommunityChatPage extends StatefulWidget {
  final Community community;
  final Function(Post) onPostAdded;
  final Function(Message) onMessageAdded;

  const AdminCommunityChatPage({
    super.key,
    required this.community,
    required this.onPostAdded,
    required this.onMessageAdded,
  });

  @override
  State<AdminCommunityChatPage> createState() => _AdminCommunityChatPageState();
}

class _AdminCommunityChatPageState extends State<AdminCommunityChatPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF1A1A1A) : Color(0xFFF5F5F5),
      appBar: _buildCustomAppBar(isDarkMode),
      body: TabBarView(
        controller: _tabController,
        children: [
          AdminPostsTabView(
            community: widget.community,
            isDarkMode: isDarkMode,
            onPostAdded: widget.onPostAdded,
          ),
          AdminMessagesTabView(
            community: widget.community,
            isDarkMode: isDarkMode,
            onMessageAdded: widget.onMessageAdded,
          ),
        ],
      ),
      floatingActionButton: _buildDynamicFab(context),
    );
  }

  AppBar _buildCustomAppBar(bool isDarkMode) {
    return AppBar(
      backgroundColor: isDarkMode ? Color(0xFF2A2A2A) : Colors.white,
      foregroundColor: isDarkMode ? Colors.white : Colors.black,
      elevation: 1,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminCommunityProfilePage(community: widget.community),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFF25D366),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(widget.community.iconUrl, style: TextStyle(fontSize: 20))),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.community.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${widget.community.members.length} members • Admin Mode',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      titleSpacing: 0,
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Color(0xFF25D366),
        labelColor: Color(0xFF25D366),
        unselectedLabelColor: isDarkMode ? Colors.white54 : Colors.grey[500],
        tabs: const [
          Tab(text: 'POSTS'),
          Tab(text: 'MESSAGES'),
        ],
      ),
    );
  }

  Widget _buildDynamicFab(BuildContext context) {
    bool isPostsTab = _tabController.index == 0;
    return FloatingActionButton(
      onPressed: () {
        if (isPostsTab) {
          _showCreatePostDialog();
        } else {
          _showCreateMessageDialog();
        }
      },
      backgroundColor: Color(0xFF25D366),
      child: Icon(
        isPostsTab ? Icons.edit : Icons.send,
        color: Colors.white,
      ),
    );
  }

  void _showCreatePostDialog() {
    final contentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Post'),
        content: TextField(
          controller: contentController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'What\'s on your mind?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (contentController.text.isNotEmpty) {
                final post = Post(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  author: Member(id: 'admin', name: 'Admin', avatarUrl: '👨‍💼', role: 'Admin'),
                  content: contentController.text,
                  timestamp: DateTime.now(),
                );
                widget.onPostAdded(post);
                Navigator.pop(context);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  void _showCreateMessageDialog() {
    final messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Message'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            hintText: 'Type your message...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (messageController.text.isNotEmpty) {
                final message = Message(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  sender: Member(id: 'admin', name: 'Admin', avatarUrl: '👨‍💼', role: 'Admin'),
                  content: messageController.text,
                  timestamp: DateTime.now(),
                  isMe: true,
                );
                widget.onMessageAdded(message);
                Navigator.pop(context);
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

class AdminPostsTabView extends StatefulWidget {
  final Community community;
  final bool isDarkMode;
  final Function(Post) onPostAdded;

  const AdminPostsTabView({
    super.key,
    required this.community,
    required this.isDarkMode,
    required this.onPostAdded,
  });

  @override
  State<AdminPostsTabView> createState() => _AdminPostsTabViewState();
}

class _AdminPostsTabViewState extends State<AdminPostsTabView> {
  Set<String> likedPosts = {};

  @override
  Widget build(BuildContext context) {
    if (widget.community.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No posts yet.',
              style: TextStyle(color: widget.isDarkMode ? Colors.white54 : Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showCreatePostDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Create First Post'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.community.posts.length,
      itemBuilder: (context, index) {
        final post = widget.community.posts[index];
        return _buildPostCard(post, index);
      },
    );
  }

  Widget _buildPostCard(Post post, int index) {
    final bool isLiked = likedPosts.contains(post.id);
    final String imagePath = index % 2 == 0 ? 'assets/images/event 2.jpg' : 'assets/images/event 3.jpg';
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: widget.isDarkMode ? Color(0xFF1A1A1A) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF25D366),
                  child: Text(
                    post.author.name[0],
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.author.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: widget.isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          if (post.author.role == 'Admin') ...[
                            SizedBox(width: 4),
                            Icon(Icons.verified, color: Colors.blue, size: 16),
                          ],
                        ],
                      ),
                      Text(
                        _formatTime(post.timestamp),
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white60 : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deletePost(post);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete Post'),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: widget.isDarkMode ? Colors.white60 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 300,
            color: widget.isDarkMode ? Color(0xFF2A2A2A) : Colors.grey[100],
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: widget.isDarkMode ? Color(0xFF2A2A2A) : Colors.grey[100],
                  child: Icon(
                    Icons.image,
                    size: 50,
                    color: widget.isDarkMode ? Colors.white30 : Colors.grey[400],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isLiked) {
                        likedPosts.remove(post.id);
                      } else {
                        likedPosts.add(post.id);
                      }
                    });
                  },
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : (widget.isDarkMode ? Colors.white : Colors.black),
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Icon(
                  Icons.chat_bubble_outline,
                  size: 26,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
                SizedBox(width: 16),
                Icon(
                  Icons.send,
                  size: 24,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
                Spacer(),
                Icon(
                  Icons.bookmark_border,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${isLiked ? post.likeCount + 1 : post.likeCount} likes',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${post.author.name} ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: post.content,
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (post.commentCount > 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                'View all ${post.commentCount} comments',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white60 : Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCreatePostDialog() {
    final contentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Post'),
        content: TextField(
          controller: contentController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'What\'s on your mind?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (contentController.text.isNotEmpty) {
                final post = Post(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  author: Member(id: 'admin', name: 'Admin', avatarUrl: '👨‍💼', role: 'Admin'),
                  content: contentController.text,
                  timestamp: DateTime.now(),
                );
                widget.onPostAdded(post);
                Navigator.pop(context);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  void _deletePost(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.community.posts.removeWhere((p) => p.id == post.id);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

class AdminMessagesTabView extends StatelessWidget {
  final Community community;
  final bool isDarkMode;
  final Function(Message) onMessageAdded;
  final TextEditingController _messageController = TextEditingController();

  AdminMessagesTabView({
    super.key,
    required this.community,
    required this.isDarkMode,
    required this.onMessageAdded,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: community.messages.length,
            itemBuilder: (context, index) {
              final message = community.messages[index];
              return _buildMessageBubble(message, isDarkMode);
            },
          ),
        ),
        _buildMessageInputBar(isDarkMode, context),
      ],
    );
  }

  Widget _buildMessageBubble(Message message, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isMe
                    ? Color(0xFF25D366)
                    : (isDarkMode ? Color(0xFF2A2A2A) : Colors.white),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isMe)
                    Row(
                      children: [
                        Text(
                          message.sender.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF25D366),
                          ),
                        ),
                        if (message.sender.role == 'Admin') ...[
                          SizedBox(width: 4),
                          Icon(Icons.verified, color: Colors.blue, size: 12),
                        ],
                      ],
                    ),
                  if (!message.isMe) SizedBox(height: 4),
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: message.isMe
                          ? Colors.white
                          : (isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 11,
                      color: message.isMe
                          ? Colors.white70
                          : (isDarkMode ? Colors.white60 : Colors.grey[500]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInputBar(bool isDarkMode, BuildContext context) {
    return Container(
      color: isDarkMode ? Color(0xFF2A2A2A) : Colors.white,
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0xFF1A1A1A) : Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white54 : Colors.grey[500],
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  prefixIcon: Icon(
                    Icons.emoji_emotions_outlined,
                    color: isDarkMode ? Colors.white54 : Colors.grey[500],
                  ),
                  suffixIcon: Icon(
                    Icons.attach_file,
                    color: isDarkMode ? Colors.white54 : Colors.grey[500],
                  ),
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Color(0xFF25D366),
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: () {
                if (_messageController.text.trim().isNotEmpty) {
                  final message = Message(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    sender: Member(id: 'admin', name: 'Admin', avatarUrl: '👨‍💼', role: 'Admin'),
                    content: _messageController.text,
                    timestamp: DateTime.now(),
                    isMe: true,
                  );
                  onMessageAdded(message);
                  _messageController.clear();
                }
              },
              icon: Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}