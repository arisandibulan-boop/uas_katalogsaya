class ApiConstants {
  // IP MacBook kamu (Pastikan HP dan Laptop satu Wi-Fi)
  static const String baseUrl = 'http://192.168.100.148:8081/v1';

  // Auth endpoints
  static const String verifyToken = '$baseUrl/auth/verify-token';
  static const String refreshToken = '$baseUrl/auth/refresh';
  static const String register = '$baseUrl/auth/register'; 

  // Product endpoints
  static const String products = '$baseUrl/products';

  // Cart endpoints
  static const String cart = '$baseUrl/cart';

  // Order endpoints
  static const String orders = '$baseUrl/orders';
  static const String checkout = '$baseUrl/orders/checkout';

  // Health check
  static const String health = '$baseUrl/health';

  // Timeouts (Penting agar tidak loading selamanya jika server mati)
  static const int connectTimeout = 15000; // 15 detik
  static const int receiveTimeout = 15000;
}