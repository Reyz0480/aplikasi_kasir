import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'riwayat_controller.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  late final RiwayatController c;

  @override
  void initState() {
    super.initState();
    c = Get.find<RiwayatController>();
    c.expandedId.value = null; // reset supaya tidak ada kartu yang "nyangkut" terbuka dari sesi sebelumnya
    c.loadData();
  }

  IconData _iconForMetode(String metode) {
    return metode == 'QRIS' ? Icons.qr_code_2 : Icons.payments_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Riwayat',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: c.searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Cari pesanan atau ID Transaksi...',
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
                  const SizedBox(height: 12),
                  Obx(
                    () => Row(
                      children: [
                        GestureDetector(
                          onTap: () => c.setFilterHariIni(true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: c.filterHariIni.value ? AppColors.accent : AppColors.cardWhite,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Hari ini',
                              style: TextStyle(
                                color: c.filterHariIni.value ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => c.setFilterHariIni(false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: !c.filterHariIni.value ? AppColors.accent : AppColors.cardWhite,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Semua',
                              style: TextStyle(
                                color: !c.filterHariIni.value ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(
                () {
                  if (c.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.accent));
                  }
                  if (c.transaksiList.isEmpty) {
                    return const Center(
                      child: Text('Belum ada transaksi', style: TextStyle(color: AppColors.textGrey)),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    itemCount: c.transaksiList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final trx = c.transaksiList[index];
                      return _RiwayatCard(
                        trx: trx,
                        controller: c,
                        iconForMetode: _iconForMetode,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}

class _RiwayatCard extends StatelessWidget {
  final Map<String, dynamic> trx;
  final RiwayatController controller;
  final IconData Function(String) iconForMetode;

  const _RiwayatCard({
    required this.trx,
    required this.controller,
    required this.iconForMetode,
  });

  @override
  Widget build(BuildContext context) {
    final id = trx['id'] as int;
    final kode = trx['kodeTransaksi'] as String;
    final metode = trx['metodePembayaran'] as String;
    final total = (trx['total'] as num).toDouble();
    final createdAt = DateTime.parse(trx['createdAt'] as String);

    // Obx khusus untuk kartu ini saja -- inilah kunci perbaikannya,
    // supaya perubahan expandedId untuk kartu ini selalu terdeteksi.
    return Obx(() {
      final expanded = controller.expandedId.value == id;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            InkWell(
              onTap: () => controller.toggleExpand(id),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(iconForMetode(metode), color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('#$kode', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              Icon(
                                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: AppColors.textGrey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm').format(createdAt),
                            style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                metode,
                                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                              ),
                              Text(
                                Formatter.rupiah(total),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.accent,
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
            ),
            if (expanded)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  children: [
                    const Divider(),
                    ...(controller.itemsCache[id] ?? []).map((item) {
                      final nama = item['nama'] as String;
                      final qty = item['qty'] as int;
                      final harga = (item['harga'] as num).toDouble();
                      final sub = (item['subtotal'] as num).toDouble();
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(nama, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$qty x ${Formatter.rupiah(harga)}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              Formatter.rupiah(sub),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.w800)),
                        Text(
                          Formatter.rupiah(total),
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.accent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}