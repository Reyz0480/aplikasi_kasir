import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'pesanan_controller.dart';

class PesananScreen extends StatefulWidget {
  const PesananScreen({super.key});

  @override
  State<PesananScreen> createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> {
  late final PesananController c;

  @override
void initState() {
  super.initState();
  c = Get.find<PesananController>();   
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
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
                ),
                Expanded(
  child: Obx(
    () {
      if (c.repo.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.accent));
      }

      // Tampilkan "Pesanan Kosong" kalau tidak ada item di keranjang
      if (c.cart.items.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_basket_outlined, size: 48, color: AppColors.borderLight),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pesanan Kosong',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textGrey),
              ),
              const SizedBox(height: 6),
              const Text(
                'Klik tombol (+) untuk mulai memilih produk',
                style: TextStyle(fontSize: 13, color: AppColors.textGrey),
              ),
            ],
          ),
        );
      }

      // Kalau ada item, tampilkan grid HANYA untuk produk yang ada di keranjang
      final produkDiKeranjang = c.repo.products
          .where((p) => c.cart.items.containsKey(p['id']))
          .toList();

      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.6,
        ),
        itemCount: produkDiKeranjang.length,
        itemBuilder: (context, index) {
          return _PesananCard(produk: produkDiKeranjang[index], controller: c);
        },
      );
    },
  ),
),
              ],
            ),
            Positioned(
  right: 20,
  bottom: 20,
  child: FloatingActionButton(
    heroTag: 'btnBayar',
    backgroundColor: AppColors.success,
    onPressed: () {
      if (c.cart.totalItemCount == 0) {
        Get.snackbar('Keranjang Kosong', 'Pilih minimal 1 produk untuk dibayar',
            snackPosition: SnackPosition.TOP);
        return;
      }
      if (Get.routeTree.routes.any((r) => r.name == AppRoutes.pembayaran)) {
        Get.toNamed(AppRoutes.pembayaran);
      } else {
        Get.snackbar('Segera Hadir', 'Halaman Pembayaran belum dibuat',
            snackPosition: SnackPosition.TOP);
      }
    },
    child: const Icon(Icons.payments, color: Colors.white),
  ),
),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}

class _PesananCard extends StatelessWidget {
  final Map<String, dynamic> produk;
  final PesananController controller;

  const _PesananCard({required this.produk, required this.controller});

  @override
  Widget build(BuildContext context) {
    final productId = produk['id'] as int;
    final nama = produk['nama'] as String;
    final harga = (produk['hargaJual'] as num).toDouble();
    final stok = produk['stok'] as int;
    final fotoPath = produk['fotoPath'] as String?;
    final cart = controller.cart;

    return Obx(() {
      final qty = cart.qtyOf(productId);
      final included = cart.isIncluded(productId);
      final showGray = qty > 0 && !included;

      return AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: showGray ? 0.4 : 1,
        child: Container(
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
                    aspectRatio: 1.2,
                    child: fotoPath != null && fotoPath.isNotEmpty
                        ? Image.file(File(fotoPath), fit: BoxFit.cover, width: double.infinity)
                        : Container(
                            color: AppColors.background,
                            child: const Icon(Icons.fastfood, color: AppColors.borderLight, size: 36),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                      child: Text(
                        '$qty',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Obx(() {
  final qty = cart.qtyOf(productId);
  final displayHarga = qty > 0 ? harga * qty : harga;
  return Text(
    Formatter.rupiah(displayHarga),
    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 14),
  );
}),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: qty > 0 ? () => cart.removeItem(productId) : null,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.borderLight.withOpacity(qty > 0 ? 1 : 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.remove, size: 14, color: AppColors.primary),
                          ),
                        ),
                        GestureDetector(
                          onTap: stok > qty
                              ? () => cart.addItem(
                                    productId: productId,
                                    nama: nama,
                                    harga: harga,
                                    fotoPath: fotoPath,
                                    maxStok: stok,
                                  )
                              : null,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: stok > qty ? AppColors.primary : AppColors.borderLight,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.add, size: 14, color: stok > qty ? Colors.white : Colors.white70),
                          ),
                        ),
                        SizedBox(
                          width: 34,
                          height: 22,
                          child: FittedBox(
                            child: Switch(
                              value: included,
                              activeColor: AppColors.success,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              onChanged: qty > 0 ? (_) => cart.toggleIncluded(productId) : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}