import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/products.dart';

class WishlistService {
  static const String _wishlistKey = 'shoppinghub_wishlist';
  static final ValueNotifier<List<Product>> wishlistNotifier = ValueNotifier<List<Product>>([]);

  // Alias notifier untuk backward compatibility
  static ValueNotifier<List<Product>> get favoritesNotifier => wishlistNotifier;

  // Inisialisasi memuat data wishlist dari Local Database (SharedPreferences) saat aplikasi dibuka
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_wishlistKey);
    if (data != null && data.isNotEmpty) {
      try {
        final List decoded = jsonDecode(data);
        final list = decoded.map((item) => Product.fromJson(item)).toList();
        wishlistNotifier.value = list;
      } catch (e) {
        wishlistNotifier.value = [];
      }
    } else {
      wishlistNotifier.value = [];
    }
  }

  // Cek apakah produk ada di wishlist
  static bool isWishlist(int id) {
    return wishlistNotifier.value.any((p) => p.id == id);
  }

  static bool isFavorite(int id) => isWishlist(id);

  // Toggle status wishlist (Tambah jika belum ada, Hapus jika sudah ada)
  // Mengembalikan true jika berhasil ditambahkan, false jika dihapus
  static Future<bool> toggleWishlist(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = List<Product>.from(wishlistNotifier.value);
    final index = currentList.indexWhere((p) => p.id == product.id);

    bool isAdded;
    if (index >= 0) {
      currentList.removeAt(index);
      isAdded = false;
    } else {
      currentList.add(product);
      isAdded = true;
    }

    wishlistNotifier.value = currentList;
    final jsonString = jsonEncode(currentList.map((p) => p.toJson()).toList());
    await prefs.setString(_wishlistKey, jsonString);

    return isAdded;
  }

  static Future<bool> toggleFavorite(Product product) => toggleWishlist(product);

  // Hapus produk dari wishlist
  static Future<void> removeFromWishlist(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = List<Product>.from(wishlistNotifier.value);
    currentList.removeWhere((p) => p.id == id);

    wishlistNotifier.value = currentList;
    final jsonString = jsonEncode(currentList.map((p) => p.toJson()).toList());
    await prefs.setString(_wishlistKey, jsonString);
  }

  static Future<void> removeFavorite(int id) => removeFromWishlist(id);
}

// Alias untuk kompatibilitas kode
typedef FavoriteService = WishlistService;
typedef ProductsService = WishlistService;
