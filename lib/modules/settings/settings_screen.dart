import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'settings_controller.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsController c;

  @override
  void initState() {
    super.initState();
    c = Get.find<SettingsController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

Center(
  child: Obx(
    () => Stack(
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accent, width: 0),
          ),
          clipBehavior: Clip.antiAlias,
          child: c.profileFotoPath.value != null && c.profileFotoPath.value!.isNotEmpty
              ? Image.file(File(c.profileFotoPath.value!), fit: BoxFit.cover)
              : Image.asset(
                  'lib/img/doyanjajan.jpeg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.storefront, size: 60, color: AppColors.primary),
                ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: c.pilihFotoProfil,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    ),
  ),
),

const SizedBox(height: 12),

const Center(
  child: Text(
    'Doyan Jajan.id',
    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary),
  ),
),
const SizedBox(height: 6),
Center(
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFB9F6CA),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      c.role,
      style: const TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.w700, fontSize: 13),
    ),
  ),
),

              const SizedBox(height: 28),

              _MenuTile(
                icon: Icons.add_box_outlined,
                label: 'Tambah Produk',
                onTap: () => Get.toNamed(AppRoutes.tambahProduk),
              ),
              const SizedBox(height: 12),
_MenuTile(
  icon: Icons.inventory_2_outlined,
  label: 'Atur Stok',
  onTap: () => Get.toNamed(AppRoutes.aturStok),
),
              const SizedBox(height: 12),
              _MenuTile(
                icon: Icons.bar_chart_rounded,
                label: 'Statistik',
                onTap: () => Get.toNamed(AppRoutes.statistik),
              ),
              const SizedBox(height: 12),
_MenuTile(
  icon: Icons.qr_code_2,
  label: 'Atur QRIS Toko',
  onTap: () {
    Get.dialog(
      AlertDialog(
        title: const Text('Atur QRIS Toko'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scan QRIS statis milikmu dengan aplikasi scan QR apa saja, lalu tempel (paste) hasil teksnya di sini.',
              style: TextStyle(fontSize: 13, color: AppColors.textGrey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: c.qrisStringCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tempel teks QRIS di sini...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
  onPressed: () async {
    final berhasil = await c.simpanQris();
    if (berhasil) {
      Get.back(); // hanya tutup dialog kalau berhasil disimpan
    }
  },
  child: const Text('Simpan'),
),
        ],
      ),
    );
  },
),
              const SizedBox(height: 12),
              _MenuTile(
  icon: Icons.info_outline,
  label: 'Tentang Aplikasi',
  onTap: () => Get.toNamed(AppRoutes.tentangAplikasi),
),
const SizedBox(height: 12),
_MenuTile(
  icon: Icons.help_outline,
  label: 'Bantuan & FAQ',
  onTap: () => Get.toNamed(AppRoutes.bantuanFaq),
),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: c.logout,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE2E2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.logout, color: AppColors.danger, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Logout',
                          style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.danger),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Center(
                child: Text(
                  'Doyan Jajan.id POS v1.0.0',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}