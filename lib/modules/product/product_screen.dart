import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'product_controller.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}
class _ProductGridBody extends StatelessWidget {
  const _ProductGridBody();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProductController>();

    return Obx(() {
      final produkList = c.filteredProducts;
      if (produkList.isEmpty) {
        return const Center(
          child: Text('Belum ada produk', style: TextStyle(color: AppColors.textGrey)),
        );
      }
      return GridView.builder(
        padding: EdgeInsets.fromLTRB(20, 4, 20, c.cart.items.isEmpty ? 20 : 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.6,
        ),
        itemCount: produkList.length,
        itemBuilder: (context, index) {
          return _ProductCard(produk: produkList[index], controller: c);
        },
      );
    });
  }
}

class _ProductScreenState extends State<ProductScreen> {
  late final ProductController c;

  @override
void initState() {
  super.initState();
  c = Get.find<ProductController>();  
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.storefront, color: AppColors.primary, size: 26),
                      SizedBox(width: 8),
                      Text(
                        'Doyan\nJajan.id',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: c.searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Cari jajanan favorit...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                      filled: true,
                      fillColor: AppColors.cardWhite,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.accent),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    height: 40,
                    child: Obx(
                      () => ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: c.kategoriList.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final kategori = c.kategoriList[index];
                          final selected = c.selectedKategori.value == kategori;
                          return GestureDetector(
                            onTap: () => c.gantiKategori(kategori),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.accent : AppColors.cardWhite,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                kategori,
                                style: TextStyle(
                                  color: selected ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),

            Expanded(
  child: Obx(() {
    if (c.repo.isLoading.value) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }
    return const _ProductGridBody();
  }),
),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
  () => c.cart.items.isEmpty
      ? const BottomNavBar(currentIndex: 1)
      : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_basket, color: Colors.white),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                          child: Text(
                            '${c.cart.totalItemCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${c.cart.totalItemCount} Item Pesanan', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(
                          Formatter.rupiah(c.cart.totalHarga),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (Get.routeTree.routes.any((r) => r.name == AppRoutes.pesanan)) {
                        Get.toNamed(AppRoutes.pesanan);
                      } else {
                        Get.snackbar('Segera Hadir', 'Halaman Pesanan belum dibuat', snackPosition: SnackPosition.TOP);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Bayar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const BottomNavBar(currentIndex: 1),
          ],
        ),
),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> produk;
  final ProductController controller;

  const _ProductCard({required this.produk, required this.controller});

  @override
  Widget build(BuildContext context) {
    final productId = produk['id'] as int;
    final nama = produk['nama'] as String;
    final harga = (produk['hargaJual'] as num).toDouble();
    final stok = produk['stok'] as int;
    final fotoPath = produk['fotoPath'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: fotoPath != null && fotoPath.isNotEmpty
                    ? Image.file(File(fotoPath), fit: BoxFit.cover, width: double.infinity)
                    : Container(
                        color: AppColors.background,
                        child: const Icon(Icons.fastfood, color: AppColors.borderLight, size: 40),
                      ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stok > 0 ? AppColors.success : AppColors.danger,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    stok > 0 ? 'STOK: $stok' : 'HABIS',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatter.rupiah(harga),
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final qty = controller.cart.qtyOf(productId);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleBtn(
                        icon: Icons.remove,
                        color: AppColors.borderLight,
                        iconColor: AppColors.primary,
                        onTap: qty > 0 ? () => controller.cart.removeItem(productId) : null,
                      ),
                      Text('$qty', style: const TextStyle(fontWeight: FontWeight.w700)),
                      _CircleBtn(
                        icon: Icons.add,
                        color: AppColors.primary,
                        iconColor: Colors.white,
                        onTap: stok > qty
                            ? () => controller.cart.addItem(
                                  productId: productId,
                                  nama: nama,
                                  harga: harga,
                                  fotoPath: fotoPath,
                                  maxStok: stok,
                                )
                            : null,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback? onTap;

  const _CircleBtn({required this.icon, required this.color, required this.iconColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: onTap == null ? AppColors.borderLight.withOpacity(0.5) : color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: onTap == null ? Colors.white70 : iconColor),
      ),
    );
  }
}