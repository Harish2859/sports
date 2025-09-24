import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

// --- App Theme and Colors ---
class AppTheme {
  static const Color background = Color(0xFFF5F5F7);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF888888);
  static const Color incomingBubble = Color(0xFFE5E5EA);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF89CFF0), Color(0xFF6495ED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static TextStyle get contactName => const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get lastMessage => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textSecondary,
      );

  static TextStyle get timestamp => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textSecondary,
      );

  static TextStyle get chatMessage => const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 15,
        fontWeight: FontWeight.normal,
      );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Messaging App',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppTheme.background,
        primarySwatch: Colors.blue,
      ),
      home: const MessagePage(),
    );
  }
}

// -----------------------------------------------------------------------------
// CHAT LIST SCREEN
// -----------------------------------------------------------------------------
class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final List<ChatItem> _allChats = [
    ChatItem(user: ChatUser(id: '1', name: 'Amin El arabi', avatar: 'https://i.pravatar.cc/150?img=12'), lastMessage: 'Where are you now', timestamp: '11:58', unreadCount: 3),
    ChatItem(user: ChatUser(id: '2', name: 'abde Samad Ifasi', avatar: 'https://i.pravatar.cc/150?img=11'), lastMessage: 'Do you like metal music..?', timestamp: '01:50', status: 'read'),
    ChatItem(user: ChatUser(id: '3', name: 'Jannat indila', avatar: 'https://i.pravatar.cc/150?img=5'), lastMessage: '👍👎👍', timestamp: '12:50', status: 'read'),
    ChatItem(user: ChatUser(id: '4', name: 'Fati Lara', avatar: 'https://i.pravatar.cc/150?img=25'), lastMessage: 'All of us, some Friends....', timestamp: '12:44', unreadCount: 1, isSelected: true),
    ChatItem(user: ChatUser(id: '5', name: 'Nisrrin flowers', avatar: 'https://i.pravatar.cc/150?img=47'), lastMessage: 'Gooooood hhhh', timestamp: '11:50', unreadCount: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.surface,
      bottomNavigationBar: const FinalBottomNavBar(),
      body: Column(
        children: [
          const WavyHeader(),
          Expanded(
            child: Container(
              color: AppTheme.surface,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 0),
                itemCount: _allChats.length,
                itemBuilder: (context, index) =>
                    ChatTile(chat: _allChats[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single row in the message list.
class ChatTile extends StatelessWidget {
  final ChatItem chat;
  const ChatTile({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            chat.isSelected ? Colors.blue.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(chat.user.avatar),
        ),
        title: Text(chat.user.name, style: AppTheme.contactName),
        subtitle: Text(
          chat.lastMessage,
          style: AppTheme.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(chat.timestamp, style: AppTheme.timestamp),
            if (chat.unreadCount > 0)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${chat.unreadCount}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              )
            else if (chat.status == 'read')
              const Icon(Icons.done_all, color: Colors.blue, size: 18)
            else
              const SizedBox(height: 20),
          ],
        ),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(user: chat.user))),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// INDIVIDUAL CHAT SCREEN
// -----------------------------------------------------------------------------
class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(text: 'Aymen, are you free this weekend 🙌🙌', timestamp: "11:58", isSentByMe: false),
    ChatMessage(text: 'I guess I am', timestamp: "11:59", isSentByMe: true, status: 'read'),
    ChatMessage(text: 'We are planning to go on a trip', timestamp: "12:38", isSentByMe: false),
    ChatMessage(text: 'All of us, some Friends From work might come too', timestamp: "01:44", isSentByMe: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Column(
        children: [
          // The new Wavy Chat Header is here
          _buildWavyChatHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Center(child: Text("THU 26 April, 2022", style: TextStyle(color: AppTheme.textSecondary)));
                }
                if (index == 4) {
                  return _buildAudioMessageBubble();
                }
                final messageIndex = index > 4 ? index - 2 : index - 1;
                if (messageIndex < 0 || messageIndex >= _messages.length)
                  return const SizedBox.shrink();
                final message = _messages[messageIndex];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  /// Builds the custom wavy header for the chat page.
  Widget _buildWavyChatHeader() {
    return SizedBox(
      height: 140, // Adjusted height for chat header
      child: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 140),
            painter: WavyHeaderPainter(color: AppTheme.background),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                      onPressed: () => Navigator.pop(context)),
                  CircleAvatar(
                      radius: 22, backgroundImage: NetworkImage(widget.user.avatar)),
                  const SizedBox(width: 12),
                  Text(widget.user.name, style: AppTheme.contactName),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.more_horiz, color: AppTheme.textPrimary),
                      onPressed: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMyMessage = message.isSentByMe;
    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: isMyMessage ? AppTheme.primaryGradient : null,
          color: isMyMessage ? null : AppTheme.incomingBubble,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: AppTheme.chatMessage.copyWith(
                  color: isMyMessage ? Colors.white : AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.timestamp,
                  style: AppTheme.timestamp.copyWith(
                      color: isMyMessage
                          ? Colors.white70
                          : AppTheme.textSecondary,
                      fontSize: 11),
                ),
                if (isMyMessage) ...[
                  const SizedBox(width: 5),
                  const Icon(Icons.done_all, color: Colors.white70, size: 16),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioMessageBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.incomingBubble,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                const Icon(Icons.play_arrow, color: AppTheme.textPrimary),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 12.0),
                      trackHeight: 2.0,
                    ),
                    child: Slider(
                      value: 0.5,
                      onChanged: (value) {},
                      activeColor: Colors.blueAccent,
                      inactiveColor: Colors.grey,
                    ),
                  ),
                ),
                const Text("00:33", style: TextStyle(fontSize: 12)),
              ],
            ),
            const Text("01:38",
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: const BoxDecoration(color: AppTheme.surface),
      child: SafeArea(
        child: Row(
          children: [
            const Icon(Icons.mic, color: AppTheme.textSecondary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Write a Message',
                  hintStyle: const TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 22),
                onPressed: () => _messageController.clear(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CUSTOM WAVY HEADER
// -----------------------------------------------------------------------------
class WavyHeader extends StatelessWidget {
  const WavyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 150),
            painter: WavyHeaderPainter(color: AppTheme.background),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.menu, color: AppTheme.textPrimary, size: 28),
                  const Text('LOGO', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const Icon(Icons.search, color: AppTheme.textPrimary, size: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WavyHeaderPainter extends CustomPainter {
  final Color color;
  WavyHeaderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.9, size.width * 0.5, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.5, size.width, size.height * 0.7);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// FINAL SYMMETRICAL WAVY BOTTOM BAR WITH CENTRAL FAB
// -----------------------------------------------------------------------------
class FinalBottomNavBar extends StatefulWidget {
  const FinalBottomNavBar({super.key});

  @override
  State<FinalBottomNavBar> createState() => _FinalBottomNavBarState();
}

class _FinalBottomNavBarState extends State<FinalBottomNavBar> {
  int _selectedIndex = 1; // Default to central FAB

  static const Color navColor = Color(0xFFB3B2E0);
  static const Color iconColor = Colors.white;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fabSize = 64.0;

    return Container(
      height: 110, // Increased height
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Custom painter for the background wave
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 110),
            painter: FinalNavBarPainter(color: navColor),
          ),

          // Central Floating Action Button
          Positioned(
            top: 0,
            left: (MediaQuery.of(context).size.width / 2) - (fabSize / 2),
            child: GestureDetector(
              onTap: () => _onItemTapped(1),
              child: Container(
                width: fabSize,
                height: fabSize,
                decoration: BoxDecoration(
                  color: _selectedIndex == 1 ? Colors.white : navColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _selectedIndex == 1 ? navColor : Colors.white,
                      width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Icon(Icons.add,
                    color: _selectedIndex == 1 ? navColor : iconColor,
                    size: 32),
              ),
            ),
          ),

          // Container for the side icons, positioned safely inside the bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80, // Height for the icon row
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.chat_bubble, 0, badgeCount: 4),
                SizedBox(width: fabSize), // Placeholder for FAB
                _buildNavItem(Icons.people, 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, {int badgeCount = 0}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 30,
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: 0,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: navColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// THIS IS THE NEW PAINTER FOR THE SYMMETRICAL NOTCHED WAVE
class FinalNavBarPainter extends CustomPainter {
  final Color color;
  FinalNavBarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final fabRadius = 45.0; // The radius of the notch

    path.moveTo(0, size.height * 0.4);
    // Left wave
    path.quadraticBezierTo(
        size.width * 0.20, 0, size.width * 0.35, size.height * 0.3);

    // Central notch
    path.arcToPoint(
      Offset(size.width * 0.65, size.height * 0.3),
      radius: Radius.circular(fabRadius),
      clockwise: false,
    );
    
    // Right wave
    path.quadraticBezierTo(
        size.width * 0.80, 0, size.width, size.height * 0.4);

    // Connect to bottom
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// DATA MODELS & OLD CLIPPER
// -----------------------------------------------------------------------------
class InvertedWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 20);
    path.quadraticBezierTo(0, 0, 20, 0);
    path.lineTo(size.width - 20, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(covariant CustomClipper oldClipper) => false;
}

class ChatUser {
  final String id, name, avatar;
  ChatUser({required this.id, required this.name, required this.avatar});
}

class ChatItem {
  final ChatUser user;
  final String lastMessage, timestamp;
  final int unreadCount;
  final String? status;
  final bool isSelected;
  ChatItem(
      {required this.user,
      required this.lastMessage,
      required this.timestamp,
      this.unreadCount = 0,
      this.status,
      this.isSelected = false});
}

class ChatMessage {
  final String text, timestamp;
  final bool isSentByMe;
  final String? status;
  ChatMessage(
      {required this.text,
      required this.timestamp,
      required this.isSentByMe,
      this.status});
}