import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/struk_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import '../../utils/pdf_helper.dart';

class StrukScreen extends StatelessWidget {
  const StrukScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int transactionId = Get.arguments as int;
    final c = Get.put(StrukController(transactionId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(
          () {
            if (c.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: AppColors.accent));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
                        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                      ),
                      const Text(
                        'Doyan Jajan.id',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: 70, height: 70,
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 40),
                  ),

                  const SizedBox(height: 14),

                  const Text('Pembayaran Berhasil!',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    'Transaksi #${c.transaksi['kodeTransaksi']} telah selesai diproses.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textGrey),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 70, height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accent, width: 2),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            'lib/img/doyanjajan.jpeg',
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(Icons.storefront, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(c.storeInfo['nama'] ?? '',
                            style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(c.storeInfo['alamat'] ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, color: Colors.black87)),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.call, size: 13, color: AppColors.textGrey),
                            const SizedBox(width: 4),
                            Text(c.storeInfo['telepon'] ?? '', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt_outlined, size: 13, color: AppColors.textGrey),
                            const SizedBox(width: 4),
                            Text(c.storeInfo['instagram'] ?? '', style: const TextStyle(fontSize: 12)),
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: _DashedLine(),
                        ),

                        _rowInfo('No. Transaksi', c.transaksi['kodeTransaksi'] ?? '-'),
                        _rowInfo('Tanggal', c.tanggalFormatted),
                        _rowInfo('Kasir', c.transaksi['kasirNama'] ?? '-'),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: _DashedLine(),
                        ),

                        ...c.items.map((item) {
                          final nama = item['nama'] as String;
                          final qty = item['qty'] as int;
                          final harga = (item['harga'] as num).toDouble();
                          final subtotal = (item['subtotal'] as num).toDouble();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(nama, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                      Text('${qty}x ${Formatter.rupiah(harga)}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                                    ],
                                  ),
                                ),
                                Text(Formatter.rupiah(subtotal), style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          );
                        }),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: _DashedLine(),
                        ),

                        _rowInfo('Subtotal', Formatter.rupiah(c.transaksi['subtotal'] ?? 0)),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                              Text(
                                Formatter.rupiah(c.transaksi['total'] ?? 0),
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.accent),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              _rowInfo('Metode Pembayaran',
                                  c.transaksi['metodePembayaran'] == 'Tunai' ? 'Tunai (Cash)' : 'QRIS'),
                              if (c.transaksi['metodePembayaran'] == 'Tunai') ...[
                                _rowInfo('Bayar (Tunai)', Formatter.rupiah(c.transaksi['uangDiterima'] ?? 0)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Kembalian', style: TextStyle(color: AppColors.textGrey)),
                                    Text(
                                      Formatter.rupiah(c.transaksi['kembalian'] ?? 0),
                                      style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          '"Terima kasih sudah jajan!\nSemoga harimu semanis jajanannya."',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.textGrey, fontSize: 13),
                        ),

                        const SizedBox(height: 10),

                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            Icon(Icons.star_border, color: Colors.amber, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => _ActionButton(
                            icon: Icons.print,
                            label: c.isPrinting.value ? 'Mencetak...' : 'Cetak',
                            loading: c.isPrinting.value,
                            onTap: c.isPrinting.value ? null : c.cetakStruk,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.picture_as_pdf,
                          label: 'Simpan PDF',
                          onTap: () => PdfHelper.simpanStrukPdf(c),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _rowInfo(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
          Text(value is double ? Formatter.rupiah(value) : '$value',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 8).floor();
        return Row(
          children: List.generate(
            count,
            (_) => const Expanded(child: SizedBox(height: 1, child: ColoredBox(color: AppColors.borderLight))),
          ).expand((w) => [w, const SizedBox(width: 4)]).toList(),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool loading;

  const _ActionButton({required this.icon, required this.label, this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFDE4D8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            loading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                : Icon(icon, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}