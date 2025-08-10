class SkillModel {
  final int id;
  final String skillName;

  SkillModel({
    required this.id,
    required this.skillName,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'] ?? 0,
      skillName: json['skill_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skill_name': skillName,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
