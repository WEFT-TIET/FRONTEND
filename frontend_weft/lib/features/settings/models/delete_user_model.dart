class DeleteUserRequest {
  final String email;
  final String password;

  DeleteUserRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class DeleteUserResponse {
  final bool success;
  final String message;

  DeleteUserResponse({
    required this.success,
    required this.message,
  });

  factory DeleteUserResponse.fromJson(Map<String, dynamic> json) {
    return DeleteUserResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}