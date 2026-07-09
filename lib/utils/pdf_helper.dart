import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../controllers/struk_controller.dart';
import '../modules/dashboard/dashboard_controller.dart';
import '../utils/formatter.dart';

class PdfHelper {
  static Future<void> generateLaporanRingkasPdf(DashboardController c) async {
    final doc = pw.Document();
    final weeklyData = await c.getWeeklyChartCurrentWeek();
    final maxVal = weeklyData.values.isEmpty
        ? 0.0
        : weeklyData.values.reduce((a, b) => a > b ? a : b);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Text('Doyan Jajan.id', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.Text('Laporan Penjualan Ringkas', style: const pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 4),
          pw.Text('Periode: 7 hari terakhir', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.Divider(),
          pw.SizedBox(height: 10),

          pw.Row(
  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  children: [
    _ringkasBox('Total Penjualan', Formatter.rupiah(c.totalPenjualanMingguIni)),
    _ringkasBox('Total Modal', Formatter.rupiah(c.totalModalMingguIni)),
    _ringkasBox('Total Keuntungan', Formatter.rupiah(c.totalKeuntunganMingguIni)),
  ],
),
pw.SizedBox(height: 14),
pw.Row(
  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  children: [
    _ringkasBox('Margin Keuntungan', '${c.marginKeuntunganPersen.toStringAsFixed(1)}%'),
    _ringkasBox('Total Produk Terjual', '${c.totalProdukTerjualMingguIni} pcs'),
    _ringkasBox('Rata-rata Transaksi', Formatter.rupiah(c.rataRataTransaksi)),
  ],
),

          pw.SizedBox(height: 24),

          pw.Text('Tren Penjualan Mingguan (Senin - Minggu)',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),

          pw.Container(
            height: 150,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: weeklyData.entries.map((e) {
                final ratio = maxVal == 0 ? 0.0 : (e.value / maxVal);
                return pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(e.value > 0 ? Formatter.rupiah(e.value) : '', style: const pw.TextStyle(fontSize: 6)),
                    pw.SizedBox(height: 3),
                    pw.Container(
                      width: 26,
                      height: (110 * ratio) + 2,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.orange,
                        borderRadius: pw.BorderRadius.circular(3),
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(e.key.substring(0, 3), style: const pw.TextStyle(fontSize: 9)),
                  ],
                );
              }).toList(),
            ),
          ),

          pw.SizedBox(height: 24),

          pw.Text('Produk Terlaris Minggu Ini', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),

          if (c.terlarisMingguIni.isEmpty)
            pw.Text('Belum ada penjualan minggu ini', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))
          else
            pw.Table.fromTextArray(
              headers: ['Peringkat', 'Produk', 'Terjual (pcs)'],
              data: c.terlarisMingguIni.asMap().entries.map((entry) {
                return ['#${entry.key + 1}', entry.value.key, '${entry.value.value}'];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellAlignment: pw.Alignment.centerLeft,
            ),

          pw.SizedBox(height: 30),
          pw.Divider(),
          pw.Text(
            'Dicetak pada: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'laporan_penjualan_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf',
    );
  }

  static pw.Widget _ringkasBox(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }
  static Future<void> simpanStrukPdf(StrukController c) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(c.storeInfo['nama'] ?? '', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text(c.storeInfo['alamat'] ?? '', style: const pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 6),
              pw.Divider(),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('No: ${c.transaksi['kodeTransaksi']}', style: const pw.TextStyle(fontSize: 8)),
              ]),
              pw.Text(c.tanggalFormatted, style: const pw.TextStyle(fontSize: 8)),
              pw.Text('Kasir: ${c.transaksi['kasirNama']}', style: const pw.TextStyle(fontSize: 8)),
              pw.Divider(),
              ...c.items.map((item) {
                final nama = item['nama'] as String;
                final qty = item['qty'] as int;
                final harga = (item['harga'] as num).toDouble();
                final subtotal = (item['subtotal'] as num).toDouble();
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(nama, style: const pw.TextStyle(fontSize: 9)),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('${qty}x ${Formatter.rupiah(harga)}', style: const pw.TextStyle(fontSize: 8)),
                        pw.Text(Formatter.rupiah(subtotal), style: const pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                  ],
                );
              }),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.Text(Formatter.rupiah(c.transaksi['total'] ?? 0),
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text('Metode: ${c.transaksi['metodePembayaran']}', style: const pw.TextStyle(fontSize: 8)),
              if (c.transaksi['metodePembayaran'] == 'Tunai') ...[
                pw.Text('Bayar: ${Formatter.rupiah(c.transaksi['uangDiterima'] ?? 0)}', style: const pw.TextStyle(fontSize: 8)),
                pw.Text('Kembali: ${Formatter.rupiah(c.transaksi['kembalian'] ?? 0)}', style: const pw.TextStyle(fontSize: 8)),
              ],
              pw.SizedBox(height: 10),
              pw.Text('Terima kasih sudah jajan!', style: const pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await doc.save(), filename: 'struk_${c.transaksi['kodeTransaksi']}.pdf');
  }
}