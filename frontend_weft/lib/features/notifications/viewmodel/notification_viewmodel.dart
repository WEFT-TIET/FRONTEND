// lib/features/notifications/viewmodel/notification_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/features/notifications/services/notification_service.dart';
import 'package:frontend_weft/features/notifications/models/notification_model.dart';

// State class for managing notification operations
class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

// NotificationViewModel that manages notification state
class NotificationViewModel extends StateNotifier<NotificationState> {
  final NotificationService _notificationService;

  NotificationViewModel(this._notificationService) : super(const NotificationState());

  // Fetch all notifications
  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final notifications = await _notificationService.getNotifications();
      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Fetch unread count
  Future<void> fetchUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      state = state.copyWith(unreadCount: count);
    } catch (e) {
      print("Error fetching unread count: $e");
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await _notificationService.markAsRead(notificationId);
      if (success) {
        // Update local state
        final updatedNotifications = state.notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();

        state = state.copyWith(notifications: updatedNotifications);
        
        // Update unread count
        await fetchUnreadCount();
      }
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final success = await _notificationService.markAllAsRead();
      if (success) {
        // Update local state
        final updatedNotifications = state.notifications.map((notification) {
          return notification.copyWith(isRead: true);
        }).toList();

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        );
      }
    } catch (e) {
      print("Error marking all notifications as read: $e");
    }
  }

  // Follow a user
  Future<void> followUser(String userId) async {
    try {
      final success = await _notificationService.followUser(userId);
      if (success) {
        // You could update the UI to show "Following" state
        print("Successfully followed user: $userId");
      }
    } catch (e) {
      print("Error following user: $e");
    }
  }

  // Like a post
  Future<void> likePost(String postId) async {
    try {
      final success = await _notificationService.likePost(postId);
      if (success) {
        // You could update the UI to show "Liked" state
        print("Successfully liked post: $postId");
      }
    } catch (e) {
      print("Error liking post: $e");
    }
  }

  // Get notifications grouped by time (Instagram style)
  Map<String, List<NotificationModel>> getGroupedNotifications() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeek = today.subtract(const Duration(days: 7));
    final thisMonth = today.subtract(const Duration(days: 30));

    final grouped = <String, List<NotificationModel>>{};

    for (final notification in state.notifications) {
      final notificationDate = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      String groupKey;
      if (notificationDate.isAtSameMomentAs(today)) {
        groupKey = 'Today';
      } else if (notificationDate.isAtSameMomentAs(yesterday)) {
        groupKey = 'Yesterday';
      } else if (notificationDate.isAfter(thisWeek)) {
        groupKey = 'This week';
      } else if (notificationDate.isAfter(thisMonth)) {
        groupKey = 'This month';
      } else {
        groupKey = 'Earlier';
      }

      grouped.putIfAbsent(groupKey, () => []).add(notification);
    }

    return grouped;
  }

  // Get unread notifications count
  int get unreadCount => state.unreadCount;

  // Get all notifications
  List<NotificationModel> get notifications => state.notifications;

  // Get loading state
  bool get isLoading => state.isLoading;

  // Get error state
  String? get error => state.error;
}

// Provider for NotificationViewModel
final notificationViewModelProvider = StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationViewModel(notificationService);
});

// Provider for unread count
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationViewModelProvider).unreadCount;
}); 