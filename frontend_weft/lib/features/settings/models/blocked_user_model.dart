class BlockedUser {
  final String id;
  final String name;
  final String branch;
  final String year;

  const BlockedUser({
    required this.id,
    required this.name,
    required this.branch,
    required this.year,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      branch: json['branch'] ?? '',
      year: json['year'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'branch': branch,
      'year': year,
    };
  }
} 