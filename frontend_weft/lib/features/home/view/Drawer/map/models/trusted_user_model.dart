class TrustedUserModel {
  final String id;
  final String name;
  final String username;
  final String? imageUrl;
  final bool isOnline;
  final DateTime? lastSeen;
  final double? latitude;
  final double? longitude;
  final bool isGhostMode;

  TrustedUserModel({
    required this.id,
    required this.name,
    required this.username,
    this.imageUrl,
    this.isOnline = false,
    this.lastSeen,
    this.latitude,
    this.longitude,
    this.isGhostMode = false,
  });

  TrustedUserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? imageUrl,
    bool? isOnline,
    DateTime? lastSeen,
    double? latitude,
    double? longitude,
    bool? isGhostMode,
  }) {
    return TrustedUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      imageUrl: imageUrl ?? this.imageUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isGhostMode: isGhostMode ?? this.isGhostMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'imageUrl': imageUrl,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'isGhostMode': isGhostMode,
    };
  }

  factory TrustedUserModel.fromJson(Map<String, dynamic> json) {
    return TrustedUserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      imageUrl: json['imageUrl'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null 
          ? DateTime.parse(json['lastSeen']) 
          : null,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isGhostMode: json['isGhostMode'] ?? false,
    );
  }
} 