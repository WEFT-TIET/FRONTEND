import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/server_constants.dart';
import 'package:frontend_weft/core/http_client.dart';
import 'package:frontend_weft/features/settings/models/delete_user_model.dart';

final deleteServiceProvider = Provider<DeleteService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return DeleteService(httpClient);
});

class DeleteService {
  static const String baseUrl = ServerConstants.baseUrl;
  final AppHttpClient _httpClient;

  DeleteService(this._httpClient);

  /// Delete user account - requires email and password as per backend implementation
  Future<DeleteUserResponse> deleteAccount(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/delete/account');
      final body = jsonEncode({
        'email': email,
        'password': password,
      });

      print("🔵 DELETE Account URL: $url");
      print("📦 Request Body: $body");
      print("📧 Email being sent: '$email'");
      print("🔐 Password length: ${password.length}");

      final response = await _httpClient.delete(url, body: body);

      print("📬 Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        // Backend returns plain text "Account successfully deleted"
        return DeleteUserResponse(
          success: true,
          message: response.body,
        );
      } else {
        // Try to get the actual error message from the backend response
        String backendMessage = response.body;
        
        // Handle different error status codes with backend message
        String errorMessage;
        switch (response.statusCode) {
          case 400:
            errorMessage = backendMessage.isNotEmpty ? backendMessage : 'Invalid email or password provided';
            break;
          case 401:
            errorMessage = backendMessage.isNotEmpty ? backendMessage : 'Invalid email or password. Please check your credentials';
            break;
          case 403:
            errorMessage = backendMessage.isNotEmpty ? backendMessage : 'You are not authorized to delete this account';
            break;
          case 404:
            errorMessage = backendMessage.isNotEmpty ? backendMessage : 'Account not found';
            break;
          case 500:
            errorMessage = 'Server error. Please try again later';
            break;
          default:
            errorMessage = backendMessage.isNotEmpty ? backendMessage : 'Failed to delete account. Please try again';
        }
        
        print("❌ Delete account failed: $errorMessage");
        
        return DeleteUserResponse(
          success: false,
          message: errorMessage,
        );
      }
    } catch (e) {
      print("❌ Error deleting account: $e");
      return DeleteUserResponse(
        success: false,
        message: 'Network error. Please check your connection and try again',
      );
    }
  }
}