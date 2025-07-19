class ApiConfig {
  static const String baseUrl = 'http://ec2-3-7-223-144.ap-south-1.compute.amazonaws.com:8080';
  
  // API Endpoints
  static const String searchUsers = '/search-users';
  static const String registerUser = '/api/register-user';
  static const String getUserProfile = '/api/user-profile';
  
  // Full URLs
  static String get searchUsersUrl => '$baseUrl$searchUsers';
  static String get registerUserUrl => '$baseUrl$registerUser';
  static String get getUserProfileUrl => '$baseUrl$getUserProfile';
  
  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeout settings
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
} 