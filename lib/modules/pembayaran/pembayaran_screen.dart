import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pembayaran_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PembayaranScreen extends StatefulWidget {
  const PembayaranScreen({super.key});

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  late final PembayaranController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(PembayaranController());
  }

  @override
  void dispose() {
    Get.delete<PembayaranController>();
    super.dispose();
  }

  Future<void> _prosesKonfirmasi() async {
  if (c.metode.value == 'Tunai' && !c.isTunaiCukup) {
    Get.snackbar('Belum Cukup', 'Uang diterima kurang dari total pembayaran',
        snackPosition: SnackPosition.TOP, backgroundColor: Colors.red.shade100);
    return;
  }
  if (c.metode.value == 'QRIS' && c.qrisExpired) {
    Get.snackbar('Kode Kadaluarsa', 'Silakan ulangi transaksi',
        snackPosition: SnackPosition.TOP, backgroundColor: Colors.red.shade100);
    return;
  }

  final transactionId = await c.konfirmasiBayar();
  if (transactionId != null) {
    Get.offNamed(AppRoutes.struk, arguments: transactionId);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
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
                          'Doyan Jajan.id',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: Column(
                        children: [
                          const Text('TOTAL PEMBAYARAN',
                              style: TextStyle(color: AppColors.textGrey, fontSize: 13, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(
                            Formatter.rupiah(c.total),
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.accent),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.textGrey),
                              const SizedBox(width: 6),
                              Text('Order #${c.orderNumber}', style: const TextStyle(color: AppColors.textGrey)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text('Metode Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),

                    Obx(
                      () => Row(
                        children: [
                          _MetodeChip(
                            label: 'Tunai',
                            icon: Icons.payments_outlined,
                            selected: c.metode.value == 'Tunai',
                            onTap: () => c.gantiMetode('Tunai'),
                          ),
                          const SizedBox(width: 10),
                          _MetodeChip(
                            label: 'QRIS',
                            icon: Icons.qr_code_2,
                            selected: c.metode.value == 'QRIS',
                            onTap: () => c.gantiMetode('QRIS'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Obx(
                      () => c.metode.value == 'Tunai'
                          ? _TunaiSection(c: c)
                          : _QrisSection(c: c),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: c.isProcessing.value ? null : _prosesKonfirmasi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: c.isProcessing.value
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Icon(
                            c.metode.value == 'Tunai' ? Icons.check_circle_outline : Icons.sync,
                            color: Colors.white,
                          ),
                    label: Text(
                      c.metode.value == 'Tunai' ? 'Konfirmasi Bayar' : 'Cek Status Pembayaran',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetodeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _MetodeChip({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : AppColors.cardWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? AppColors.accent : AppColors.borderLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : AppColors.textGrey),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TunaiSection extends StatelessWidget {
  final PembayaranController c;
  const _TunaiSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Uang Diterima', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
              const SizedBox(height: 8),
              Obx(
                () => Row(
                  children: [
                    const Text('Rp ', style: TextStyle(fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.w700)),
                    Text(
                      Formatter.rupiah(c.uangDiterima.value).replaceFirst('Rp ', ''),
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.accent, thickness: 1.4, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kembalian:', style: TextStyle(color: AppColors.textGrey)),
                  Obx(
                    () => Text(
                      Formatter.rupiah(c.kembalian),
                      style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Numpad
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.4,
          children: [
            ...['1', '2', '3', '4', '5', '6', '7', '8', '9'].map(
              (d) => _NumpadButton(label: d, onTap: () => c.inputDigit(d)),
            ),
            _NumpadButton(label: 'C', textColor: AppColors.danger, onTap: c.clearInput),
            _NumpadButton(label: '0', onTap: () => c.inputDigit('0')),
            _NumpadButton(icon: Icons.backspace_outlined, onTap: c.backspace),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            _QuickAmountButton(label: '20rb', onTap: () => c.tambahNominal(20000)),
            const SizedBox(width: 10),
            _QuickAmountButton(label: '50rb', onTap: () => c.tambahNominal(50000)),
            const SizedBox(width: 10),
            _QuickAmountButton(label: '100rb', onTap: () => c.tambahNominal(100000)),
          ],
        ),
      ],
    );
  }
}

class _NumpadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final Color? textColor;
  final VoidCallback onTap;

  const _NumpadButton({this.label, this.icon, this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: icon != null
            ? Icon(icon, color: AppColors.textGrey)
            : Text(
                label!,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor ?? Colors.black87),
              ),
      ),
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAmountButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent),
          ),
          alignment: Alignment.center,
          child: Text(label, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

class _QrisSection extends StatelessWidget {
  final PembayaranController c;
  const _QrisSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Obx(
              () {
                if (c.qrisPayload.value != null) {
                  return QrImageView(
                    data: c.qrisPayload.value!,
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                  );
                }
                return SizedBox(
                  height: 220,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.qr_code_2, size: 60, color: AppColors.borderLight),
                        const SizedBox(height: 8),
                        Text(
                          c.qrisError.value.isNotEmpty ? c.qrisError.value : 'QRIS belum tersedia',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          Obx(
            () => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sync, size: 18, color: c.qrisExpired ? AppColors.danger : AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      c.qrisExpired ? 'KODE KADALUARSA' : 'MENUNGGU PEMBAYARAN...',
                      style: TextStyle(
                        color: c.qrisExpired ? AppColors.danger : AppColors.success,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Scan QRIS untuk membayar menggunakan m-banking atau e-wallet Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Kode berlaku hingga: ', style: TextStyle(color: AppColors.textGrey)),
                    Text(
                      c.qrisExpired ? 'EXPIRED' : c.qrisWaktuFormatted,
                      style: TextStyle(
                        color: c.qrisExpired ? AppColors.danger : AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}