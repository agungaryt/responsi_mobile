import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';
import 'services/auth_service.dart';
import 'services/wishlist.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive Local Database untuk Manajemen Akun User
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserAdapter());
  }
  final userBox = await Hive.openBox<User>('users');

  // Buat akun bawaan / default jika database baru pertama kali dijalankan
  if (userBox.isEmpty) {
    await userBox.add(
      User(
        username: 'admin',
        password: 'admin123',
        nama: 'Administrator',
      ),
    );
    await userBox.add(
      User(
        username: 'user',
        password: 'user123',
        nama: 'Shopper Hub',
      ),
    );
  }

  // Inisialisasi data Wishlist dari Local Database
  await WishlistService.init();

  // Cek sesi login dari SharedPreferences
  final bool loggedIn = await AuthService.isLoggedIn();

  runApp(ShoppingHubApp(isLoggedIn: loggedIn));
}

class ShoppingHubApp extends StatelessWidget {
  final bool isLoggedIn;

  const ShoppingHubApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShoppingHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF1E3A8A),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
        ),
      ),
      home: isLoggedIn ? const MainNavigation() : const LoginScreen(),
    );
  }
}
