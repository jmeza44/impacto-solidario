import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  // Get the instance of SharedPreferences
  Future<SharedPreferences> _getPreferences() async {
    return await SharedPreferences.getInstance();
  }

  // Set user session (userId and role)
  Future<void> setUserSession(String userId, String role) async {
    final SharedPreferences prefs = await _getPreferences();
    await prefs.setString('userId', userId);
    await prefs.setString('role', role);
  }

  // Get user session (userId and role)
  Future<Map<String, String>> getUserSession() async {
    final SharedPreferences prefs = await _getPreferences();
    String? userId = prefs.getString('userId');
    String? role = prefs.getString('role');

    // If either value is null, return empty map
    if (userId == null || role == null) {
      return {};
    }

    return {
      'userId': userId,
      'role': role,
    };
  }

  // Clear user session
  Future<void> clearUserSession() async {
    final SharedPreferences prefs = await _getPreferences();
    await prefs.remove('userId');
    await prefs.remove('role');
  }
}
