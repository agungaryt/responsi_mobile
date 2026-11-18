import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/products.dart';
import '../services/wishlist.dart';

class DetailScreen extends StatefulWidget {
  final int productId;
  final Product? initialProduct;

  const DetailScreen({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Product? _product;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _product = widget.initialProduct;
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final product = await ApiService.getProductDetail(widget.productId);
      if (mounted) {
        setState(() {
          _product = product;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        if (_product == null) {
          setState(() {
            _errorMessage = e.toString().replaceAll('Exception: ', '');
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _handleToggleWishlist() async {
    if (_product == null) return;

    final isAdded = await WishlistService.toggleWishlist(_product!);
    setState(() {});

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isAdded ? Icons.check_circle_outline_rounded : Icons.remove_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isAdded
                    ? '${_product!.title} ditambahkan ke wishlist!'
                    : '${_product!.title} dihapus dari wishlist!',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        // Ketentuan Soal 3: SnackBar Hijau saat ditambah, Merah saat dihapus
        backgroundColor: isAdded ? Colors.green.shade600 : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFav = _product != null && WishlistService.isWishlist(_product!.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _product?.title ?? 'Detail Produk',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: const Color(0xFF1E3A8A), // Deep Royal Navy
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_product != null)
            IconButton(
              icon: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                // Ketentuan Soal 3: Icon berubah warna ketika ditambahkan / dihapus
                color: isFav ? Colors.redAccent : Colors.white,
                size: 24,
              ),
              tooltip: isFav ? 'Hapus dari Wishlist' : 'Tambah ke Wishlist',
              onPressed: _handleToggleWishlist,
            ),
        ],
      ),
      body: _buildBody(isFav),
      bottomNavigationBar: _product != null ? _buildBottomBar(isFav) : null,
    );
  }

  Widget _buildBody(bool isFav) {
    if (_isLoading && _product == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF1E3A8A)),
            SizedBox(height: 14),
            Text('Memuat detail produk...', style: TextStyle(color: Colors.black54, fontSize: 13)),
          ],
        ),
      );
    }

    if (_errorMessage != null && _product == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 50, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                'Gagal memuat detail produk:\n$_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchDetail,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final p = _product!;
    final originalPrice = p.discountPercentage > 0 ? (p.price / (1 - (p.discountPercentage / 100))) : p.price;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Gambar Produk Showcase (Thumbnail)
          Container(
            width: double.infinity,
            height: 250,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.network(
                      p.thumbnail,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.image_not_supported_outlined, size: 54, color: Colors.grey),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A), strokeWidth: 2));
                      },
                    ),
                  ),
                ),

                // Kategori Tag di Pojok Gambar
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Text(
                      p.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),

                // Diskon Badge di Pojok Gambar
                if (p.discountPercentage > 0)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'HEMAT ${p.discountPercentage.toInt()}%',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 2. Info Utama Produk (Title & Harga)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Produk (Ketentuan Soal: nama produk)
                Text(
                  p.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Harga & Coretan Diskon (Ketentuan Soal: harga & persentase diskon)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '\$${p.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (p.discountPercentage > 0) ...[
                      Text(
                        '\$${originalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${p.discountPercentage}% OFF)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. Grid Parameter Produk (Rating, Brand, Stok, Kategori)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Rating (Ketentuan Soal: rating)
                _buildInfoItem(
                  icon: Icons.star_rounded,
                  iconColor: Colors.amber,
                  label: 'Rating',
                  value: '${p.rating} / 5',
                ),
                _buildDivider(),

                // Brand jika tersedia (Ketentuan Soal: brand jika tersedia)
                _buildInfoItem(
                  icon: Icons.storefront_rounded,
                  iconColor: Colors.blueAccent,
                  label: 'Brand',
                  value: (p.brand != null && p.brand!.trim().isNotEmpty) ? p.brand! : '-',
                ),
                _buildDivider(),

                // Informasi Stok (Ketentuan Soal: informasi stok)
                _buildInfoItem(
                  icon: Icons.inventory_2_rounded,
                  iconColor: Colors.teal,
                  label: 'Stok',
                  value: '${p.stock} pcs',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4. Deskripsi Produk (Ketentuan Soal: deskripsi)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notes_rounded, size: 20, color: Color(0xFF1E3A8A)),
                    SizedBox(width: 8),
                    Text(
                      'Deskripsi Produk',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  p.description.isNotEmpty ? p.description : 'Tidak ada informasi deskripsi untuk produk ini.',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 14),

                // Jaminan Belanja
                Row(
                  children: [
                    _buildBadgeCheck('100% Original'),
                    const SizedBox(width: 12),
                    _buildBadgeCheck('Pengiriman Cepat'),
                    const SizedBox(width: 12),
                    _buildBadgeCheck('Stok Siap Kirim'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCheck(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 38,
      color: const Color(0xFFE2E8F0),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildBottomBar(bool isFav) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Total Harga
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Harga',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
                Text(
                  '\$${_product!.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 18),

            // Tombol Wishlist (Ketentuan Soal 3: Wishlist add/remove, icon berubah warna, snackbar hijau/merah)
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFav ? Colors.red.shade50 : const Color(0xFF1E3A8A),
                    foregroundColor: isFav ? Colors.red.shade700 : Colors.white,
                    side: isFav ? BorderSide(color: Colors.red.shade400, width: 1.5) : BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: isFav ? 0 : 2,
                  ),
                  icon: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? Colors.redAccent : Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    isFav ? 'Hapus dari Wishlist' : 'Tambah ke Wishlist',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onPressed: _handleToggleWishlist,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
