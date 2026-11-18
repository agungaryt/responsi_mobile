import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/products.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com';

  // Data cadangan (fallback) jika perangkat sedang offline / internet bermasalah
  static final List<Product> _fallbackProducts = [
    Product(
      id: 1,
      title: 'Essence Mascara Lash Princess',
      description: 'The Essence Mascara Lash Princess is a popular mascara known for its volumizing and lengthening effects. It features a specially designed brush that addresses each lash individually to provide dramatic results.',
      category: 'beauty',
      price: 9.99,
      discountPercentage: 7.17,
      rating: 4.94,
      stock: 99,
      brand: 'Essence',
      thumbnail: 'https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/thumbnail.png',
    ),
    Product(
      id: 2,
      title: 'Eyeshadow Palette with Mirror',
      description: 'The Eyeshadow Palette with Mirror offers a versatile range of eyeshadow shades for various makeup looks. Includes a convenient built-in mirror.',
      category: 'beauty',
      price: 19.99,
      discountPercentage: 5.50,
      rating: 3.28,
      stock: 44,
      brand: 'Glamour Beauty',
      thumbnail: 'https://cdn.dummyjson.com/products/images/beauty/Eyeshadow%20Palette%20with%20Mirror/thumbnail.png',
    ),
    Product(
      id: 3,
      title: 'Powder Canister',
      description: 'The Powder Canister is a finely milled setting powder designed to set makeup and control shine for a smooth finish.',
      category: 'beauty',
      price: 14.99,
      discountPercentage: 18.14,
      rating: 3.82,
      stock: 59,
      brand: 'Velvet Touch',
      thumbnail: 'https://cdn.dummyjson.com/products/images/beauty/Powder%20Canister/thumbnail.png',
    ),
    Product(
      id: 4,
      title: 'Red Lipstick',
      description: 'The Red Lipstick is a classic and bold choice for adding a pop of color to your lips with long-lasting hydration.',
      category: 'beauty',
      price: 12.99,
      discountPercentage: 19.03,
      rating: 2.51,
      stock: 68,
      brand: 'Chic Cosmetics',
      thumbnail: 'https://cdn.dummyjson.com/products/images/beauty/Red%20Lipstick/thumbnail.png',
    ),
    Product(
      id: 5,
      title: 'Red Nail Polish',
      description: 'The Red Nail Polish offers a rich and glossy red color for vibrant and polished nails with chip-resistant formula.',
      category: 'beauty',
      price: 8.99,
      discountPercentage: 2.46,
      rating: 3.91,
      stock: 71,
      brand: 'Nail Couture',
      thumbnail: 'https://cdn.dummyjson.com/products/images/beauty/Red%20Nail%20Polish/thumbnail.png',
    ),
    Product(
      id: 6,
      title: 'Calvin Klein CK One',
      description: 'CK One by Calvin Klein is a classic unisex fragrance, known for its fresh and clean scent with green tea and bergamot.',
      category: 'fragrances',
      price: 49.99,
      discountPercentage: 0.32,
      rating: 4.85,
      stock: 17,
      brand: 'Calvin Klein',
      thumbnail: 'https://cdn.dummyjson.com/products/images/fragrances/Calvin%20Klein%20CK%20One/thumbnail.png',
    ),
    Product(
      id: 7,
      title: 'Chanel Coco Noir Eau De',
      description: 'Coco Noir by Chanel is an elegant and mysterious fragrance with notes of grapefruit, rose, and patchouli.',
      category: 'fragrances',
      price: 129.99,
      discountPercentage: 18.64,
      rating: 2.76,
      stock: 41,
      brand: 'Chanel',
      thumbnail: 'https://cdn.dummyjson.com/products/images/fragrances/Chanel%20Coco%20Noir%20Eau%20De/thumbnail.png',
    ),
    Product(
      id: 8,
      title: "Dior J'adore",
      description: "J'adore by Dior is a luxurious and floral fragrance, featuring notes of ylang-ylang, Damascus rose, and jasmine.",
      category: 'fragrances',
      price: 89.99,
      discountPercentage: 17.44,
      rating: 3.31,
      stock: 91,
      brand: 'Dior',
      thumbnail: "https://cdn.dummyjson.com/products/images/fragrances/Dior%20J'adore/thumbnail.png",
    ),
    Product(
      id: 9,
      title: 'Dolce Shine Eau de',
      description: 'Dolce Shine by Dolce & Gabbana is a sunny and fruity floral scent with notes of mango, jasmine, and blond woods.',
      category: 'fragrances',
      price: 69.99,
      discountPercentage: 11.47,
      rating: 2.68,
      stock: 3,
      brand: 'Dolce & Gabbana',
      thumbnail: 'https://cdn.dummyjson.com/products/images/fragrances/Dolce%20Shine%20Eau%20de/thumbnail.png',
    ),
    Product(
      id: 10,
      title: 'Gucci Bloom Eau de',
      description: 'Gucci Bloom by Gucci is a sophisticated floral scent capturing notes of rangoon creeper, jasmine bud, and tuberose.',
      category: 'fragrances',
      price: 79.99,
      discountPercentage: 8.90,
      rating: 4.14,
      stock: 93,
      brand: 'Gucci',
      thumbnail: 'https://cdn.dummyjson.com/products/images/fragrances/Gucci%20Bloom%20Eau%20de/thumbnail.png',
    ),
    Product(
      id: 11,
      title: 'Annibale Colombo Bed',
      description: 'The Annibale Colombo Bed is a luxurious and elegant bed frame crafted with high-quality solid wood materials.',
      category: 'furniture',
      price: 1899.99,
      discountPercentage: 0.29,
      rating: 4.14,
      stock: 47,
      brand: 'Annibale Colombo',
      thumbnail: 'https://cdn.dummyjson.com/products/images/furniture/Annibale%20Colombo%20Bed/thumbnail.png',
    ),
    Product(
      id: 12,
      title: 'Annibale Colombo Sofa',
      description: 'The Annibale Colombo Sofa is a sophisticated and comfortable seating option with exquisite craftsmanship.',
      category: 'furniture',
      price: 2499.99,
      discountPercentage: 18.54,
      rating: 4.31,
      stock: 16,
      brand: 'Annibale Colombo',
      thumbnail: 'https://cdn.dummyjson.com/products/images/furniture/Annibale%20Colombo%20Sofa/thumbnail.png',
    ),
    Product(
      id: 13,
      title: 'Honey Jar',
      description: 'Pure and natural honey jar harvested from premium wildflowers, offering rich sweetness and nutrients.',
      category: 'groceries',
      price: 6.99,
      discountPercentage: 1.91,
      rating: 3.50,
      stock: 25,
      brand: 'Nature Sweet',
      thumbnail: 'https://cdn.dummyjson.com/products/images/groceries/Honey%20Jar/thumbnail.png',
    ),
    Product(
      id: 14,
      title: 'Cooking Oil',
      description: 'Versatile and healthy cooking oil suitable for frying, baking, and dressing everyday culinary meals.',
      category: 'groceries',
      price: 4.99,
      discountPercentage: 18.89,
      rating: 4.01,
      stock: 22,
      brand: 'Golden Harvest',
      thumbnail: 'https://cdn.dummyjson.com/products/images/groceries/Cooking%20Oil/thumbnail.png',
    ),
    Product(
      id: 15,
      title: 'Ice Cream',
      description: 'Creamy and delicious vanilla ice cream made with fresh dairy cream, perfect for family desserts.',
      category: 'groceries',
      price: 5.49,
      discountPercentage: 10.00,
      rating: 4.77,
      stock: 76,
      brand: 'Sweet Delights',
      thumbnail: 'https://cdn.dummyjson.com/products/images/groceries/Ice%20Cream/thumbnail.png',
    ),
    Product(
      id: 16,
      title: 'Eggs',
      description: 'Farm-fresh Grade A eggs packed with high-quality protein and essential vitamins for breakfast.',
      category: 'groceries',
      price: 2.99,
      discountPercentage: 5.80,
      rating: 4.46,
      stock: 100,
      brand: 'Farm Fresh',
      thumbnail: 'https://cdn.dummyjson.com/products/images/groceries/Eggs/thumbnail.png',
    ),
    Product(
      id: 17,
      title: 'Green Bell Pepper',
      description: 'Crisp and crunchy green bell peppers bursting with freshness, ideal for salads and stir-fries.',
      category: 'groceries',
      price: 1.29,
      discountPercentage: 2.31,
      rating: 4.28,
      stock: 89,
      brand: 'Fresh Garden',
      thumbnail: 'https://cdn.dummyjson.com/products/images/groceries/Green%20Bell%20Pepper/thumbnail.png',
    ),
  ];

  // Mengambil daftar produk dari API (dengan fallback otomatis jika offline)
  static Future<List<Product>> getProducts({
    String? category,
    String? search,
  }) async {
    Uri uri;

    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
      uri = Uri.parse('$baseUrl/products/category/$category');
    } else if (search != null && search.trim().isNotEmpty) {
      uri = Uri.parse('$baseUrl/products/search?q=${Uri.encodeComponent(search.trim())}');
    } else {
      uri = Uri.parse('$baseUrl/products?limit=100');
    }

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['products'] ?? [];
        return list.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } catch (_) {
      // Fallback data lokal jika internet/koneksi bermasalah
      List<Product> result = List.from(_fallbackProducts);

      if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
        result = result.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
      }

      if (search != null && search.trim().isNotEmpty) {
        final q = search.trim().toLowerCase();
        result = result.where((p) => p.title.toLowerCase().contains(q) || p.category.toLowerCase().contains(q)).toList();
      }

      return result;
    }
  }

  // Mengambil detail produk dari API (dengan fallback jika offline)
  static Future<Product> getProductDetail(int id) async {
    final uri = Uri.parse('$baseUrl/products/$id');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } catch (_) {
      // Cari di data lokal cadangan
      return _fallbackProducts.firstWhere(
        (p) => p.id == id,
        orElse: () => _fallbackProducts.first,
      );
    }
  }

  // Mengambil daftar kategori dari API (dengan fallback jika offline)
  static Future<List<String>> getCategories() async {
    final uri = Uri.parse('$baseUrl/products/category-list');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          return data.map((item) => item.toString()).toList();
        }
      }
      return ['beauty', 'fragrances', 'furniture', 'groceries'];
    } catch (_) {
      return ['beauty', 'fragrances', 'furniture', 'groceries'];
    }
  }

  // Backward compatibility
  static Future<Product> getCharacterDetail(int id) => getProductDetail(id);
}
