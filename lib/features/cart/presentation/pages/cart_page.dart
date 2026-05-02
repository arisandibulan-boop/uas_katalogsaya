import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas_katalogsaya/features/cart/presentation/providers/cart_provider.dart';
import 'package:uas_katalogsaya/core/routes/app_router.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // PENTING: Ambil data saat halaman pertama kali dibuka
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCart();
    });
  }

  String _formatPrice(double price) {
    final str = price.toInt().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp. ${buffer.toString().split('').reversed.join()}';
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan watch agar UI otomatis update
    final cartProv = context.watch<CartProvider>();
    final cart = cartProv.cart;
    final items = cart?.items ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Keranjang Belanja"),
      ),
      body: Builder(
        builder: (context) {
          // 1. Kondisi Loading
          if (cartProv.status == CartStatus.loading && items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Kondisi Keranjang Kosong
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text("Keranjangmu kosong", style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => cartProv.fetchCart(),
                    child: const Text("Refresh Keranjang"),
                  )
                ],
              ),
            );
          }

          // 3. Kondisi Jika Ada Item
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.product.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => 
                                const Icon(Icons.laptop, size: 40), 
                          ),
                        ),
                        title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${item.quantity} x ${_formatPrice(item.product.price.toDouble())}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => cartProv.removeFromCart(item.id),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bagian Total
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Total Pembayaran"),
                          Text(
                            _formatPrice(cart?.total.toDouble() ?? 0.0),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, AppRouter.checkout),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
                        child: const Text("Checkout"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}