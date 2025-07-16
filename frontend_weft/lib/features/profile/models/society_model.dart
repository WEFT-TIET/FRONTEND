// lib/models/society_model.dart
class SocietyModel {
  final String id;
  final String name;
  final String description;
  final String category;

  SocietyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
    };
  }

  factory SocietyModel.fromJson(Map<String, dynamic> json) {
    return SocietyModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
    );
  }
}

// Available societies data
class SocietyData {
  static final List<SocietyModel> availableSocieties = [
    // Technical Societies
    SocietyModel(
      id: 'mlsc',
      name: 'MLSC',
      description: 'Microsoft Learn Student Chapter',
      category: 'Technical',
    ),
    SocietyModel(
      id: 'ccs',
      name: 'CCS',
      description: 'Computer Club Society',
      category: 'Technical',
    ),
    SocietyModel(
      id: 'ieee',
      name: 'IEEE',
      description: 'Institute of Electrical and Electronics Engineers',
      category: 'Technical',
    ),
    SocietyModel(
      id: 'acm',
      name: 'ACM',
      description: 'Association for Computing Machinery',
      category: 'Technical',
    ),
    SocietyModel(
      id: 'gdsc',
      name: 'GDSC',
      description: 'Google Developer Student Club',
      category: 'Technical',
    ),
    SocietyModel(
      id: 'robotics',
      name: 'Robotics Club',
      description: 'Robotics and Automation Club',
      category: 'Technical',
    ),
    
    // Cultural Societies
    SocietyModel(
      id: 'music',
      name: 'Music Society',
      description: 'Music and Performance Club',
      category: 'Cultural',
    ),
    SocietyModel(
      id: 'dance',
      name: 'Dance Society',
      description: 'Dance and Choreography Club',
      category: 'Cultural',
    ),
    SocietyModel(
      id: 'drama',
      name: 'Drama Club',
      description: 'Theater and Drama Society',
      category: 'Cultural',
    ),
    SocietyModel(
      id: 'art',
      name: 'Art Society',
      description: 'Fine Arts and Creative Club',
      category: 'Cultural',
    ),
    
    // Sports Societies
    SocietyModel(
      id: 'basketball',
      name: 'Basketball Club',
      description: 'Basketball Team and Club',
      category: 'Sports',
    ),
    SocietyModel(
      id: 'football',
      name: 'Football Club',
      description: 'Football Team and Club',
      category: 'Sports',
    ),
    SocietyModel(
      id: 'cricket',
      name: 'Cricket Club',
      description: 'Cricket Team and Club',
      category: 'Sports',
    ),
    SocietyModel(
      id: 'badminton',
      name: 'Badminton Club',
      description: 'Badminton Team and Club',
      category: 'Sports',
    ),
    
    // Academic Societies
    SocietyModel(
      id: 'debate',
      name: 'Debate Society',
      description: 'Debate and Public Speaking Club',
      category: 'Academic',
    ),
    SocietyModel(
      id: 'quiz',
      name: 'Quiz Club',
      description: 'Quiz and General Knowledge Club',
      category: 'Academic',
    ),
    SocietyModel(
      id: 'literary',
      name: 'Literary Society',
      description: 'Literature and Writing Club',
      category: 'Academic',
    ),
    SocietyModel(
      id: 'entrepreneurship',
      name: 'E-Cell',
      description: 'Entrepreneurship Cell',
      category: 'Academic',
    ),
    
    // Social Societies
    SocietyModel(
      id: 'nss',
      name: 'NSS',
      description: 'National Service Scheme',
      category: 'Social',
    ),
    SocietyModel(
      id: 'ncc',
      name: 'NCC',
      description: 'National Cadet Corps',
      category: 'Social',
    ),
    SocietyModel(
      id: 'rotaract',
      name: 'Rotaract Club',
      description: 'Rotaract Community Service Club',
      category: 'Social',
    ),
    SocietyModel(
      id: 'environment',
      name: 'Eco Club',
      description: 'Environmental Awareness Club',
      category: 'Social',
    ),
  ];

  static List<String> get categories => [
    'Technical',
    'Cultural',
    'Sports',
    'Academic',
    'Social',
  ];

  static List<SocietyModel> getSocietiesByCategory(String category) {
    return availableSocieties.where((society) => society.category == category).toList();
  }

  static SocietyModel? getSocietyById(String id) {
    try {
      return availableSocieties.firstWhere((society) => society.id == id);
    } catch (e) {
      return null;
    }
  }

  static SocietyModel? getSocietyByName(String name) {
    try {
      return availableSocieties.firstWhere((society) => society.name == name);
    } catch (e) {
      return null;
    }
  }
}