class User {
  final String name;
  final String email;
  final String year;
  final String classId;
  final String branch;

  User({
    required this.name,
    required this.email,
    required this.year,
    required this.classId,
    required this.branch,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        name: json['name'],
        email: json['email'],
        year: json['year'],
        classId: json['class_id'],
        branch: json['branch'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'year': year,
        'class_id': classId,
        'branch': branch,
      };
}
