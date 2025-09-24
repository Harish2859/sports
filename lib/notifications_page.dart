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
    // Ensures sample data is added only once after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  void _initializeNotifications() {
    if (!mounted || _initialized) return;

    if (NotificationManager.instance.notifications.isEmpty) {
      NotificationManager.instance.addFriendRequestNotification('Alex Johnson', 'user_123');
      NotificationManager.instance.addEventNotification('Basketball Championship', 'Dec 25, 2024');
      NotificationManager.instance.addCertificateNotification('Fitness Fundamentals');
      NotificationManager.instance.addDailyTaskCompletedNotification();
      NotificationManager.instance.addNewLeagueNotification('Winter Sports League');
    }
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        // UI ENHANCEMENT: Made AppBar transparent for a seamless look
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.bold, // Bolder title for emphasis
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // UI ENHANCEMENT: Changed TextButton to a more minimal IconButton
          IconButton(
            tooltip: 'Mark All As Read',
            icon: Icon(Icons.done_all, color: theme.colorScheme.onBackground),
            onPressed: () {
              NotificationManager.instance.markAllAsRead();
            },
          ),
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: theme.colorScheme.onBackground,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: NotificationManager.instance,
        builder: (context, child) {
          final notifications = NotificationManager.instance.notifications;
          // UI ENHANCEMENT: Using ListView for the whole body for a consistent scroll experience
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              _buildFriendSuggestions(theme),
              const SizedBox(height: 16),
              Text(
                'Recent',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (notifications.isEmpty)
                _buildEmptyNotificationsState(theme)
              else
                // UI ENHANCEMENT: Using Column instead of ListView.builder since the parent is now a ListView
                Column(
                  children: notifications
                      .map((notification) => _buildNotificationCard(notification, theme))
                      .toList(),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyNotificationsState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 60,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No notifications yet',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll see updates about events and activities here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, ThemeData theme) {
    // UI ENHANCEMENT: Using a subtle background and no border/shadow for a flatter, cleaner look.
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unread indicator is now the primary visual cue
          if (!notification.isRead)
            Container(
              margin: const EdgeInsets.only(right: 12, top: 12),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          if (notification.isRead) const SizedBox(width: 20), // Placeholder for alignment
          Icon(
            _getNotificationIcon(notification.type),
            color: theme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: !notification.isRead ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTimestamp(notification.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),
                if (notification.type == NotificationType.friendRequest) ...[
                  const SizedBox(height: 12),
                  _buildFriendRequestActions(notification, theme),
                ],
                if (notification.type == NotificationType.dailyTask) ...[
                  const SizedBox(height: 12),
                  _buildDailyTaskAction(theme),
                ],
                if (notification.type == NotificationType.league) ...[
                  const SizedBox(height: 12),
                  _buildLeagueAction(theme),
                ],
              ],
            ),
          ),
          // UI ENHANCEMENT: Made popup menu icon more subtle
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            onSelected: (value) {
              if (value == 'mark_read') {
                NotificationManager.instance.markAsRead(notification.id);
              } else if (value == 'delete') {
                NotificationManager.instance.deleteNotification(notification.id);
              }
            },
            itemBuilder: (context) => [
              if (!notification.isRead)
                const PopupMenuItem(value: 'mark_read', child: Text('Mark as Read')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  // UI ENHANCEMENT: This method is no longer needed for coloring, as we use a unified theme color
  // Color _getNotificationColor(NotificationType type) { ... }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.event:
        return Icons.event_available_outlined;
      case NotificationType.course:
        return Icons.school_outlined;
      case NotificationType.achievement:
        return Icons.emoji_events_outlined;
      case NotificationType.system:
        return Icons.info_outline;
      case NotificationType.friendRequest:
        return Icons.person_add_alt_1_outlined;
      case NotificationType.certificate:
        return Icons.workspace_premium_outlined;
      case NotificationType.dailyTask:
        return Icons.task_alt_outlined;
      case NotificationType.league:
        return Icons.sports_esports_outlined;
    }
  }

  // UI ENHANCEMENT: Renamed for clarity and improved the title styling.
  Widget _buildFriendSuggestions(ThemeData theme) {
    final suggestions = [
      {'name': 'Alex Johnson', 'username': 'alex_runner', 'image': 'https://i.pravatar.cc/100?img=1'},
      {'name': 'Sarah Wilson', 'username': 'sarah_swimmer', 'image': 'https://i.pravatar.cc/100?img=2'},
      {'name': 'Mike Chen', 'username': 'mike_boxer', 'image': 'https://i.pravatar.cc/100?img=3'},
      {'name': 'Emily Davis', 'username': 'em_cyclist', 'image': 'https://i.pravatar.cc/100?img=4'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Using a more direct title
            Text(
              'Discover Players',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PlayerSearchPage()));
              },
              child: Text(
                'See All',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 170, // Increased height slightly for better spacing
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // Added a clip behavior to prevent any overflow issues with shadows or borders
            clipBehavior: Clip.none,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return _buildSuggestionCard(suggestion, theme);
            },
          ),
        ),
      ],
    );
  }

  // UI ENHANCEMENT: The card is now significantly more minimal.
  Widget _buildSuggestionCard(Map<String, String> suggestion, ThemeData theme) {
    return Container(
      width: 135,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        // Using a subtle outline instead of a solid background color for a lighter feel
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30, // Reduced from 32 to fit better
            backgroundImage: NetworkImage(suggestion['image']!),
          ),
          const SizedBox(height: 8),
          Text(
            suggestion['name']!,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '@${suggestion['username']!}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Replaced the button with a simple, clean icon button for adding friends.
          SizedBox(
            height: 32,
            width: 32,
            child: IconButton(
              onPressed: () => _addFriend(suggestion['name']!),
              style: IconButton.styleFrom(
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                foregroundColor: theme.primaryColor,
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
              tooltip: 'Add Friend',
            ),
          ),
        ],
      ),
    );
  }

  // UI ENHANCEMENT: Action buttons are now lighter TextButtons instead of solid buttons.
  Widget _buildFriendRequestActions(NotificationItem notification, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => _acceptFriendRequest(notification),
            style: TextButton.styleFrom(
              backgroundColor: Colors.green.withOpacity(0.1),
              foregroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextButton(
            onPressed: () => _declineFriendRequest(notification),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Decline'),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyTaskAction(ThemeData theme) {
    return TextButton(
      onPressed: () => _navigateToDailyTasks(),
      style: TextButton.styleFrom(
        backgroundColor: theme.primaryColor.withOpacity(0.1),
        foregroundColor: theme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(double.infinity, 40),
      ),
      child: const Text('View Daily Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLeagueAction(ThemeData theme) {
    return TextButton(
      onPressed: () => _navigateToLeague(),
      style: TextButton.styleFrom(
        backgroundColor: Colors.orange.withOpacity(0.1),
        foregroundColor: Colors.orange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(double.infinity, 40),
      ),
      child: const Text('View League', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // --- Helper & Action Methods (No UI changes needed here) ---

  void _acceptFriendRequest(NotificationItem notification) {
    final friendName = notification.actionData?['friendName'] ?? 'Friend';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You are now friends with $friendName!'), backgroundColor: Colors.green),
    );
    NotificationManager.instance.deleteNotification(notification.id);
  }

  void _declineFriendRequest(NotificationItem notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friend request declined'), backgroundColor: Colors.red),
    );
    NotificationManager.instance.deleteNotification(notification.id);
  }

  void _navigateToDailyTasks() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const DailyTasksScreen()));
  }

  void _navigateToLeague() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MyLeaguePage()));
  }

  void _addFriend(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Friend request sent to $name'), backgroundColor: Colors.blue),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}