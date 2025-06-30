import 'dart:convert';
import 'package:frontend_weft/core/constants/server_constants.dart';
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';

Future<Either<String, String>> realLoginApi(String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$ServerConstants/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token']; // 🔁 Replace 'token' with actual key if different
      return right(token);
    } else {
      final data = jsonDecode(response.body);
      return left(data['error'] ?? 'Invalid credentials');
    }
  } catch (e) {
    return left('Network error');
  }
}
