// lib/models/user_model.dart
class UserModel {
  final String name;
  final String batch;
  final String branch;
  final String className;
  final List<String> societies;
  final String? profileImagePath;
  final String house;

  UserModel({
    required this.name,
    required this.batch,
    required this.branch,
    required this.className,
    required this.societies,
    this.profileImagePath,
    this.house = 'House',
  });

  UserModel copyWith({
    String? name,
    String? batch,
    String? branch,
    String? className,
    List<String>? societies,
    String? profileImagePath,
    String? house,
  }) {
    return UserModel(
      name: name ?? this.name,
      batch: batch ?? this.batch,
      branch: branch ?? this.branch,
      className: className ?? this.className,
      societies: societies ?? this.societies,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      house: house ?? this.house,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'batch': batch,
      'branch': branch,
      'className': className,
      'societies': societies,
      'profileImagePath': profileImagePath,
      'house': house,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      batch: json['batch'] ?? '',
      branch: json['branch'] ?? '',
      className: json['className'] ?? '',
      societies: List<String>.from(json['societies'] ?? []),
      profileImagePath: json['profileImagePath'],
      house: json['house'] ?? 'House',
    );
  }
}