import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final Map<String, dynamic>? actionData;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.actionData,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum NotificationType {
  event,
  course,
  achievement,
  system,
  friendRequest,
  certificate,
  dailyTask,
  league,
}

class NotificationManager extends ChangeNotifier {
  static NotificationManager? _instance;
  static NotificationManager get instance {
    _instance ??= NotificationManager._internal();
    return _instance!;
  }

  factory NotificationManager() => instance;
  NotificationManager._internal();

  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  List<NotificationItem> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  int get unreadCount => unreadNotifications.length;

  void addNotification({
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? actionData,
  }) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
      actionData: actionData,
    );

    _notifications.insert(0, notification);
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  // Helper methods for different types of notifications
  void addEventNotification(String eventName, String eventDate) {
    addNotification(
      title: 'New Event Posted',
      message: '$eventName has been scheduled for $eventDate',
      type: NotificationType.event,
    );
  }

  void addFriendRequestNotification(String friendName, String friendId) {
    addNotification(
      title: 'Friend Request',
      message: '$friendName wants to be your friend',
      type: NotificationType.friendRequest,
      actionData: {'friendName': friendName, 'friendId': friendId},
    );
  }

  void addCertificateNotification(String certificateName) {
    addNotification(
      title: 'Certificate Earned!',
      message: 'Congratulations! You earned: $certificateName',
      type: NotificationType.certificate,
    );
  }

  void addDailyTaskCompletedNotification() {
    addNotification(
      title: 'Daily Task Completed!',
      message: 'Great job! You completed your daily tasks. Keep up the streak!',
      type: NotificationType.dailyTask,
    );
  }

  void addNewLeagueNotification(String leagueName) {
    addNotification(
      title: 'New League Available',
      message: 'Join the $leagueName and compete with other athletes!',
      type: NotificationType.league,
    );
  }

  void addCourseNotification(String courseName) {
    addNotification(
      title: 'Course Update',
      message: 'New course available: $courseName',
      type: NotificationType.course,
    );
  }

  void addAchievementNotification(String achievementName) {
    addNotification(
      title: 'Achievement Unlocked!',
      message: 'Congratulations! You earned: $achievementName',
      type: NotificationType.achievement,
    );
  }

  void addSystemNotification(String message) {
    addNotification(
      title: 'System Update',
      message: message,
      type: NotificationType.system,
    );
  }


}
