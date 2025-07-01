// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String name;
  final String year;
  final String branch;
  final String class_id;
  final String email;
  final String id;
  final String token;
  UserModel({
    required this.name,
    required this.year,
    required this.branch,
    required this.class_id,
    required this.email,
    required this.id,
    required this.token,
  });

  UserModel copyWith({
    String? name,
    String? year,
    String? branch,
    String? class_id,
    String? email,
    String? id,
    String? token,
  }) {
    return UserModel(
      name: name ?? this.name,
      year: year ?? this.year,
      branch: branch ?? this.branch,
      class_id: class_id ?? this.class_id,
      email: email ?? this.email,
      id: id ?? this.id,
      token: token ?? this.token,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'year': year,
      'branch': branch,
      'class_id': class_id,
      'email': email,
      'id': id,
      'token': token,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String,
      year: map['year'] as String,
      branch: map['branch'] as String,
      class_id: map['class_id'] as String,
      email: map['email'] as String,
      id: map['id'] as String,
      token: map['token'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(name: $name, year: $year, branch: $branch, class_id: $class_id, email: $email, id: $id, token: $token)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.name == name &&
      other.year == year &&
      other.branch == branch &&
      other.class_id == class_id &&
      other.email == email &&
      other.id == id &&
      other.token == token;
  }

  @override
  int get hashCode {
    return name.hashCode ^
      year.hashCode ^
      branch.hashCode ^
      class_id.hashCode ^
      email.hashCode ^
      id.hashCode ^
      token.hashCode;
  }
}
