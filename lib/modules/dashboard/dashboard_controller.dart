import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../database/db_helper.dart';
import '../../database/session.dart';

class DashboardController extends GetxController {
  final isLoading = true.obs;
  final transaksiHariIni = <Map<String, dynamic>>[].obs;
  final transaksiKemarin = <Map<String, dynamic>>[].obs;
  final transaksiMingguIni = <Map<String, dynamic>>[].obs;
  final products = <Map<String, dynamic>>[].obs;

  // Kunci untuk fitur "tap kartu carousel -> scroll ke section"
  final terlarisKey = GlobalKey();
  final laporanRingkasKey = GlobalKey();

  String get namaKasir => Session.nama;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  DateTime get _startOfToday {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _startOfYesterday => _startOfToday.subtract(const Duration(days: 1));
  DateTime get _startOfWeek => _startOfToday.subtract(const Duration(days: 6));
  DateTime get _endOfToday => _startOfToday.add(const Duration(days: 1));

  Future<void> loadData() async {
    isLoading.value = true;

    transaksiHariIni.value = await DBHelper.instance.getTransactionsByDateRange(_startOfToday, _endOfToday);
    transaksiKemarin.value = await DBHelper.instance.getTransactionsByDateRange(_startOfYesterday, _startOfToday);
    transaksiMingguIni.value = await DBHelper.instance.getTransactionsByDateRange(_startOfWeek, _endOfToday);
    products.value = await DBHelper.instance.getAllProducts();

await _hitungAgregatMingguan();

isLoading.value = false;
  }

  void scrollToTerlaris() {
    final ctx = terlarisKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void scrollToLaporan() {
    final ctx = laporanRingkasKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  double get totalPenjualanHariIni => transaksiHariIni.fold(0.0, (sum, t) => sum + (t['total'] as num));
  double get totalPenjualanKemarin => transaksiKemarin.fold(0.0, (sum, t) => sum + (t['total'] as num));

  double get persenVsKemarin {
    if (totalPenjualanKemarin == 0) return 0;
    return ((totalPenjualanHariIni - totalPenjualanKemarin) / totalPenjualanKemarin) * 100;
  }

  int get jumlahTransaksiHariIni => transaksiHariIni.length;

  int get produkTerjualHariIni => _cachedQtyHariIni;

  

  int _cachedQtyHariIni = 0;

  

  String get produkPalingLarisHariIni {
    if (_qtyPerProdukHariIni.isEmpty) return '-';
    return _qtyPerProdukHariIni.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Map<String, int> _qtyPerProdukHariIni = {};
  Map<String, int> _qtyPerProdukMinggu = {};
  double _totalModalMinggu = 0;

  Future<void> _hitungAgregatMingguan() async {
    final Map<String, int> qtyHariIni = {};
    final Map<String, int> qtyMinggu = {};
    double modalMinggu = 0;

    for (final trx in transaksiMingguIni) {
      final items = await DBHelper.instance.getItemsByTransactionId(trx['id'] as int);
      final isHariIni = transaksiHariIni.any((t) => t['id'] == trx['id']);

      for (final item in items) {
        final nama = item['nama'] as String;
        final qty = item['qty'] as int;
        qtyMinggu[nama] = (qtyMinggu[nama] ?? 0) + qty;
        if (isHariIni) qtyHariIni[nama] = (qtyHariIni[nama] ?? 0) + qty;

        final produk = products.firstWhereOrNull((p) => p['id'] == item['productId']);
        if (produk != null) {
          modalMinggu += (produk['hargaModal'] as num) * qty;
        }
      }
    }

    _qtyPerProdukHariIni = qtyHariIni;
    _qtyPerProdukMinggu = qtyMinggu;
    _totalModalMinggu = modalMinggu;
    _cachedQtyHariIni = qtyHariIni.values.fold(0, (a, b) => a + b);
  }

  double get totalModalMingguIni => _totalModalMinggu;

double get totalKeuntunganMingguIni => totalPenjualanMingguIni - _totalModalMinggu;

int get totalProdukTerjualMingguIni =>
    _qtyPerProdukMinggu.values.fold(0, (sum, qty) => sum + qty);

  double get totalPenjualanMingguIni => transaksiMingguIni.fold(0.0, (sum, t) => sum + (t['total'] as num));

  double get marginKeuntunganPersen {
    if (totalPenjualanMingguIni == 0) return 0;
    final untung = totalPenjualanMingguIni - _totalModalMinggu;
    return (untung / totalPenjualanMingguIni) * 100;
  }

  double get rataRataTransaksi {
    if (transaksiMingguIni.isEmpty) return 0;
    return totalPenjualanMingguIni / transaksiMingguIni.length;
  }

  List<MapEntry<String, int>> get terlarisMingguIni {
    final sorted = _qtyPerProdukMinggu.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  List<Map<String, dynamic>> get produkStokMenipis =>
      products.where((p) => (p['stok'] as int) <= 5 && (p['aktif'] as int) == 1).toList();

  Future<Map<String, double>> getWeeklyChartCurrentWeek() async {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final nextMonday = monday.add(const Duration(days: 7));
    final trxs = await DBHelper.instance.getTransactionsByDateRange(monday, nextMonday);

    final sums = List<double>.filled(7, 0);
    for (final t in trxs) {
      final tgl = DateTime.parse(t['createdAt'] as String);
      sums[tgl.weekday - 1] += (t['total'] as num).toDouble();
    }

    const labels = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return {for (int i = 0; i < 7; i++) labels[i]: sums[i]};
  }
}