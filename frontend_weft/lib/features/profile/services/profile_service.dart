// lib/services/profile_service.dart
import 'package:frontend_weft/features/profile/models/user_model.dart';
import 'package:frontend_weft/features/profile/models/weft_model.dart';
import 'package:frontend_weft/features/profile/models/society_model.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  // Mock data - in real app, this would come from API/database
  UserModel _currentUser = UserModel(
    name: 'Rudra Yadav',
    batch: '2025',
    branch: 'COE',
    className: '1A62',
    societies: ['MLSC', 'CCS'],
    profileImagePath: 'lib/core/assets/profile_photo.jpeg',
  );

  List<WeftModel> _userWefts = [
    WeftModel(
      id: '1',
      date: '20/07/15',
      time: '3:16 AM',
      content: 'What is Weft?',
      likes: 12,
      comments: 5,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    WeftModel(
      id: '2',
      date: '19/07/15',
      time: '11:32 PM',
      content: 'Just finished my Flutter project! 🚀',
      likes: 8,
      comments: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    WeftModel(
      id: '3',
      date: '18/07/15',
      time: '2:45 PM',
      content: 'Great workshop on AI today!',
      likes: 15,
      comments: 7,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    WeftModel(
      id: '4',
      date: '17/07/15',
      time: '10:30 AM',
      content: 'Looking forward to the hackathon',
      likes: 6,
      comments: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  // Getters
  UserModel get currentUser => _currentUser;
  List<WeftModel> get userWefts => List.unmodifiable(_userWefts);

  // User operations
  Future<void> updateUser(UserModel updatedUser) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = updatedUser;
  }

  Future<void> addSociety(String societyName) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Check if society already exists
    if (!_currentUser.societies.contains(societyName)) {
      final updatedSocieties = List<String>.from(_currentUser.societies)..add(societyName);
      _currentUser = _currentUser.copyWith(societies: updatedSocieties);
    }
  }

  Future<void> removeSociety(String society) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final updatedSocieties = List<String>.from(_currentUser.societies)..remove(society);
    _currentUser = _currentUser.copyWith(societies: updatedSocieties);
  }

  // Get available societies for dropdown
  List<SocietyModel> getAvailableSocieties() {
    return SocietyData.availableSocieties;
  }

  // Get societies not already selected by user
  List<SocietyModel> getUnselectedSocieties() {
    return SocietyData.availableSocieties
        .where((society) => !_currentUser.societies.contains(society.name))
        .toList();
  }

  // Get societies by category
  List<SocietyModel> getSocietiesByCategory(String category) {
    return SocietyData.getSocietiesByCategory(category)
        .where((society) => !_currentUser.societies.contains(society.name))
        .toList();
  }

  Future<void> updateProfileImage(String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = _currentUser.copyWith(profileImagePath: imagePath);
  }

  // Weft operations
  Future<void> likeWeft(String weftId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _userWefts.indexWhere((weft) => weft.id == weftId);
    if (index != -1) {
      _userWefts[index] = _userWefts[index].copyWith(likes: _userWefts[index].likes + 1);
    }
  }

  Future<void> addComment(String weftId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _userWefts.indexWhere((weft) => weft.id == weftId);
    if (index != -1) {
      _userWefts[index] = _userWefts[index].copyWith(comments: _userWefts[index].comments + 1);
    }
  }

  Future<String> shareProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'Profile shared successfully!';
  }
}