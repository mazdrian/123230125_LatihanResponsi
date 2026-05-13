import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class AuthService {
  static const String _keyLoggedIn = 'is_logged_in';
  static const String _keyLoggedUsername = 'logged_username';

  static Future<bool> register(String username, String password) async {
    final result = await DatabaseHelper.instance.registerUser(username, password);
    return result != -1;
  }

  static Future<bool> login(String username, String password) async {
    final user = await DatabaseHelper.instance.loginUser(username, password);
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyLoggedIn, true);
      await prefs.setString(_keyLoggedUsername, username);
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
    await prefs.remove(_keyLoggedUsername);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  static Future<String?> getLoggedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLoggedUsername);
  }
}
