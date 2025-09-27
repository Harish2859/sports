import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'profile_structure_screen.dart';

class AppTheme {
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color primary = Color(0xFF0A66C2);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF666666);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color messageBubble = Color(0xFFE3F2FD);
  static const Color myMessageBubble = Color(0xFF0A66C2);

  static TextStyle get contactName => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get lastMessage => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      );

  static TextStyle get timestamp => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      );

  static TextStyle get chatMessage => const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
      );
}



class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final List<ChatItem> _allChats = [
    ChatItem(user: ChatUser(id: '1', name: 'Alex Johnson', avatar: 'https://i.pravatar.cc/150?img=12', title: 'Sports Coach'), lastMessage: 'Great training session today!', timestamp: '2m', unreadCount: 2),
    ChatItem(user: ChatUser(id: '2', name: 'Sarah Williams', avatar: 'https://i.pravatar.cc/150?img=5', title: 'Fitness Trainer'), lastMessage: 'Ready for tomorrow\'s workout?', timestamp: '1h', status: 'read'),
    ChatItem(user: ChatUser(id: '3', name: 'Mike Chen', avatar: 'https://i.pravatar.cc/150?img=8', title: 'Team Captain'), lastMessage: 'Team meeting at 3 PM', timestamp: '3h', unreadCount: 1),
    ChatItem(user: ChatUser(id: '4', name: 'Emma Davis', avatar: 'https://i.pravatar.cc/150?img=25', title: 'Nutritionist'), lastMessage: 'Here\'s your meal plan', timestamp: '5h', status: 'delivered'),
    ChatItem(user: ChatUser(id: '5', name: 'David Wilson', avatar: 'https://i.pravatar.cc/150?img=15', title: 'Physiotherapist'), lastMessage: 'Recovery session scheduled', timestamp: '1d', status: 'read'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.textSecondary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: _allChats.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: AppTheme.divider,
          indent: 72,
        ),
        itemBuilder: (context, index) => ChatTile(chat: _allChats[index]),
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final ChatItem chat;
  const ChatTile({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(chat.user.avatar),
          backgroundColor: AppTheme.divider,
        ),
        title: Text(chat.user.name, style: AppTheme.contactName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chat.user.title.isNotEmpty)
              Text(
                chat.user.title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            const SizedBox(height: 2),
            Text(
              chat.lastMessage,
              style: AppTheme.lastMessage.copyWith(
                fontWeight: chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(chat.timestamp, style: AppTheme.timestamp),
            const SizedBox(height: 4),
            if (chat.unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${chat.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (chat.status == 'read')
              const Icon(Icons.done_all, color: AppTheme.primary, size: 16)
            else if (chat.status == 'delivered')
              const Icon(Icons.done, color: AppTheme.textSecondary, size: 16),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(user: chat.user),
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(text: 'Hey! Ready for today\'s training session?', timestamp: '10:30 AM', isSentByMe: false),
    ChatMessage(text: 'Absolutely! I\'ve been looking forward to it', timestamp: '10:32 AM', isSentByMe: true, status: 'read'),
    ChatMessage(text: 'Great! We\'ll focus on endurance today', timestamp: '10:35 AM', isSentByMe: false),
    ChatMessage(text: 'Perfect. Should I bring any specific equipment?', timestamp: '10:36 AM', isSentByMe: true, status: 'delivered'),
    ChatMessage(text: 'Just your regular gear. See you at the gym!', timestamp: '10:38 AM', isSentByMe: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildChatAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.divider.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Today',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }
                final message = _messages[index - 1];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildChatAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileStructureScreen(),
            ),
          );
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.user.avatar),
              backgroundColor: AppTheme.divider,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.user.title.isNotEmpty)
                    Text(
                      widget.user.title,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMyMessage = message.isSentByMe;
    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isMyMessage ? AppTheme.myMessageBubble : AppTheme.messageBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMyMessage ? 18 : 4),
            bottomRight: Radius.circular(isMyMessage ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: AppTheme.chatMessage.copyWith(
                color: isMyMessage ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.timestamp,
                  style: AppTheme.timestamp.copyWith(
                    color: isMyMessage ? Colors.white70 : AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
                if (isMyMessage) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.status == 'read' ? Icons.done_all : Icons.done,
                    color: message.status == 'read' ? Colors.white : Colors.white70,
                    size: 14,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.divider, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file, color: AppTheme.textSecondary),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () {
                  if (_messageController.text.trim().isNotEmpty) {
                    // Add message logic here
                    _messageController.clear();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class ChatUser {
  final String id, name, avatar, title;
  ChatUser({required this.id, required this.name, required this.avatar, this.title = ''});
}

class ChatItem {
  final ChatUser user;
  final String lastMessage, timestamp;
  final int unreadCount;
  final String? status;
  final bool isSelected;
  ChatItem({
    required this.user,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
    this.status,
    this.isSelected = false,
  });
}

class ChatMessage {
  final String text, timestamp;
  final bool isSentByMe;
  final String? status;
  ChatMessage({
    required this.text,
    required this.timestamp,
    required this.isSentByMe,
    this.status,
  });
}