import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/utils/logger.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_local_repository.dart';

final httpClientProvider = Provider<AppHttpClient>((ref) {
  final authLocalRepository = ref.watch(authLocalRepositoryProvider);
  return AppHttpClient(authLocalRepository);
});

class AppHttpClient {
  final AuthLocalRepository _authLocalRepository;

  AppHttpClient(this._authLocalRepository);

  /// Get headers with automatic token inclusion as Cookie
  Future<Map<String, String>> _getHeaders({
    Map<String, String>? additionalHeaders,
  }) async {
    final token = await _authLocalRepository.getAccessToken();
    
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?additionalHeaders,
    };

    // Add AccessToken as Cookie if available
    if (token != null && token.isNotEmpty) {
      headers['Cookie'] = 'AccessToken=$token';
    }

    Logger.debug("Token retrieved from storage: '${token ?? 'null'}'");
    Logger.debug("Token included in Cookie: ${token != null && token.isNotEmpty ? 'Yes' : 'No'}");
    Logger.debug("Headers being sent: $headers");
    
    return headers;
  }

  /// GET request with automatic token inclusion
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    final finalHeaders = await _getHeaders(additionalHeaders: headers);
    return await http.get(url, headers: finalHeaders);
  }

  /// POST request with automatic token inclusion
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final finalHeaders = await _getHeaders(additionalHeaders: headers);
    return await http.post(url, headers: finalHeaders, body: body);
  }

  /// PUT request with automatic token inclusion
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final finalHeaders = await _getHeaders(additionalHeaders: headers);
    return await http.put(url, headers: finalHeaders, body: body);
  }

  /// DELETE request with automatic token inclusion
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final finalHeaders = await _getHeaders(additionalHeaders: headers);
    return await http.delete(url, headers: finalHeaders, body: body);
  }

  /// PATCH request with automatic token inclusion
  Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final finalHeaders = await _getHeaders(additionalHeaders: headers);
    return await http.patch(url, headers: finalHeaders, body: body);
  }

  /// Multipart request with automatic token inclusion (for file uploads and form data)
  Future<http.Response> postMultipart(
    Uri url, {
    Map<String, String>? fields,
    Map<String, String>? headers,
    List<http.MultipartFile>? files,
  }) async {
    final token = await _authLocalRepository.getAccessToken();
    
    final request = http.MultipartRequest('POST', url);
    
    // Add fields
    if (fields != null) {
      request.fields.addAll(fields);
    }
    
    // Add files
    if (files != null) {
      request.files.addAll(files);
    }
    
    // Add headers including token as Cookie
    if (headers != null) {
      request.headers.addAll(headers);
    }
    
    if (token != null && token.isNotEmpty) {
      request.headers['Cookie'] = 'AccessToken=$token';
    }

    Logger.debug("Multipart Token retrieved from storage: '${token ?? 'null'}'");
    Logger.debug("Multipart Token included in Cookie: ${token != null && token.isNotEmpty ? 'Yes' : 'No'}");
    Logger.debug("Multipart Headers being sent: ${request.headers}");
    Logger.debug("Multipart Fields being sent: ${request.fields}");
    
    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
} 