import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';



class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  // Sample data for demonstration
  final List<ChatUser> _activeUsers = [
    ChatUser(
      id: '1',
      name: 'Alex Johnson',
      title: 'Sprinter, Elite Athletics Team',
      avatar: 'https://i.pravatar.cc/100?img=1',
      isOnline: true,
      hasStory: false,
    ),
    ChatUser(
      id: '2',
      name: 'Mike Thompson',
      title: 'Coach, City Football Club',
      avatar: 'https://i.pravatar.cc/100?img=2',
      isOnline: true,
      hasStory: false,
    ),
    ChatUser(
      id: '3',
      name: 'Emma Davis',
      title: 'Volleyball Player, National Team',
      avatar: 'https://i.pravatar.cc/100?img=3',
      isOnline: false,
      hasStory: false,
    ),
  ];

  final List<ChatItem> _focusedChats = [
    ChatItem(
      user: ChatUser(
        id: '1',
        name: 'Alex Johnson',
        title: 'Sprinter, Elite Athletics Team',
        avatar: 'https://i.pravatar.cc/100?img=1',
        isOnline: true,
      ),
      lastMessage: 'Great training session! Let\'s discuss your sprint times.',
      timestamp: '2h',
      unreadCount: 1,
      isTyping: false,
      isPinned: false,
      messageStatus: MessageStatus.delivered,
    ),
    ChatItem(
      user: ChatUser(
        id: '4',
        name: 'Sports Academy',
        title: 'Official Training Program',
        avatar: 'https://i.pravatar.cc/100?img=4',
        isOnline: false,
        isVerified: true,
      ),
      lastMessage: 'New training programs available for your level',
      timestamp: '4h',
      unreadCount: 0,
      isTyping: false,
      isPinned: false,
      messageStatus: MessageStatus.read,
    ),
  ];

  final List<ChatItem> _otherChats = [
    ChatItem(
      user: ChatUser(
        id: '2',
        name: 'Mike Thompson',
        title: 'Coach, City Football Club',
        avatar: 'https://i.pravatar.cc/100?img=2',
        isOnline: true,
      ),
      lastMessage: 'Great match yesterday! Your defense was solid.',
      timestamp: '1d',
      unreadCount: 0,
      isTyping: false,
      isPinned: false,
      messageStatus: MessageStatus.read,
    ),
    ChatItem(
      user: ChatUser(
        id: '5',
        name: 'Athletes Community',
        title: 'Sports Group • 2K members',
        avatar: 'https://i.pravatar.cc/100?img=5',
        isOnline: false,
        isGroup: true,
      ),
      lastMessage: 'Coach: Check out this new training technique',
      timestamp: '2d',
      unreadCount: 0,
      isTyping: false,
      isPinned: false,
      messageStatus: MessageStatus.read,
    ),
    ChatItem(
      user: ChatUser(
        id: '3',
        name: 'Emma Davis',
        title: 'Volleyball Player, National Team',
        avatar: 'https://i.pravatar.cc/100?img=3',
        isOnline: false,
      ),
      lastMessage: 'Would love to get your thoughts on this play strategy',
      timestamp: '3d',
      unreadCount: 0,
      isTyping: false,
      isPinned: false,
      messageStatus: MessageStatus.read,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Sports Chat',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black54),
            onPressed: () {
              // Handle options menu
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black54),
            onPressed: () {
              // Handle compose message
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search messages',
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
                  // Handle search
                },
              ),
            ),

            // Messages Content
            Expanded(
              child: _buildMessagesSection(),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildMessagesSection() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ..._focusedChats.map((chat) => LinkedInChatTile(chat: chat)),
        ..._otherChats.map((chat) => LinkedInChatTile(chat: chat)),
      ],
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

class LinkedInChatTile extends StatelessWidget {
  final ChatItem chat;

  const LinkedInChatTile({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(chat.user.avatar),
            ),
            if (chat.user.isOnline && !chat.user.isGroup)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            if (chat.user.isVerified)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.check, size: 10, color: Colors.white),
                ),
              ),
            if (chat.user.isGroup)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.group, size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                chat.user.name,
                style: TextStyle(
                  fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              chat.timestamp,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chat.user.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  chat.user.title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      chat.isTyping ? 'Typing...' : chat.lastMessage,
                      style: TextStyle(
                        color: chat.isTyping 
                            ? Colors.blue[700] 
                            : chat.unreadCount > 0 
                                ? Colors.black87 
                                : Colors.grey[600],
                        fontStyle: chat.isTyping ? FontStyle.italic : FontStyle.normal,
                        fontWeight: chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (chat.unreadCount > 0) ...[
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
              builder: (context) => LinkedInChatScreen(user: chat.user),
            ),
          );
        },
      ),
    );
  }
}

// Individual Chat Screen - LinkedIn Style
class LinkedInChatScreen extends StatefulWidget {
  final ChatUser user;

  const LinkedInChatScreen({super.key, required this.user});

  @override
  State<LinkedInChatScreen> createState() => _LinkedInChatScreenState();
}

class _LinkedInChatScreenState extends State<LinkedInChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(widget.user.avatar),
                ),
                if (widget.user.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  if (widget.user.title.isNotEmpty)
                    Text(
                      widget.user.title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.grey[700]),
            onPressed: () {
              // Handle user info
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          
          // Messages Area
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.message_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Start a conversation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Send a message to your teammate',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE0E0E0)),

          // Message Input Area
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.grey[600]),
                    onPressed: () {
                      // Handle attachments
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.image_outlined, color: Colors.grey[600]),
                    onPressed: () {
                      // Handle image
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Write a message...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: const Color(0xFFF3F2EF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () {
                        // Handle send message
                        _messageController.clear();
                      },
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
}

// Data Models
class ChatUser {
  final String id;
  final String name;
  final String title;
  final String avatar;
  final bool isOnline;
  final bool hasStory;
  final bool isGroup;
  final bool isVerified;

  ChatUser({
    required this.id,
    required this.name,
    this.title = '',
    required this.avatar,
    this.isOnline = false,
    this.hasStory = false,
    this.isGroup = false,
    this.isVerified = false,
  });
}

class ChatItem {
  final ChatUser user;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final bool isTyping;
  final bool isPinned;
  final MessageStatus? messageStatus;

  ChatItem({
    required this.user,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
    this.isTyping = false,
    this.isPinned = false,
    this.messageStatus,
  });
}

enum MessageStatus { sent, delivered, read }

