import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import 'statistik_controller.dart';

class StatistikScreen extends StatefulWidget {
  const StatistikScreen({super.key});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  late final StatistikController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(StatistikController());
  }

  @override
  void dispose() {
    Get.delete<StatistikController>();
    super.dispose();
  }

  void _openPicker() {
    int bulanSementara = c.selectedBulan.value.month;
    int tahunSementara = c.selectedBulan.value.year;
    final tahunSekarang = DateTime.now().year;
    final daftarTahun = List.generate(6, (i) => tahunSekarang - 4 + i);

    Get.dialog(
      StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Pilih Bulan & Tahun'),
            content: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: bulanSementara,
                    decoration: const InputDecoration(labelText: 'Bulan'),
                    items: List.generate(12, (i) => i + 1)
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(StatistikController.namaBulanLengkap[m - 1]),
                            ))
                        .toList(),
                    onChanged: (val) => setStateDialog(() => bulanSementara = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: tahunSementara,
                    decoration: const InputDecoration(labelText: 'Tahun'),
                    items: daftarTahun
                        .map((t) => DropdownMenuItem(value: t, child: Text('$t')))
                        .toList(),
                    onChanged: (val) => setStateDialog(() => tahunSementara = val!),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
              ElevatedButton(
                onPressed: () {
                  c.setBulan(bulanSementara, tahunSementara);
                  Get.back();
                },
                child: const Text('Terapkan'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                      ),
                      const Expanded(
                        child: Text(
                          'Statistik\nPenjualan',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1.1),
                        ),
                      ),
                      GestureDetector(
                        onTap: _openPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(c.bulanTahunLabel, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _SummaryCard(
                    icon: Icons.credit_card,
                    label: 'Total Penjualan',
                    value: Formatter.rupiah(c.totalPenjualan.value),
                    bgColor: AppColors.accent,
                    textColor: Colors.black87,
                  ),
                  const SizedBox(height: 14),
                  _SummaryCard(
                    icon: Icons.trending_up,
                    label: 'Total Keuntungan',
                    value: Formatter.rupiah(c.totalKeuntungan.value),
                    bgColor: const Color(0xFF8FF0A4),
                    textColor: AppColors.success,
                  ),
                  const SizedBox(height: 14),
                  _SummaryCard(
                    icon: Icons.payments_outlined,
                    label: 'Total Modal',
                    value: Formatter.rupiah(c.totalModal.value),
                    bgColor: const Color(0xFFD3E8FB),
                    textColor: Colors.black87,
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tren Penjualan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            _ModeChip(
                              label: 'Per Minggu',
                              selected: c.chartMode.value == 'mingguan',
                              onTap: () => c.setChartMode('mingguan'),
                            ),
                            const SizedBox(width: 10),
                            _ModeChip(
                              label: 'Per Hari',
                              selected: c.chartMode.value == 'harian',
                              onTap: () => c.setChartMode('harian'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: const [
                            Icon(Icons.circle, size: 10, color: AppColors.accent),
                            SizedBox(width: 6),
                            Text('Omzet (IDR)', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                          ],
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          height: 220,
                          child: c.chartValues.every((v) => v == 0)
                              ? const Center(
                                  child: Text('Belum ada penjualan di periode ini',
                                      style: TextStyle(color: AppColors.textGrey)),
                                )
                              : BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: (c.chartValues.reduce((a, b) => a > b ? a : b)) * 1.2,
                                    barTouchData: BarTouchData(
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                          return BarTooltipItem(
                                            Formatter.rupiah(rod.toY),
                                            const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                          );
                                        },
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final index = value.toInt();
                                            if (index < 0 || index >= c.chartLabels.length) {
                                              return const SizedBox.shrink();
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(
                                                c.chartLabels[index],
                                                style: const TextStyle(fontSize: 11, color: AppColors.textGrey, fontWeight: FontWeight.w600),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    gridData: const FlGridData(show: false),
                                    barGroups: List.generate(c.chartValues.length, (i) {
                                      return BarChartGroupData(
                                        x: i,
                                        barRods: [
                                          BarChartRodData(
                                            toY: c.chartValues[i],
                                            color: AppColors.accent,
                                            width: 18,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color bgColor;
  final Color textColor;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Icon(icon, size: 40, color: Colors.black.withOpacity(0.15)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.8))),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textColor)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.accent : AppColors.borderLight),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}