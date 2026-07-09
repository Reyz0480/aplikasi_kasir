import 'package:get/get.dart';
import '../../database/db_helper.dart';

class StatistikController extends GetxController {
  final selectedBulan = DateTime.now().obs;
  final isLoading = true.obs;
  final chartMode = 'mingguan'.obs; // 'mingguan' atau 'harian'

  final totalPenjualan = 0.0.obs;
  final totalKeuntungan = 0.0.obs;
  final totalModal = 0.0.obs;

  final chartLabels = <String>[].obs;
  final chartValues = <double>[].obs;

  static const namaBulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  static const namaBulanLengkap = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  static const namaHari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  String get bulanTahunLabel =>
      '${namaBulan[selectedBulan.value.month - 1]} ${selectedBulan.value.year}';

  void setBulan(int bulan, int tahun) {
    selectedBulan.value = DateTime(tahun, bulan, 1);
    loadData();
  }

  void setChartMode(String mode) {
    chartMode.value = mode;
    _buildChartData();
  }

  Future<void> loadData() async {
    isLoading.value = true;

    final ringkasan = await DBHelper.instance.getStatistikBulanan(selectedBulan.value);
    totalPenjualan.value = ringkasan['totalPenjualan'] as double;
    totalKeuntungan.value = ringkasan['totalKeuntungan'] as double;
    totalModal.value = ringkasan['totalModal'] as double;

    _transaksiBulanIni = await DBHelper.instance.getTransactionsInMonth(selectedBulan.value);
    _buildChartData();

    isLoading.value = false;
  }

  List<Map<String, dynamic>> _transaksiBulanIni = [];

  void _buildChartData() {
    if (chartMode.value == 'mingguan') {
      _buildWeekly();
    } else {
      _buildDaily();
    }
  }

  void _buildWeekly() {
    final daysInMonth = DateTime(selectedBulan.value.year, selectedBulan.value.month + 1, 0).day;
    final jumlahMinggu = ((daysInMonth - 1) ~/ 7) + 1;

    final sums = List<double>.filled(jumlahMinggu, 0);

    for (final trx in _transaksiBulanIni) {
      final tgl = DateTime.parse(trx['createdAt'] as String);
      final mingguKe = ((tgl.day - 1) ~/ 7);
      sums[mingguKe] += (trx['total'] as num).toDouble();
    }

    chartLabels.value = List.generate(jumlahMinggu, (i) => 'Mgu ${i + 1}');
    chartValues.value = sums;
  }

  void _buildDaily() {
    final sums = List<double>.filled(7, 0); // index 0 = Senin ... 6 = Minggu

    for (final trx in _transaksiBulanIni) {
      final tgl = DateTime.parse(trx['createdAt'] as String);
      final index = tgl.weekday - 1; // DateTime.weekday: 1=Senin ... 7=Minggu
      sums[index] += (trx['total'] as num).toDouble();
    }

    chartLabels.value = namaHari;
    chartValues.value = sums;
  }
}