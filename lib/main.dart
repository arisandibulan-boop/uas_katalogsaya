import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/dashboard/presentation/providers/product_provider.dart';
import 'features/order/presentation/providers/order_provider.dart';
import 'features/cart/presentation/providers/cart_provider.dart'; 
import 'features/dashboard/presentation/providers/favorite_provider.dart';
import 'core/providers/theme_provider.dart'; 
import 'core/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inisialisasi Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase Error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        // AKTIFKAN LOGIN DISINI (SUDAH TERPASANG)
        ChangeNotifierProvider(create: (_) => AuthProvider()..initializeAuth()),
        
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Katalog Laptop',
      themeMode: themeProvider.themeMode, 
      theme: ThemeData.light(useMaterial3: true), // Tambahkan useMaterial3 agar UI lebih modern
      darkTheme: ThemeData.dark(useMaterial3: true),
      initialRoute: AppRouter.splash, 
      routes: AppRouter.routes,
    );
  }
}// Progress
// Progress
// Progress
// Progress
// Config Firebase
// pancingan 20
// pancingan 21
//c22
//c23
