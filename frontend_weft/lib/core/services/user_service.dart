import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../http_client.dart';

class UserService {
  static Future<Map<String, dynamic>> searchUsers({
    String? name,
    String? year,
    String? username,
    String? branch,
    String? skill,
    AppHttpClient? client, 
  }) async {
    try {
      if (client == null) {
        throw ArgumentError('AppHttpClient must be provided');
      }
      final appClient = client;

      Map<String, String> queryParams = {};
      if (name != null && name.isNotEmpty) queryParams['name'] = name;
      if (year != null && year.isNotEmpty) queryParams['year'] = year;
      if (username != null && username.isNotEmpty) queryParams['username'] = username;
      if (branch != null && branch.isNotEmpty) queryParams['branch'] = branch;
      
      // The key has been corrected from 'skill' to 'skills' to match your backend.
      if (skill != null && skill.isNotEmpty) queryParams['skills'] = skill;

      Uri uri = Uri.parse(ApiConfig.searchUsersUrl).replace(
        queryParameters: queryParams,
      );

      // API call using AppHttpClient
      final response = await appClient.get(
        uri,
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Combined search for both name and username
  static Future<Map<String, dynamic>> searchUsersByNameOrUsername({
    required String query,
    AppHttpClient? client,
  }) async {
    try {
      if (client == null) {
        throw ArgumentError('AppHttpClient must be provided');
      }

      // Make two parallel searches - one by name, one by username
      final futures = await Future.wait([
        searchUsers(name: query, client: client),
        searchUsers(username: query, client: client),
      ]);

      final nameResults = futures[0];
      final usernameResults = futures[1];

      // Combine results and remove duplicates
      Set<String> seenIds = <String>{};
      List<dynamic> combinedUsers = [];

      // Add users from name search
      if (nameResults['success'] && nameResults['data'] != null) {
        final nameUsers = nameResults['data'] as List<dynamic>;
        for (var user in nameUsers) {
          final userId = user['id'].toString();
          if (!seenIds.contains(userId)) {
            seenIds.add(userId);
            combinedUsers.add(user);
          }
        }
      }

      // Add users from username search (avoid duplicates)
      if (usernameResults['success'] && usernameResults['data'] != null) {
        final usernameUsers = usernameResults['data'] as List<dynamic>;
        for (var user in usernameUsers) {
          final userId = user['id'].toString();
          if (!seenIds.contains(userId)) {
            seenIds.add(userId);
            combinedUsers.add(user);
          }
        }
      }

      return {
        'success': true,
        'data': combinedUsers,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      Uri uri = Uri.parse('${ApiConfig.getUserProfileUrl}/$userId');

      final response = await http.get(
        uri,
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerUserUrl),
        headers: ApiConfig.defaultHeaders,
        body: json.encode(userData),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
}