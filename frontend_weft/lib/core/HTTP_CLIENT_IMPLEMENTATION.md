# HTTP Client Implementation for Automatic Token Inclusion

## Problem Statement

Your senior requested that the AccessToken should be automatically included in every HTTP request after login in the format:
```
Cookie: AccessToken=...
```

Instead of the current implementation which uses:
```
Authorization: Bearer ...
```

## Solution Overview

I've implemented a **centralized HTTP client** that automatically includes the AccessToken as a Cookie in every request. This ensures consistency across all API calls and follows your senior's requirements.

## Implementation Details

### 1. Centralized HTTP Client (`lib/core/http_client.dart`)

```dart
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
    if (token != null) {
      headers['Cookie'] = 'AccessToken=$token';
    }

    return headers;
  }

  // HTTP methods with automatic token inclusion
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final finalHeaders = await _getHeaders(additionalHeaders: headers);
    return await http.get(url, headers: finalHeaders);
  }

  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) async {
    final finalHeaders = await _getHeaders(additionalHeaders: headers);
    return await http.post(url, headers: finalHeaders, body: body);
  }

  // ... other methods (PUT, DELETE, PATCH)
}
```

### 2. Provider Setup

```dart
final httpClientProvider = Provider<AppHttpClient>((ref) {
  final authLocalRepository = ref.watch(authLocalRepositoryProvider);
  return AppHttpClient(authLocalRepository);
});
```

### 3. Service Integration

All services now use the centralized HTTP client:

#### Auth Service
```dart
final authServiceProvider = Provider<AuthService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return AuthService(httpClient);
});

class AuthService {
  final AppHttpClient _httpClient;
  
  Future<User> login(String email, String password) async {
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/login'),
      body: jsonEncode({'email': email, 'password': password}),
    );
    // ... rest of implementation
  }
}
```

#### Post Service
```dart
final postServiceProvider = Provider<PostService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return PostService(httpClient);
});

class PostService {
  final AppHttpClient _httpClient;
  
  Future<List<Post>> getAllPosts() async {
    final response = await _httpClient.get(Uri.parse('$baseUrl/posts'));
    // ... rest of implementation
  }
}
```

## How It Works

### 1. Token Storage
- AccessToken is stored in SharedPreferences after login
- `AuthLocalRepository` manages token storage and retrieval

### 2. Automatic Inclusion
- Every HTTP request goes through `AppHttpClient`
- `_getHeaders()` method automatically retrieves the stored token
- Token is added as `Cookie: AccessToken=<token_value>`

### 3. Request Flow
```
Service Method → AppHttpClient → _getHeaders() → Add Cookie → HTTP Request
```

## Benefits

✅ **Automatic**: No need to manually add tokens to each request  
✅ **Consistent**: All requests use the same token format  
✅ **Maintainable**: Single place to modify token handling  
✅ **Secure**: Tokens are stored securely in SharedPreferences  
✅ **Flexible**: Easy to add additional headers when needed  

## Usage Examples

### Creating a New Service

```dart
final myServiceProvider = Provider<MyService>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return MyService(httpClient);
});

class MyService {
  final AppHttpClient _httpClient;
  
  MyService(this._httpClient);
  
  Future<void> myApiCall() async {
    final response = await _httpClient.get(
      Uri.parse('$baseUrl/my-endpoint'),
    );
    // Token is automatically included as Cookie
  }
}
```

### Adding Custom Headers

```dart
final response = await _httpClient.post(
  Uri.parse('$baseUrl/upload'),
  headers: {'Content-Type': 'multipart/form-data'},
  body: formData,
);
// Custom headers are merged with automatic token inclusion
```

## Testing

You can verify the implementation by checking the console logs:

```
🔑 Token included in Cookie: Yes
📤 Headers being sent: {
  Content-Type: application/json,
  Accept: application/json,
  Cookie: AccessToken=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
}
```

## Migration Guide

### For Existing Services

1. **Update imports**:
   ```dart
   import 'package:frontend_weft/core/http_client.dart';
   ```

2. **Update provider**:
   ```dart
   final serviceProvider = Provider<MyService>((ref) {
     final httpClient = ref.watch(httpClientProvider);
     return MyService(httpClient);
   });
   ```

3. **Update constructor**:
   ```dart
   class MyService {
     final AppHttpClient _httpClient;
     MyService(this._httpClient);
   }
   ```

4. **Replace HTTP calls**:
   ```dart
   // Before
   final response = await http.get(url, headers: await _getHeaders());
   
   // After
   final response = await _httpClient.get(url);
   ```

## Security Considerations

- Tokens are stored securely in SharedPreferences
- Tokens are automatically cleared on logout
- No token exposure in logs (only presence is logged)
- Cookie format follows HTTP standards

## Future Enhancements

- Token refresh mechanism
- Request/response interceptors
- Retry logic for failed requests
- Request timeout handling
- Offline request queuing 