import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/server_constants.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_local_repository.dart';
import 'package:http/http.dart' as http;
import '../model/post_model.dart'; // adjust path as needed

final postsProvider = FutureProvider<List<PostModel>>((ref) async {
  final repo = ref.read(authLocalRepositoryProvider);
  final token = await repo.getAccessToken();

  if (token == null) {
    throw Exception("Access Token not present");
  }

  final response = await http.get(
    Uri.parse("${ServerConstants.baseUrl}/post/view"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((json) => PostModel.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load posts: ${response.body}');
  }
});

