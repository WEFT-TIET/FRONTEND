// lib/features/notifications/viewmodel/notification_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/features/notifications/services/notification_service.dart';
import 'package:frontend_weft/features/notifications/models/notification_model.dart';

// State class for managing notification operations
class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
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