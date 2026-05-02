import 'package:flutter/material.dart';
import 'package:uas_katalogsaya/core/providers/theme_provider.dart';
import 'package:uas_katalogsaya/core/routes/app_router.dart';
import 'package:uas_katalogsaya/features/auth/presentation/providers/auth_provider.dart';
import 'package:uas_katalogsaya/features/cart/presentation/providers/cart_provider.dart';
import 'package:uas_katalogsaya/features/dashboard/data/models/product_model.dart';
import 'package:uas_katalogsaya/features/dashboard/presentation/providers/product_provider.dart';
import 'package:uas_katalogsaya/features/dashboard/presentation/providers/favorite_provider.dart';
import 'package:provider/provider.dart';

// ── Model internal ──────────────────────────────────────────
class _CategoryItem {
  final String label;
  final IconData icon;
  const _CategoryItem({required this.label, required this.icon});
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedNav = 0;
  String _selectedCategory = 'All';
  final _searchCtrl = TextEditingController();

  final List<_CategoryItem> _categories = const [
    _CategoryItem(label: 'All', icon: Icons.grid_view_rounded),
    _CategoryItem(label: 'Apple', icon: Icons.laptop_mac_rounded),
    _CategoryItem(label: 'Gaming', icon: Icons.sports_esports_rounded),
    _CategoryItem(label: 'Ultrabook', icon: Icons.auto_awesome_rounded),
    _CategoryItem(label: 'Student', icon: Icons.school_rounded),
    _CategoryItem(label: 'Workstation', icon: Icons.terminal_rounded),
    _CategoryItem(label: 'Business', icon: Icons.business_center_rounded),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
      context.read<CartProvider>().fetchCart();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ProductModel> _filteredProducts(List<ProductModel> products) {
    final query = _searchCtrl.text.toLowerCase();
    return products.where((p) {
      final matchCategory = _selectedCategory == 'All' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchSearch = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);
      return matchCategory && matchSearch;
    }).toList();
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

  Widget _buildHomeBody(ProductProvider productProv) {
    return RefreshIndicator(
      onRefresh: () => productProv.fetchProducts(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: _SearchBar(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _BannerCard(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text('See All')),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (ctx, idx) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  return _CategoryChip(
                    item: cat,
                    selected: _selectedCategory == cat.label,
                    onTap: () => setState(() => _selectedCategory = cat.label),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text('For you', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          switch (productProv.status) {
            ProductStatus.loading || ProductStatus.initial => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            ProductStatus.error => SliverFillRemaining(
                child: Center(child: Text(productProv.error ?? 'Terjadi kesalahan')),
              ),
            ProductStatus.loaded => () {
                final items = _filteredProducts(productProv.products);
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _ProductCard(product: items[i], formatPrice: _formatPrice),
                      childCount: items.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.62,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                  ),
                );
              }(),
          },
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final productProv = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedNav,
          children: [
            _buildHomeBody(productProv),
            const Center(child: Text("Halaman Cart")),
            const FavoritePage(),
            const Center(child: Text("Halaman Akun")),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedNav,
        onTap: (i) {
          if (i == 1) {
            Navigator.pushNamed(context, AppRouter.cart);
          } else if (i == 3) {
            _showLogoutDialog(context, auth);
          } else {
            setState(() => _selectedNav = i);
          }
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(context: context, builder: (_) => _AccountDialog(auth: auth));
  }
}

// ── Search Bar Widget ──────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: "Cari MacBook, ROG, atau ThinkPad...",
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

// ── Banner Card Widget ─────────────────────────────────────
class _BannerCard extends StatelessWidget {
  const _BannerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Upgrade Workstation Anda!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Dapatkan diskon hingga 30% hari ini.",
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "\"CEK PROMO\"",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Opacity(
              opacity: 0.2,
              child: const Icon(
                Icons.laptop_mac,
                size: 120,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category Chip Widget ───────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final _CategoryItem item;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(item.label),
      selected: selected,
      onSelected: (_) => onTap(),
      avatar: Icon(item.icon, size: 16, color: selected ? Colors.white : Colors.black),
    );
  }
}

// ── Product Card Widget ────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final String Function(double) formatPrice;
  const _ProductCard({required this.product, required this.formatPrice});

  @override
  Widget build(BuildContext context) {
    final favProv = context.watch<FavoriteProvider>();
    final isFavorite = favProv.isFavorite(product);

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => _ProductDetailSheet(product: product, formatPrice: formatPrice),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) { 
                          return const Center(child: Icon(Icons.laptop, size: 50, color: Colors.grey));
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(formatPrice(product.price), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => favProv.toggleFavorite(product),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Navigation Widget ───────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  const _BottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Consumer<CartProvider>(
            builder: (context, cartProv, _) {
              final count = cartProv.itemCount; 
              return Badge(
                label: Text('$count'),
                isLabelVisible: count > 0,
                child: const Icon(Icons.shopping_cart),
              );
            },
          ),
          label: 'Cart',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorite'),
        const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
      ],
    );
  }
}

// ── Account Dialog ─────────────────────────────────────────
class _AccountDialog extends StatelessWidget {
  final AuthProvider auth;
  const _AccountDialog({required this.auth});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final String email = auth.firebaseUser?.email ?? "";
    final String name = auth.firebaseUser?.displayName ?? (email.isNotEmpty ? email.split('@')[0] : "User");

    return AlertDialog(
      title: const Text('Akun'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF1565C0),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "U",
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const Divider(),
          SwitchListTile(
            title: Text(themeProvider.isDark ? "Mode Gelap" : "Mode Terang"),
            secondary: Icon(themeProvider.isDark ? Icons.dark_mode : Icons.light_mode),
            value: themeProvider.isDark,
            onChanged: (_) => themeProvider.toggle(),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            await auth.logout();
            if (context.mounted) Navigator.pushReplacementNamed(context, AppRouter.login);
          },
          child: const Text('Logout', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

// ── Product Detail Sheet (VERSI CEPAT) ─────────────────────
class _ProductDetailSheet extends StatelessWidget {
  final ProductModel product;
  final String Function(double) formatPrice;
  const _ProductDetailSheet({required this.product, required this.formatPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrl,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const Icon(Icons.laptop, size: 100),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(formatPrice(product.price), style: const TextStyle(fontSize: 18, color: Colors.blue)),
          const SizedBox(height: 16),
          Text(product.description),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final cartProv = context.read<CartProvider>();
                
                // LANGSUNG TUTUP MODAL
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${product.name} sedang ditambahkan..."),
                    backgroundColor: Colors.blue,
                    duration: const Duration(milliseconds: 600),
                  ),
                );

                // PROSES BACKGROUND
                cartProv.addToCart(product.id, 1).then((success) {
                  if (success) {
                    cartProv.fetchCart(); 
                  }
                });
              },
              child: const Text("Tambah ke Keranjang"),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Halaman Favorite ───────────────────────────────────────
class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final favProv = context.watch<FavoriteProvider>();
    final items = favProv.favoriteItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("My Favorites", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text("Belum ada produk favorit."))
              : ListView.builder(
                  itemCount: items.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final p = items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            p.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => const Icon(Icons.laptop),
                          ),
                        ),
                        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Rp ${p.price}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => favProv.toggleFavorite(p),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}