import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _loginKey = 'isLoggedIn';
  static const String _userKey = 'currentUsername';
  static const String _nameKey = 'currentName';

  static Box<User> get _userBox => Hive.box<User>('users');

  // Cek apakah ada session login aktif
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  // Ambil nama user yang sedang login
  static Future<String> getCurrentName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? 'Explorer';
  }

  // Register user baru ke Hive
  static Future<bool> register({
    required String username,
    required String password,
    required String nama,
  }) async {
    final trimmedUser = username.trim();
    // Cek apakah username sudah ada
    final existingUser = _userBox.values.any(
      (u) => u.username.toLowerCase() == trimmedUser.toLowerCase(),
    );

    if (existingUser) {
      return false; // Username sudah terdaftar
    }

    final newUser = User(
      username: trimmedUser,
      password: password,
      nama: nama.trim(),
    );

    await _userBox.add(newUser);
    return true;
  }

  // Login user dengan memvalidasi dari Hive
  static Future<bool> login({
    required String username,
    required String password,
  }) async {
    final trimmedUser = username.trim();

    // Cari kecocokan di database Hive
    User? matchedUser;
    for (var u in _userBox.values) {
      if (u.username.toLowerCase() == trimmedUser.toLowerCase() && u.password == password) {
        matchedUser = u;
        break;
      }
    }

    if (matchedUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_loginKey, true);
      await prefs.setString(_userKey, matchedUser.username);
      await prefs.setString(_nameKey, matchedUser.nama);
      return true;
    }

    return false;
  }

  // Logout dan bersihkan session SharedPreferences
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, false);
    await prefs.remove(_userKey);
    await prefs.remove(_nameKey);
  }
}

