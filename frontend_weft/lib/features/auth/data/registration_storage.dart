import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RegistrationStorage {
  static const String _registrationDataKey = 'pending_registration_data';

  /// Save registration data temporarily for OTP resend
  static Future<void> saveRegistrationData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_registrationDataKey, jsonEncode(userData));
  }

  /// Get saved registration data
  static Future<Map<String, dynamic>?> getRegistrationData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_registrationDataKey);
    if (dataString != null) {
      return jsonDecode(dataString) as Map<String, dynamic>;
    }
    return null;
  }

  /// Clear registration data after successful registration
  static Future<void> clearRegistrationData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_registrationDataKey);
  }
}