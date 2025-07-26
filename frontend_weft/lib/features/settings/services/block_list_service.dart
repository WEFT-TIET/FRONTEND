import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/server_constants.dart';
import 'package:frontend_weft/core/http_client.dart';
import 'package:frontend_weft/features/settings/models/blocked_user_model.dart';

final blockListServiceProvider = Provider<BlockListService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return BlockListService(httpClient);
});

class BlockListService {
  static const String baseUrl = ServerConstants.baseUrl;
  final AppHttpClient _httpClient;

  BlockListService(this._httpClient);

  // Get list of blocked users
  Future<List<BlockedUser>> getBlockedUsers() async {
    try {
      final url = Uri.parse('$baseUrl/blocklist');
      final response = await _httpClient.get(url);

      print("🔵 GET Block List URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((json) => BlockedUser.fromJson(json)).toList();
        } else {
          print("⚠️ Unexpected response format: $data");
          return [];
        }
      } else {
        print("❌ Failed to fetch block list: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching block list: $e");
      return [];
    }
  }

  // Unblock a user
  Future<bool> unblockUser(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/unblock/user?id=$userId');
      final response = await _httpClient.post(url);

      print("🔵 POST Unblock User URL: $url");
      print("📬 Response (${response.statusCode}): ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error unblocking user: $e");
      return false;
    }
  }
} 