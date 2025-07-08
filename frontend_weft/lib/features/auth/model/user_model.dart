class User {
  final String id;
  final String name;
  final String email;
  final String year;
  final String classId;
  final String branch;
  final String accessToken; // ✅ Add this

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.year,
    required this.classId,
    required this.branch,
    required this.accessToken,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        year: json['year'],
        classId: json['class_id'],
        branch: json['branch'],
        accessToken: json['accessToken'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'year': year,
        'class_id': classId,
        'branch': branch,
        'accessToken': accessToken,
      };
}
