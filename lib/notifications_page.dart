import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notification_manager.dart';
import 'theme_provider.dart';
import 'player_search_page.dart';
import 'daily_tasks_screen.dart';
import 'myleague.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  void _initializeNotifications() {
    if (!_initialized && NotificationManager.instance.notifications.isEmpty) {
      _initialized = true;
      Future.microtask(() {
        NotificationManager.instance.addFriendRequestNotification('Alex Johnson', 'user_123');
        NotificationManager.instance.addEventNotification('Basketball Championship', 'Dec 25, 2024');
        NotificationManager.instance.addCertificateNotification('Fitness Fundamentals');
        NotificationManager.instance.addDailyTaskCompletedNotification();
        NotificationManager.instance.addNewLeagueNotification('Winter Sports League');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              NotificationManager.instance.markAllAsRead();
              setState(() {});
            },
            child: Text(
              'Mark All Read',
              style: TextStyle(
                color: theme.appBarTheme.foregroundColor,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: theme.appBarTheme.foregroundColor,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Friend Suggestions Section - Always visible
          _buildFriendSuggestions(theme),
          
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          
          // Notifications Section
          Expanded(
            child: AnimatedBuilder(
              animation: NotificationManager.instance,
              builder: (context, child) {
                _initializeNotifications();
                final notifications = NotificationManager.instance.notifications;
                final unreadCount = NotificationManager.instance.unreadCount;

                if (notifications.isEmpty) {
                  return _buildEmptyNotificationsState(theme);
                }

                return Column(
                  children: [
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: theme.primaryColor.withOpacity(0.1),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$unreadCount unread notification${unreadCount > 1 ? 's' : ''}',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return _buildNotificationCard(notification, theme);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyNotificationsState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.notifications_none,
              size: 40,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see updates about events and activities here',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead ? theme.colorScheme.surface : theme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? theme.dividerColor
              : theme.primaryColor.withOpacity(0.2),
        ),
        boxShadow: notification.isRead ? null : [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getNotificationColor(notification.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: _getNotificationColor(notification.type),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: notification.isRead
                              ? theme.textTheme.bodyMedium?.color
                              : theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: notification.isRead
                        ? theme.textTheme.bodySmall?.color
                        : theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTimestamp(notification.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6)),
                ),
                if (notification.type == NotificationType.friendRequest ||
                    notification.type == NotificationType.dailyTask ||
                    notification.type == NotificationType.league)
                  const SizedBox(height: 8),
                if (notification.type == NotificationType.friendRequest)
                  _buildFriendRequestActions(notification),
                if (notification.type == NotificationType.dailyTask)
                  _buildDailyTaskAction(),
                if (notification.type == NotificationType.league)
                  _buildLeagueAction(),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'mark_read') {
                NotificationManager.instance.markAsRead(notification.id);
                setState(() {});
              } else if (value == 'delete') {
                NotificationManager.instance.deleteNotification(notification.id);
                setState(() {});
              }
            },
            itemBuilder: (context) => [
              if (!notification.isRead)
                const PopupMenuItem(
                  value: 'mark_read',
                  child: Text('Mark as Read'),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
            icon: Icon(
              Icons.more_vert,
              color: theme.textTheme.bodySmall?.color,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.event:
        return const Color(0xFF059669);
      case NotificationType.course:
        return const Color(0xFF2563EB);
      case NotificationType.achievement:
        return const Color(0xFFF59E0B);
      case NotificationType.system:
        return const Color(0xFF6B7280);
      case NotificationType.friendRequest:
        return const Color(0xFF8B5CF6);
      case NotificationType.certificate:
        return const Color(0xFFDC2626);
      case NotificationType.dailyTask:
        return const Color(0xFF10B981);
      case NotificationType.league:
        return const Color(0xFFF97316);
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.event:
        return Icons.event;
      case NotificationType.course:
        return Icons.school;
      case NotificationType.achievement:
        return Icons.emoji_events;
      case NotificationType.system:
        return Icons.info;
      case NotificationType.friendRequest:
        return Icons.person_add;
      case NotificationType.certificate:
        return Icons.workspace_premium;
      case NotificationType.dailyTask:
        return Icons.task_alt;
      case NotificationType.league:
        return Icons.sports;
    }
  }

  Widget _buildFriendSuggestions(ThemeData theme) {
    final suggestions = [
      {'name': 'Alex Johnson', 'username': 'alex_runner', 'image': 'https://i.pravatar.cc/100?img=1', 'sport': 'Running'},
      {'name': 'Sarah Wilson', 'username': 'sarah_swimmer', 'image': 'https://i.pravatar.cc/100?img=2', 'sport': 'Swimming'},
      {'name': 'Mike Chen', 'username': 'mike_boxer', 'image': 'https://i.pravatar.cc/100?img=3', 'sport': 'Boxing'},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Suggested for you',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PlayerSearchPage()),
                  );
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return _buildSuggestionCard(suggestion, theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(Map<String, String> suggestion, ThemeData theme) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(suggestion['image']!),
          ),
          const SizedBox(height: 6),
          Text(
            suggestion['name']!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '@${suggestion['username']!}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              suggestion['sport']!,
              style: TextStyle(
                fontSize: 9,
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            height: 28,
            child: ElevatedButton(
              onPressed: () => _addFriend(suggestion['name']!),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('Add', style: TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendRequestActions(NotificationItem notification) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _acceptFriendRequest(notification),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Text('Accept', style: TextStyle(fontSize: 12)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _declineFriendRequest(notification),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Text('Decline', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyTaskAction() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _navigateToDailyTasks(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: const Text('View Daily Tasks', style: TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildLeagueAction() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _navigateToLeague(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: const Text('View League', style: TextStyle(fontSize: 12)),
      ),
    );
  }

  void _acceptFriendRequest(NotificationItem notification) {
    final friendName = notification.actionData?['friendName'] ?? 'Friend';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You are now friends with $friendName!'),
        backgroundColor: Colors.green,
      ),
    );
    NotificationManager.instance.markAsRead(notification.id);
    setState(() {});
  }

  void _declineFriendRequest(NotificationItem notification) {
    final friendName = notification.actionData?['friendName'] ?? 'Friend';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Friend request from $friendName declined'),
        backgroundColor: Colors.red,
      ),
    );
    NotificationManager.instance.deleteNotification(notification.id);
    setState(() {});
  }

  void _navigateToDailyTasks() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DailyTasksScreen()),
    );
  }

  void _navigateToLeague() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyLeaguePage()),
    );
  }

  void _addFriend(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Friend request sent to $name'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}