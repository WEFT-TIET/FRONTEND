// lib/features/profile/services/profile_service.dart
import 'package:frontend_weft/features/profile/models/user_model.dart';
import 'package:frontend_weft/features/profile/models/weft_model.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  // Cache for better performance
  UserModel? _cachedUser;
  List<WeftModel>? _cachedWefts;
  bool _isLoading = false;

  // Mock data - in real app, this would come from API/database
  UserModel get _currentUserData => UserModel(
    name: 'Rudra Yadav',
    username: 'rudra_yadav',
    batch: '2025',
    branch: 'COE',
    className: '1A62',
    profileImagePath: 'lib/core/assets/profile_photo.jpeg',
  );

  List<WeftModel> get _userWeftsData => [
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

  // Optimized getters with caching
  UserModel get currentUser {
    _cachedUser ??= _currentUserData;
    return _cachedUser!;
  }

  List<WeftModel> get userWefts {
    _cachedWefts ??= _userWeftsData;
    return List.unmodifiable(_cachedWefts!);
  }

  // User operations with optimized state management
  Future<void> updateUser(UserModel updatedUser) async {
    if (_isLoading) return; // Prevent concurrent operations
    
    _isLoading = true;
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      _cachedUser = updatedUser;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> updateProfileImage(String imagePath) async {
    if (_isLoading) return;
    
    _isLoading = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _cachedUser = _cachedUser!.copyWith(profileImagePath: imagePath);
    } finally {
      _isLoading = false;
    }
  }

  // Username validation - optimized
  Future<bool> isUsernameAvailable(String username) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock validation - in real app, this would check against database
    return username.isNotEmpty && username.length >= 3;
  }

  // Weft operations - optimized with direct list manipulation
  Future<void> likeWeft(String weftId) async {
    if (_isLoading) return;
    
    _isLoading = true;
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final index = _cachedWefts!.indexWhere((weft) => weft.id == weftId);
      if (index != -1) {
        _cachedWefts![index] = _cachedWefts![index].copyWith(likes: _cachedWefts![index].likes + 1);
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> addComment(String weftId) async {
    if (_isLoading) return;
    
    _isLoading = true;
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final index = _cachedWefts!.indexWhere((weft) => weft.id == weftId);
      if (index != -1) {
        _cachedWefts![index] = _cachedWefts![index].copyWith(comments: _cachedWefts![index].comments + 1);
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<String> shareProfile() async {
    if (_isLoading) return 'Already processing...';
    
    _isLoading = true;
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return 'Profile shared successfully!';
    } finally {
      _isLoading = false;
    }
  }

  // Clear cache when needed
  void clearCache() {
    _cachedUser = null;
    _cachedWefts = null;
  }

  // Check if service is currently loading
  bool get isLoading => _isLoading;
}