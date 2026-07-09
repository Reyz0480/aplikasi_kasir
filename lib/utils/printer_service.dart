import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class PrinterService {
  static final PrinterService instance = PrinterService._internal();
  PrinterService._internal();

  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();
    return statuses.values.every((s) => s.isGranted || s.isLimited);
  }

  Future<List<BluetoothInfo>> getPairedDevices() async {
    return await PrintBluetoothThermal.pairedBluetooths;
  }

  Future<bool> connect(String macAddress) async {
    return await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
  }

  Future<bool> get isConnected async => await PrintBluetoothThermal.connectionStatus;

  Future<void> disconnect() async {
    await PrintBluetoothThermal.disconnect;
  }

  Future<void> printStruk({
    required String namaToko,
    required String alamatToko,
    required String telepon,
    required String instagram,
    required String noTransaksi,
    required String tanggal,
    required String kasir,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double total,
    required String metode,
    required double uangDiterima,
    required double kembalian,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    bytes += generator.text(
      namaToko,
      styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size2, width: PosTextSize.size2, bold: true),
    );
    bytes += generator.text(alamatToko, styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Telp: $telepon', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('IG: $instagram', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(text: 'No. Transaksi', width: 6),
      PosColumn(text: noTransaksi, width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Tanggal', width: 6),
      PosColumn(text: tanggal, width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Kasir', width: 6),
      PosColumn(text: kasir, width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.hr();

    for (final item in items) {
      final nama = item['nama'] as String;
      final qty = item['qty'] as int;
      final harga = (item['harga'] as num).toDouble();
      final sub = (item['subtotal'] as num).toDouble();
      bytes += generator.text(nama);
      bytes += generator.row([
        PosColumn(text: '  ${qty}x ${_rp(harga)}', width: 6),
        PosColumn(text: _rp(sub), width: 6, styles: const PosStyles(align: PosAlign.right)),
      ]);
    }

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'Subtotal', width: 6),
      PosColumn(text: _rp(subtotal), width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(text: _rp(total), width: 6, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'Metode', width: 6),
      PosColumn(text: metode, width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    if (metode == 'Tunai') {
      bytes += generator.row([
        PosColumn(text: 'Bayar', width: 6),
        PosColumn(text: _rp(uangDiterima), width: 6, styles: const PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Kembalian', width: 6),
        PosColumn(text: _rp(kembalian), width: 6, styles: const PosStyles(align: PosAlign.right)),
      ]);
    }

    bytes += generator.emptyLines(1);
    bytes += generator.text('Terima kasih sudah jajan!', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Semoga harimu semanis jajanannya.', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.emptyLines(2);
    bytes += generator.cut();

    await PrintBluetoothThermal.writeBytes(Uint8List.fromList(bytes));
  }

  String _rp(num value) {
    final str = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final posFromRight = str.length - i;
      buffer.write(str[i]);
      if (posFromRight > 1 && posFromRight % 3 == 1) buffer.write('.');
    }
    return 'Rp$buffer';
  }
}