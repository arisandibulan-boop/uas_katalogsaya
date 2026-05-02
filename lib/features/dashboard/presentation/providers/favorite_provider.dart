import 'package:flutter/material.dart';
import 'package:uas_katalogsaya/features/dashboard/data/models/product_model.dart';

class FavoriteProvider extends ChangeNotifier {
  // 1. Menggunakan List final untuk keamanan referensi data
  final List<ProductModel> _favoriteItems = [];

  // 2. Mengembalikan UnmodifiableListView jika ingin lebih ketat (opsional)
  // Agar data tidak bisa dimanipulasi dari luar tanpa melalui fungsi toggle
  List<ProductModel> get favoriteItems => List.unmodifiable(_favoriteItems);

  // Fungsi untuk tambah/hapus favorit (Toggle)
  void toggleFavorite(ProductModel product) {
    // Pastikan ID tidak null sebelum melakukan pengecekan
    final index = _favoriteItems.indexWhere((item) => item.id == product.id);
    
    if (index != -1) {
      // Jika ada (index bukan -1), hapus berdasarkan index (lebih cepat dari removeWhere)
      _favoriteItems.removeAt(index);
    } else {
      // Jika tidak ada, tambahkan ke list
      _favoriteItems.add(product);
    }
    
    // Sangat penting: Memberitahu UI untuk menggambar ulang ikon hati
    notifyListeners(); 
  }

  // Fungsi cek apakah produk sudah favorit atau belum
  bool isFavorite(ProductModel product) {
    return _favoriteItems.any((item) => item.id == product.id);
  }

  // Bonus: Fungsi untuk membersihkan semua favorit (misal saat logout)
  void clearFavorites() {
    _favoriteItems.clear();
    notifyListeners();
  }
}