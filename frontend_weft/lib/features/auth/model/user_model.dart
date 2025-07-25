class User {
  final String id;
  final String name;
  final String email;
  final String year;
  final String branch;
  final String accessToken;
  final String? refreshToken;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.year,
    required this.branch,
    required this.accessToken,
    this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    year: json['year'],
    branch: json['branch'],
    accessToken: json['accessToken'] ?? '',
    refreshToken: json['refreshToken'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'year': year,
    'branch': branch,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
  };
}
