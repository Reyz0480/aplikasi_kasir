import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../utils/pdf_helper.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardController c;
  final PageController _pageController = PageController();
  final RxInt _currentPage = 0.obs;
  final RxBool _isGeneratingPdf = false.obs;

  @override
  void initState() {
    super.initState();
    c = Get.find<DashboardController>();
    c.loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(
          () => c.isLoading.value
              ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
              : RefreshIndicator(
                  color: AppColors.accent,
                  onRefresh: c.loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Selamat datang di kasir', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
          SizedBox(height: 4),
          Text(
            'Doyan\nJajan.id',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary),
          ),
        ],
      ),
    ),
    ClipOval(
      child: Image.asset(
        'lib/img/doyanjajan.jpeg',
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(color: AppColors.borderLight, shape: BoxShape.circle),
          child: const Icon(Icons.storefront, color: AppColors.primary),
        ),
      ),
    ),
  ],
),

                        const SizedBox(height: 18),

                        // ==================== CAROUSEL 3-SWIPE ====================
                        SizedBox(
                          height: 160,
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (i) => _currentPage.value = i,
                            children: [
                              _CarouselStokMenipis(c: c),
                              _CarouselTerlaris(c: c, onTap: c.scrollToTerlaris),
                              _CarouselLaporan(c: c, onTap: c.scrollToLaporan),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (i) {
                              final active = _currentPage.value == i;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: active ? 20 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: active ? AppColors.accent : AppColors.borderLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                        ),
                        // ==================== END CAROUSEL ====================

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Hari ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFB9F6CA), borderRadius: BorderRadius.circular(20)),
                              child: const Text('LIVE', style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        _StatCard(
                          icon: Icons.payments_outlined,
                          label: 'Total Penjualan',
                          value: Formatter.rupiah(c.totalPenjualanHariIni),
                          trailing: c.totalPenjualanKemarin > 0
                              ? Row(
                                  children: [
                                    Icon(c.persenVsKemarin >= 0 ? Icons.trending_up : Icons.trending_down,
                                        size: 16, color: c.persenVsKemarin >= 0 ? AppColors.success : AppColors.danger),
                                    const SizedBox(width: 4),
                                    Text('${c.persenVsKemarin.toStringAsFixed(0)}% vs Kemarin',
                                        style: TextStyle(
                                            color: c.persenVsKemarin >= 0 ? AppColors.success : AppColors.danger,
                                            fontWeight: FontWeight.w600, fontSize: 13)),
                                  ],
                                )
                              : null,
                        ),

                        const SizedBox(height: 12),

                        _StatCard(
                          icon: Icons.receipt_long_outlined,
                          label: 'Jumlah Transaksi',
                          value: '${c.jumlahTransaksiHariIni}',
                          trailing: Row(
                            children: [
                              const Icon(Icons.arrow_upward, size: 16, color: AppColors.success),
                              const SizedBox(width: 4),
                              Text('${c.jumlahTransaksiHariIni} pesanan',
                                  style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        _StatCard(
                          icon: Icons.inventory_2_outlined,
                          label: 'Produk Terjual',
                          value: '${c.produkTerjualHariIni} Pcs',
                          trailing: Text('Paling Laris: ${c.produkPalingLarisHariIni}',
                              style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
                        ),

                        const SizedBox(height: 16),

                        // ==================== LAPORAN RINGKAS (ada key untuk scroll target) ====================
                        Container(
                          key: c.laporanRingkasKey,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(color: AppColors.cardWhite, borderRadius: BorderRadius.circular(18)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Laporan Ringkas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                  const Text('7 hari terakhir', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Margin Keuntungan', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                                          const SizedBox(height: 4),
                                          Text('${c.marginKeuntunganPersen >= 0 ? '+' : ''}${c.marginKeuntunganPersen.toStringAsFixed(1)}%',
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.success)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Rata-rata Transaksi', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                                          const SizedBox(height: 4),
                                          Text(Formatter.rupiah(c.rataRataTransaksi), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Obx(
                                () => SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: _isGeneratingPdf.value
                                        ? null
                                        : () async {
                                            _isGeneratingPdf.value = true;
                                            await PdfHelper.generateLaporanRingkasPdf(c);
                                            _isGeneratingPdf.value = false;
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    icon: _isGeneratingPdf.value
                                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : const Icon(Icons.download, color: Colors.white),
                                    label: Text(_isGeneratingPdf.value ? 'Membuat PDF...' : 'Download Laporan',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ==================== TERLARIS MINGGU INI (ada key untuk scroll target, 5 item + medali) ====================
                        Container(
                          key: c.terlarisKey,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(color: AppColors.cardWhite, borderRadius: BorderRadius.circular(18)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Terlaris Minggu Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 12),
                              if (c.terlarisMingguIni.isEmpty)
                                const Text('Belum ada penjualan minggu ini', style: TextStyle(color: AppColors.textGrey))
                              else
                                ...c.terlarisMingguIni.asMap().entries.map((entry) {
                                  final rank = entry.key;
                                  final item = entry.value;
                                  final produk = c.products.firstWhereOrNull((p) => p['nama'] == item.key);
                                  final fotoPath = produk?['fotoPath'] as String?;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
                                    child: Row(
                                      children: [
                                        _MedalOrRank(rank: rank),
                                        const SizedBox(width: 10),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: fotoPath != null && fotoPath.isNotEmpty
                                              ? Image.file(File(fotoPath), width: 44, height: 44, fit: BoxFit.cover)
                                              : Container(width: 44, height: 44, color: AppColors.borderLight),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.key, style: const TextStyle(fontWeight: FontWeight.w700)),
                                              Text('${item.value} Terjual', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          produk != null ? Formatter.rupiah(produk['hargaJual']) : '-',
                                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}

// ==================== WIDGET CAROUSEL ====================

class _CarouselStokMenipis extends StatelessWidget {
  final DashboardController c;
  const _CarouselStokMenipis({required this.c});

  @override
  Widget build(BuildContext context) {
    final totalProduk = c.products.length;
    final jumlahMenipis = c.produkStokMenipis.length;

    String judul;
    String deskripsi;

    if (totalProduk == 0) {
      judul = 'Belum Ada Produk';
      deskripsi = 'Tambahkan produk terlebih dahulu lewat menu Settings > Tambah Produk.';
    } else if (jumlahMenipis > 0) {
      judul = 'Ingatkan Stok Menipis!';
      deskripsi = '$jumlahMenipis produk perlu restock segera untuk menghindari kekosongan menu.';
    } else {
      judul = 'Stok Aman';
      deskripsi = 'Semua produk masih tersedia dengan stok yang cukup.';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                totalProduk == 0 ? Icons.inventory_2_outlined : Icons.warning_amber_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  judul,
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(deskripsi, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const Spacer(),
          if (totalProduk == 0 || jumlahMenipis > 0)
            ElevatedButton(
              onPressed: () {
                if (totalProduk == 0) {
                  Get.offNamed(AppRoutes.settings);
                } else {
                  Get.offNamed(AppRoutes.product);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                totalProduk == 0 ? 'Tambah Produk' : 'Cek Inventaris',
                style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

class _CarouselTerlaris extends StatelessWidget {
  final DashboardController c;
  final VoidCallback onTap;
  const _CarouselTerlaris({required this.c, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final topItem = c.terlarisMingguIni.isNotEmpty ? c.terlarisMingguIni.first : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.white),
                SizedBox(width: 8),
                Text('Terlaris Minggu Ini', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              topItem != null
                  ? '${topItem.key} terjual ${topItem.value}x minggu ini!'
                  : 'Belum ada penjualan minggu ini.',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const Spacer(),
            Row(
              children: const [
                Text('Lihat selengkapnya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: Colors.white, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CarouselLaporan extends StatelessWidget {
  final DashboardController c;
  final VoidCallback onTap;
  const _CarouselLaporan({required this.c, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B3A0E), Color(0xFFE85D0B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(Icons.insert_chart_rounded, color: Colors.white.withOpacity(0.15), size: 90),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bar_chart_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Laporan Ringkas', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Omzet 7 hari terakhir: ${Formatter.rupiah(c.totalPenjualanMingguIni)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Spacer(),
                Row(
                  children: const [
                    Text('Lihat & unduh laporan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MedalOrRank extends StatelessWidget {
  final int rank; // 0-based

  const _MedalOrRank({required this.rank});

  @override
  Widget build(BuildContext context) {
    Color? medalColor;
    if (rank == 0) medalColor = const Color(0xFFFFD700); // emas
    if (rank == 1) medalColor = const Color(0xFFC0C0C0); // perak
    if (rank == 2) medalColor = const Color(0xFFCD7F32); // perunggu

    if (medalColor != null) {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(color: medalColor, shape: BoxShape.circle),
        child: const Icon(Icons.star, color: Colors.white, size: 15),
      );
    }

    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.borderLight, shape: BoxShape.circle),
      child: Text('${rank + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGrey)),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const _StatCard({required this.icon, required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardWhite, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          if (trailing != null) ...[const SizedBox(height: 6), trailing!],
        ],
      ),
    );
  }
}