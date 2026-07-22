import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../database/db_helper.dart';
import '../data/store_info_repo.dart';
import '../utils/printer_service.dart';

class StrukController extends GetxController {
  final int transactionId;
  StrukController(this.transactionId);

  final isLoading = true.obs;
  final transaksi = <String, dynamic>{}.obs;
  final items = <Map<String, dynamic>>[].obs;
  final storeInfo = <String, String>{}.obs;
  final isPrinting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    final trx = await DBHelper.instance.getTransactionById(transactionId);
    final trxItems = await DBHelper.instance.getItemsByTransactionId(transactionId);
    final info = await StoreInfoRepo.getInfo();

    if (trx != null) transaksi.value = trx;
    items.value = trxItems;
    storeInfo.value = info;
    isLoading.value = false;
  }

  String get tanggalFormatted {
    final raw = transaksi['createdAt'] as String?;
    if (raw == null) return '-';
    final date = DateTime.parse(raw);
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  Future<void> cetakStruk() async {
  isPrinting.value = true;

  final granted = await PrinterService.instance.requestPermissions();
  if (!granted) {
    isPrinting.value = false;
    Get.snackbar('Izin Ditolak', 'Aplikasi butuh izin Bluetooth untuk mencetak',
        snackPosition: SnackPosition.TOP);
    return;
  }

  // Selalu putuskan koneksi lama dulu, supaya tidak ada sesi "menggantung"
  await PrinterService.instance.disconnect();
  await Future.delayed(const Duration(milliseconds: 300));

  final devices = await PrinterService.instance.getPairedDevices();
  if (devices.isEmpty) {
    isPrinting.value = false;
    Get.snackbar('Printer Tidak Ditemukan',
        'Pasangkan (pair) printer Bluetooth dulu lewat Pengaturan HP',
        snackPosition: SnackPosition.TOP);
    return;
  }

  BluetoothInfo? selected;
  if (devices.length == 1) {
    selected = devices.first;
  } else {
    isPrinting.value = false;
    selected = await Get.dialog<BluetoothInfo>(_PrinterPickerDialog(devices: devices));
    if (selected == null) return;
    isPrinting.value = true;
  }

  await PrinterService.instance.connect(selected.macAdress);

  // Tunggu sampai status koneksi benar-benar TRUE, maksimal 5 detik
  bool terhubung = false;
  for (int i = 0; i < 10; i++) {
    await Future.delayed(const Duration(milliseconds: 500));
    terhubung = await PrinterService.instance.isConnected;
    if (terhubung) break;
  }

  if (!terhubung) {
    isPrinting.value = false;
    Get.snackbar('Gagal Terhubung',
        'Tidak bisa terhubung ke printer. Pastikan printer menyala dan dalam jangkauan',
        snackPosition: SnackPosition.TOP, backgroundColor: Colors.red.shade100);
    return;
  }

  // Jeda tambahan sesaat setelah koneksi stabil, sebelum kirim data
  await Future.delayed(const Duration(milliseconds: 500));

  final sukses = await PrinterService.instance.printStruk(
    namaToko: storeInfo['nama'] ?? '',
    alamatToko: storeInfo['alamat'] ?? '',
    telepon: storeInfo['telepon'] ?? '',
    instagram: storeInfo['instagram'] ?? '',
    noTransaksi: transaksi['kodeTransaksi'] ?? '',
    tanggal: tanggalFormatted,
    kasir: transaksi['kasirNama'] ?? '',
    items: items,
    subtotal: (transaksi['subtotal'] as num?)?.toDouble() ?? 0,
    total: (transaksi['total'] as num?)?.toDouble() ?? 0,
    metode: transaksi['metodePembayaran'] ?? '',
    uangDiterima: (transaksi['uangDiterima'] as num?)?.toDouble() ?? 0,
    kembalian: (transaksi['kembalian'] as num?)?.toDouble() ?? 0,
  );

  isPrinting.value = false;

  if (sukses) {
    Get.snackbar('Berhasil', 'Struk berhasil dicetak',
        snackPosition: SnackPosition.TOP, backgroundColor: const Color(0xFFC8E6C9));
  } else {
    Get.snackbar('Gagal', 'Data gagal terkirim ke printer, coba lagi',
        snackPosition: SnackPosition.TOP, backgroundColor: Colors.red.shade100);
  }
}
}

class _PrinterPickerDialog extends StatelessWidget {
  final List<BluetoothInfo> devices;
  const _PrinterPickerDialog({required this.devices});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pilih Printer'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return ListTile(
              leading: const Icon(Icons.print),
              title: Text(device.name),
              subtitle: Text(device.macAdress),
              onTap: () => Get.back(result: device),
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
      ],
    );
  }
}