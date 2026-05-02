import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uas_katalogsaya/core/constants/api_constants.dart';
import 'package:uas_katalogsaya/features/cart/data/models/cart_model.dart';
import 'package:uas_katalogsaya/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final Dio _dio = Dio();

  CartRepositoryImpl() {
    // Menambahkan Interceptor agar setiap request membawa Token Firebase
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  @override
  Future<CartModel> getCart() async {
    try {
      final response = await _dio.get(ApiConstants.cart);
      if (response.statusCode == 200) {
        return CartModel.fromJson(response.data['data']);
      }
      throw Exception('Gagal mengambil data keranjang');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addToCart(int productId, int quantity) async {
    try {
      await _dio.post(
        ApiConstants.cart,
        data: {
          'product_id': productId,
          'quantity': quantity,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateCartItem(int cartItemId, int quantity) async {
    try {
      await _dio.put(
        '${ApiConstants.cart}/$cartItemId',
        data: {'quantity': quantity},
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeCartItem(int cartItemId) async {
    try {
      await _dio.delete('${ApiConstants.cart}/$cartItemId');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _dio.delete(ApiConstants.cart);
    } catch (e) {
      rethrow;
    }
  }
}// Get Cart
// Add Cart
