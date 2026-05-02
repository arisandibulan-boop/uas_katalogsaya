import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  ProductStatus _status = ProductStatus.initial;
  List<ProductModel> _products = [];
  String? _error;

  ProductStatus get status => _status;
  List<ProductModel> get products => _products;
  String? get error => _error;
  bool get isLoading => _status == ProductStatus.loading;

  Future<void> fetchProducts() async {
    _status = ProductStatus.loading;
    notifyListeners();
    try {
      // Simulasi loading 1 detik
      await Future.delayed(const Duration(seconds: 1));
      
      final dummyData = [
        {
          "id": 1,
          "name": "MacBook Air M3 2024",
          "category": "Apple",
          "price": 17500000,
          "image_url": "https://sm.pcmag.com/t/pcmag_au/review/a/apple-macb/apple-macbook-air-15-inch-2024-m3_752k.3840.jpg",
          "description": "Chip M3 terbaru, Liquid Retina Display, RAM 8GB."
        },
        {
          "id": 2,
          "name": "ASUS ROG Strix G16",
          "category": "Gaming",
          "price": 22499000,
          "image_url": "https://images.unsplash.com/photo-1593642632823-8f785ba67e45?q=80&w=500",
          "description": "Intel Core i9, RTX 4070, Performa gaming tingkat tinggi."
        },
        {
          "id": 3,
          "name": "HP Spectre x360",
          "category": "Ultrabook",
          "price": 21000000,
          "image_url": "https://sm.pcmag.com/t/pcmag_au/review/h/hp-spectre/hp-spectre-x360-15-2020_e7kd.3840.jpg",
          "description": "Layar sentuh OLED, bisa ditekuk 360 derajat, mewah."
        },
        {
          "id": 4,
          "name": "Dell XPS 15 9530",
          "category": "Ultrabook",
          "price": 32000000,
          "image_url": "https://hothardware.com/Image/Resize/?width=1170&height=1170&imageFile=/contentimages/Article/3302/content/big_dell-xps-15-9530-3.jpg",
          "description": "Layar 4K InfinityEdge, cocok untuk desain profesional."
        },
        {
          "id": 5,
          "name": "Lenovo Legion Slim 5",
          "category": "Gaming",
          "price": 18900000,
          "image_url": "https://images.unsplash.com/photo-1603302576837-37561b2e2302?q=80&w=500",
          "description": "Ryzen 7, RTX 4060, bodi tipis namun tetap dingin."
        },
        {
          "id": 6,
          "name": "Acer Swift Go 14",
          "category": "Student",
          "price": 11500000,
          "image_url": "https://trenteknologi.com/wp-content/uploads/2024/10/Review-Acer-Swift-Go-14-AI-Copilot-PC-Copilot-PC-Terjangkau-Pertama-di-Indonesia.jpg",
          "description": "Layar OLED jernih, ringan dibawa ke kampus."
        },
        {
          "id": 7,
          "name": "MSI Katana 15",
          "category": "Gaming",
          "price": 15500000,
          "image_url": "https://images.unsplash.com/photo-1525547719571-a2d4ac8945e2?q=80&w=500",
          "description": "Keyboard RGB, Intel i7 Gen 13, harga terjangkau."
        },
        {
          "id": 10,
          "name": "Razer Blade 14",
          "category": "Gaming",
          "price": 38000000,
          "image_url": "https://cdn.mos.cms.futurecdn.net/3vk3bg8c3JHmyonUV9Xa9G-1920-80.jpg.webp",
          "description": "Kualitas build terbaik, sangat kencang dan kompak."
        },
        {
          "id": 11,
          "name": "Lenovo ThinkPad P1 Gen 6",
          "category": "Workstation",
          "price": 45000000,
          "image_url": "https://www.notebookcheck.net/fileadmin/_processed_/d/c/csm_IMG_0654_4750f0fd36.jpg",
          "description": "Intel Xeon, RTX A2000, RAM 64GB. Laptop workstation paling tangguh untuk profesional."
        },
        {
          "id": 12,
          "name": "HP EliteBook 840 G10",
          "category": "Business",
          "price": 22500000,
          "image_url": "https://laptopmedia.com/wp-content/uploads/2024/03/5-8.jpg",
          "description": "Intel i7 vPro, Keamanan tingkat tinggi, desain elegan untuk eksekutif."
        },
  
      ];

      // Baris ini sangat penting: Mengubah list Map menjadi list ProductModel
      _products = dummyData.map((item) => ProductModel.fromJson(item)).toList();
      
      _status = ProductStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = ProductStatus.error;
    }
    notifyListeners();
  }
}