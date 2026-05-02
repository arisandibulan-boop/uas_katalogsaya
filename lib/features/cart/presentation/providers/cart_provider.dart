import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uas_katalogsaya/features/cart/data/models/cart_model.dart';
import 'package:uas_katalogsaya/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:uas_katalogsaya/features/cart/domain/repositories/cart_repository.dart';

enum CartStatus { initial, loading, loaded, error }

class CartProvider extends ChangeNotifier {
  final CartRepository _repository = CartRepositoryImpl();

  CartStatus _status = CartStatus.initial;
  CartModel? _cart;
  String? _error;
  bool _isAdding = false;

  CartStatus get status => _status;
  CartModel? get cart => _cart;
  String? get error => _error;
  bool get isAdding => _isAdding;
  int get itemCount => _cart?.itemCount ?? 0;

  List<dynamic> get cartItems => _cart?.items ?? [];
  double get totalPrice => _cart?.total.toDouble() ?? 0.0;

  // Fungsi Helper untuk memproses pesan error dari Server
  String _parseError(DioException e) {
    if (e.response?.data is Map) {
      return e.response?.data['message']?.toString() ?? 'Terjadi kesalahan server';
    }
    return e.response?.data?.toString() ?? 'Gagal terhubung ke server';
  }

  void _setLoading() {
    _status = CartStatus.loading;
    _error = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = CartStatus.error;
    _error = message;
    notifyListeners();
  }

  Future<void> refreshWithUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await fetchCart();
    } else {
      _cart = const CartModel(items: [], total: 0, itemCount: 0);
      _status = CartStatus.loaded;
      notifyListeners();
    }
  }

  Future<void> fetchCart() async {
    _setLoading();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _setError('Silakan login terlebih dahulu');
        return;
      }

      _cart = await _repository.getCart();
      _status = CartStatus.loaded;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        _cart = const CartModel(items: [], total: 0, itemCount: 0);
        _status = CartStatus.loaded;
      } else {
        _setError(_parseError(e));
      }
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
    }
    notifyListeners();
  }

  Future<bool> addToCart(int productId, int quantity) async {
    _isAdding = true;
    _error = null; // Reset error sebelum mulai
    notifyListeners();
    try {
      await _repository.addToCart(productId, quantity);
      await fetchCart();
      _isAdding = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = _parseError(e);
      _isAdding = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _isAdding = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateItem(int cartItemId, int quantity) async {
    try {
      await _repository.updateCartItem(cartItemId, quantity);
      await fetchCart();
    } on DioException catch (e) {
      _setError(_parseError(e));
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
    }
  }

  Future<void> removeItem(int cartItemId) async {
    try {
      await _repository.removeCartItem(cartItemId);
      await fetchCart();
    } on DioException catch (e) {
      _setError(_parseError(e));
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      await _repository.clearCart();
      _cart = const CartModel(items: [], total: 0, itemCount: 0);
      _status = CartStatus.loaded;
      notifyListeners();
    } on DioException catch (e) {
      _setError(_parseError(e));
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
    }
  }

  Future<void> removeFromCart(int id) async {
    await removeItem(id);
  }
}// Update Cart
