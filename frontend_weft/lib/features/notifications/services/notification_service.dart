// lib/features/notifications/services/notification_service.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/server_constants.dart';
import 'package:frontend_weft/core/http_client.dart';
import 'package:frontend_weft/features/notifications/models/notification_model.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return NotificationService(httpClient);
});

class NotificationService {
  static const String baseUrl = ServerConstants.baseUrl;
  final AppHttpClient _httpClient;

  NotificationService(this._httpClient);

  /// Get all notifications for the current user
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final url = Uri.parse('$baseUrl/notifications');
      final response = await _httpClient.get(url);

      print("🔔 GET Notifications URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> notificationsJson = data['notifications'] ?? data['data'] ?? [];
        
        return notificationsJson
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      } else {
        print("❌ Failed to fetch notifications: ${response.statusCode} - ${response.body}");
        // Return mock data for development
        return MockNotificationData.getNotifications();
      }
    } catch (e) {
      print("❌ Error fetching notifications: $e");
      // Return mock data for development
      return MockNotificationData.getNotifications();
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final url = Uri.parse('$baseUrl/notifications/$notificationId/read');
      final response = await _httpClient.post(url);

      print("🔔 PUT Mark Read URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Error marking notification as read: $e");
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final url = Uri.parse('$baseUrl/notifications/read-all');
      final response = await _httpClient.post(url);

      print("🔔 PUT Mark All Read URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Error marking all notifications as read: $e");
      return false;
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final url = Uri.parse('$baseUrl/notifications/unread-count');
      final response = await _httpClient.get(url);

      print("🔔 GET Unread Count URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      } else {
        print("❌ Failed to fetch unread count: ${response.statusCode} - ${response.body}");
        // Return mock count for development
        return 3;
      }
    } catch (e) {
      print("❌ Error fetching unread count: $e");
      // Return mock count for development
      return 3;
    }
  }

  /// Follow a user (for follow notifications)
  Future<bool> followUser(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/users/$userId/follow');
      final response = await _httpClient.post(url);

      print("🔔 POST Follow User URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Error following user: $e");
      return false;
    }
  }

  /// Like a post (for like notifications)
  Future<bool> likePost(String postId) async {
    try {
      final url = Uri.parse('$baseUrl/posts/$postId/like');
      final response = await _httpClient.post(url);

      print("🔔 POST Like Post URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Error liking post: $e");
      return false;
    }
  }
} 