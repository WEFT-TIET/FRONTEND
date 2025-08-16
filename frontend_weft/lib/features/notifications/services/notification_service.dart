// lib/features/notifications/services/notification_service.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/server_constants.dart';
import 'package:frontend_weft/core/http_client.dart';
import 'package:frontend_weft/core/utils/logger.dart';
import 'package:frontend_weft/features/notifications/models/notification_model.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return NotificationService(httpClient);
});

class NotificationService {
  static const String baseUrl = ServerConstants.baseUrl;
  final AppHttpClient _httpClient;

  NotificationService(this._httpClient);

  /// Get all notifications for the current user with pagination support
  Future<List<NotificationModel>> getNotifications({int page = 1}) async {
    try {
      final url = Uri.parse('$baseUrl/notifications?page=$page');
      final response = await _httpClient.get(url);

      Logger.debug("🔵 GET Notifications URL: $url");
      Logger.debug("📬 Response (${response.statusCode}): ${response.body}");

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
        
        Logger.debug("📋 Found ${notificationsJson.length} notifications");
        
        return notificationsJson
            .map((json) {
              try {
                return NotificationModel.fromJson(json);
              } catch (e) {
                Logger.error("Error parsing notification: $e");
                Logger.debug("Problematic JSON: $json");
                return null;
              }
            })
            .where((notification) => notification != null)
            .cast<NotificationModel>()
            .toList();
      } else {
        Logger.error("❌ Failed to fetch notifications: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      Logger.error("❌ Error fetching notifications", e);
      return [];
    }
  }
} 