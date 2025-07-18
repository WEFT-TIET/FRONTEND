// lib/models/user_model.dart
class UserModel {
  final String name;
  final String username;
  final String batch;
  final String branch;
  final String className;
  final List<String> societies;
  final String? profileImagePath;

  UserModel({
    required this.name,
    required this.username,
    required this.batch,
    required this.branch,
    required this.className,
    required this.societies,
    this.profileImagePath,
  });

  UserModel copyWith({
    String? name,
    String? username,
    String? batch,
    String? branch,
    String? className,
    List<String>? societies,
    String? profileImagePath,
  }) {
    return UserModel(
      name: name ?? this.name,
      username: username ?? this.username,
      batch: batch ?? this.batch,
      branch: branch ?? this.branch,
      className: className ?? this.className,
      societies: societies ?? this.societies,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'batch': batch,
      'branch': branch,
      'className': className,
      'societies': societies,
      'profileImagePath': profileImagePath,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      batch: json['batch'] ?? '',
      branch: json['branch'] ?? '',
      className: json['className'] ?? '',
      societies: List<String>.from(json['societies'] ?? []),
      profileImagePath: json['profileImagePath'],
    );
  }
}