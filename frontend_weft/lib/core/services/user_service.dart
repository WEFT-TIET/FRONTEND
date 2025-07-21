import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../http_client.dart';

class UserService {
  static Future<Map<String, dynamic>> searchUsers({
    String? name,
    String? year,
    String? branch,
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
      if (branch != null && branch.isNotEmpty) queryParams['branch'] = branch;

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
          'error': 'Server error:  {response.statusCode}',
        };
      }
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