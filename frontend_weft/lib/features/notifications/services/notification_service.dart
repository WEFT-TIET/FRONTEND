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
        
        // Handle both array response and object with notifications/data field
        List<dynamic> notificationsJson;
        if (data is List) {
          // Backend returns array directly
          notificationsJson = data;
        } else if (data is Map) {
          // Backend returns object with notifications/data field
          notificationsJson = data['notifications'] ?? data['data'] ?? [];
        } else {
          notificationsJson = [];
        }
        
        return notificationsJson
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      } else {
        print("❌ Failed to fetch notifications: ${response.statusCode} - ${response.body}");
        // Return empty list if backend fails
        return [];
      }
    } catch (e) {
      print("❌ Error fetching notifications: $e");
      // Return empty list if error occurs
      return [];
    }
  }
} 