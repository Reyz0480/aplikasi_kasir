import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  static const _items = [
    {'icon': Icons.home_rounded, 'label': 'Beranda', 'route': AppRoutes.dashboard},
    {'icon': Icons.inventory_2_outlined, 'label': 'Produk', 'route': AppRoutes.product},
    {'icon': Icons.receipt_long_outlined, 'label': 'Pesanan', 'route': AppRoutes.pesanan},
    {'icon': Icons.history_rounded, 'label': 'Riwayat', 'route': AppRoutes.riwayat},
    {'icon': Icons.settings_outlined, 'label': 'Settings', 'route': AppRoutes.settings},
  ];

  void _onTap(int index) {
    if (index == currentIndex) return;
    final route = _items[index]['route'] as String;

    if (Get.routeTree.routes.any((r) => r.name == route)) {
      Get.offNamed(route);   // <-- ganti dari Get.offAllNamed jadi Get.offNamed
    } else {
      Get.snackbar('Segera Hadir', 'Halaman ini belum dibuat',
          snackPosition: SnackPosition.TOP);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final selected = index == currentIndex;
          final item = _items[index];
          return GestureDetector(
            onTap: () => _onTap(index),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: selected ? Colors.white : AppColors.textGrey,
                    size: 22,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: selected ? Colors.white : AppColors.textGrey,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}