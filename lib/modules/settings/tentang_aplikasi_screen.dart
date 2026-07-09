import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';

class TentangAplikasiScreen extends StatelessWidget {
  const TentangAplikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  ),
                  const Text(
                    'Tentang Aplikasi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 3),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'lib/img/doyanjajan.jpeg',
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(Icons.storefront, size: 50, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'Doyan Jajan.id',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Sistem Kasir Untuk Jajanan Nagih',
                  style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Versi 1.0.0',
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Deskripsi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    Text(
                      'Doyan Jajan.id adalah aplikasi kasir (POS) sederhana yang dirancang khusus untuk membantu UMKM jajanan mengelola penjualan, stok produk, dan laporan keuangan secara mudah dan cepat. Aplikasi ini bekerja secara offline menggunakan database lokal, mendukung pembayaran Tunai dan QRIS, serta dapat mencetak struk langsung ke printer thermal Bluetooth.',
                      style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text('Dibuat Oleh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text(
                'Tim pengembang aplikasi Doyan Jajan.id',
                style: TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),

              const SizedBox(height: 14),

              const _AnggotaTimCard(
                foto: 'lib/img/reza.jpg',
                nama: 'Rahmansyah Reza',
                nim: '2023020184',
              ),
              const SizedBox(height: 12),
              const _AnggotaTimCard(
                foto: 'lib/img/sakila.jpeg',
                nama: 'Shakila Zahara',
                nim: '2023020201',
              ),
              const SizedBox(height: 12),
              const _AnggotaTimCard(
                foto: 'lib/img/josua.jpeg',
                nama: 'Josua Parulian Asi Simbolon',
                nim: '2023020461',
              ),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  '© ${DateTime.now().year} Doyan Jajan.id',
                  style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnggotaTimCard extends StatelessWidget {
  final String foto;
  final String nama;
  final String nim;

  const _AnggotaTimCard({required this.foto, required this.nama, required this.nim});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderLight, width: 0),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              foto,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                color: AppColors.background,
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text('NIRM: $nim', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}