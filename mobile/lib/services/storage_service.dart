import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _userDataKey = 'user_data';
  
  // Get SharedPreferences instance
  static Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }
  
  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, token);
  }
  
  // Get token
  static Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }
  
  // Save user data (full user object)
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await _prefs;
    await prefs.setString(_userDataKey, jsonEncode(userData));
    // Also save individual fields for backward compatibility
    if (userData['id'] != null) {
      await prefs.setString(_userIdKey, userData['id'].toString());
    }
    if (userData['role'] != null) {
      await prefs.setString(_userRoleKey, userData['role'].toString());
    }
  }
  
  // Get full user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await _prefs;
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      try {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(_userIdKey);
  }
  
  // Get user role
  static Future<String?> getUserRole() async {
    final prefs = await _prefs;
    return prefs.getString(_userRoleKey);
  }
  
  // Clear all data (logout)
  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userDataKey);
  }
  
  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

