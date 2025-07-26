class UserModel {
  final String username;
  final String password;

  UserModel({
    required this.username,
    required this.password,
  });

  UserModel copyWith({
    String? username,
    String? password,
  }) {
    return UserModel(
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      password: json['password'] ?? '',
    );
  }
}