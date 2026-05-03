import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:uas_katalogsaya/core/constants/api_constants.dart';
import 'package:uas_katalogsaya/core/services/dio_client.dart';
import 'package:uas_katalogsaya/features/cart/data/models/cart_model.dart';
import 'package:uas_katalogsaya/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  
  // Fungsi pembantu untuk mengambil Token Firebase
  Future<Options> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  @override
  Future<CartModel> getCart() async {
    final options = await _getHeaders();
    final response = await DioClient.instance.get(
      ApiConstants.cart,
      options: options,
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return CartModel.fromJson(data);
  }

  @override
  Future<void> addToCart(int productId, int quantity) async {
    final options = await _getHeaders();
    await DioClient.instance.post(
      ApiConstants.cart,
      data: {'product_id': productId, 'quantity': quantity},
      options: options,
    );
  }

  // FIXED: Menambahkan kembali fungsi yang hilang agar tidak error merah
  @override
  Future<void> updateCartItem(int cartItemId, int quantity) async {
    final options = await _getHeaders();
    await DioClient.instance.put(
      '${ApiConstants.cart}/$cartItemId',
      data: {'quantity': quantity},
      options: options,
    );
  }

  @override
  Future<void> removeCartItem(int cartItemId) async {
    final options = await _getHeaders();
    await DioClient.instance.delete(
      '${ApiConstants.cart}/$cartItemId',
      options: options,
    );
  }

  @override
  Future<void> clearCart() async {
    final options = await _getHeaders();
    await DioClient.instance.delete(
      ApiConstants.cart,
      options: options,
    );
  }
}