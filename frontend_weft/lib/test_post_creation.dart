import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  await testPostCreation();
}

Future<void> testPostCreation() async {
  print("🧪 Testing post creation without authentication...");
  
  try {
    // Test 1: JSON format (current frontend approach)
    final jsonUrl = Uri.parse('http://ec2-3-7-223-144.ap-south-1.compute.amazonaws.com:4040/post/create');
    final jsonBody = jsonEncode({'title': 'Test Post', 'content': 'Test Content'});
    
    final jsonResponse = await http.post(
      jsonUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonBody,
    );
    
    print("📡 JSON Request Response: ${jsonResponse.statusCode}");
    print("📡 JSON Response Body: ${jsonResponse.body}");
    
    // Test 2: Multipart form data (backend expects this)
    final multipartRequest = http.MultipartRequest(
      'POST',
      Uri.parse('http://ec2-3-7-223-144.ap-south-1.compute.amazonaws.com:4040/post/create'),
    );
    
    multipartRequest.fields['title'] = 'Test Post Multipart';
    multipartRequest.fields['content'] = 'Test Content Multipart';
    
    final multipartStreamedResponse = await multipartRequest.send();
    final multipartResponse = await http.Response.fromStream(multipartStreamedResponse);
    
    print("📡 Multipart Request Response: ${multipartResponse.statusCode}");
    print("📡 Multipart Response Body: ${multipartResponse.body}");
    
  } catch (e) {
    print("❌ Error: $e");
  }
}
