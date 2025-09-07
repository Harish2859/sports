import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notification_manager.dart';
import 'theme_provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
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
      body: AnimatedBuilder(
        animation: NotificationManager.instance,
        builder: (context, child) {
          final notifications = NotificationManager.instance.notifications;
          final unreadCount = NotificationManager.instance.unreadCount;

          if (notifications.isEmpty) {
            return _buildEmptyState(theme);
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
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
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
    }
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