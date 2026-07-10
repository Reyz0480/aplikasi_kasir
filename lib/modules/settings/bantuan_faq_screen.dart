import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';

class BantuanFaqScreen extends StatefulWidget {
  const BantuanFaqScreen({super.key});

  @override
  State<BantuanFaqScreen> createState() => _BantuanFaqScreenState();
}

class _BantuanFaqScreenState extends State<BantuanFaqScreen> {
  final _deskripsiCtrl = TextEditingController();

  static const _faqList = [
    {
      'q': 'Aplikasi tiba-tiba error atau force close, apa yang harus saya lakukan?',
      'a': 'Coba tutup aplikasi sepenuhnya lalu buka kembali. Jika masalah berlanjut, hubungi Developer melalui tombol di bawah dengan menyertakan tangkapan layar (screenshot) pesan error yang muncul.',
    },
    {
      'q': 'Data transaksi atau produk saya hilang, bagaimana cara mengembalikannya?',
      'a': 'Data aplikasi ini disimpan secara lokal di perangkat. Jika data hilang setelah uninstall/clear data, sayangnya tidak bisa dikembalikan otomatis. Segera hubungi Developer untuk bantuan lebih lanjut.',
    },
    {
      'q': 'QRIS tidak bisa discan atau kadaluarsa terus?',
      'a': 'Pastikan teks QRIS yang disimpan di menu Settings > Atur QRIS Toko sudah benar dan sesuai hasil scan QRIS asli milik toko. Jika masih bermasalah, hubungi Developer.',
    },
    {
      'q': 'Printer Bluetooth tidak terdeteksi saat mencetak struk?',
      'a': 'Pastikan printer sudah dipasangkan (paired) terlebih dahulu lewat Pengaturan Bluetooth HP, bukan hanya dinyalakan. Pastikan juga izin Bluetooth aplikasi sudah diaktifkan.',
    },
    {
      'q': 'Saya lupa sandi akun kasir, bagaimana cara resetnya?',
      'a': 'Gunakan tombol "Lupa Sandi?" di halaman Login. Isi data verifikasi yang diminta, lalu kirim pesan ke Developer melalui WhatsApp untuk proses reset sandi.',
    },
    {
      'q': 'Bagaimana jika saya menemukan bug atau kesalahan lain di aplikasi?',
      'a': 'Kami sangat menghargai laporan bug. Silakan hubungi Developer melalui tombol WhatsApp di bawah, jelaskan masalah yang ditemukan selengkap mungkin (kapan terjadi, di halaman mana, dan jika memungkinkan sertakan screenshot).',
    },
  ];

  @override
  void dispose() {
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  void _openDeskripsiDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Jelaskan Masalahnya'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tulis deskripsi bug/masalah yang kamu alami. Pesan akan otomatis terisi di WhatsApp, tinggal kirim.',
              style: TextStyle(fontSize: 13, color: AppColors.textGrey),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _deskripsiCtrl,
              maxLines: 4,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Contoh: Saat klik tombol Bayar di halaman Pesanan, aplikasi force close...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton.icon(
            onPressed: () async {
              await _hubungiWhatsapp();
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
            icon: const Icon(Icons.chat, color: Colors.white, size: 18),
            label: const Text('Kirim via WhatsApp', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _hubungiWhatsapp() async {
    const nomorDeveloper = '6281362685887';
    final deskripsi = _deskripsiCtrl.text.trim();

    final pesan = Uri.encodeComponent(
      'Halo, saya ingin melaporkan bug/masalah pada aplikasi Doyan Jajan.id.\n\n'
      'Deskripsi masalah:\n'
      '${deskripsi.isNotEmpty ? deskripsi : '-'}\n\n'
      'Terima kasih.',
    );
    final url = Uri.parse('https://wa.me/$nomorDeveloper?text=$pesan');

    try {
      final berhasil = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (berhasil) {
        _deskripsiCtrl.clear();
      } else {
        Get.snackbar('Gagal', 'Tidak bisa membuka WhatsApp', snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar('Gagal', 'WhatsApp tidak ditemukan di perangkat ini', snackPosition: SnackPosition.TOP);
    }
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
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  ),
                  const Text(
                    'Bantuan & FAQ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pertanyaan yang Sering Diajukan',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Cari tahu solusi cepat untuk masalah umum di bawah ini.',
                      style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 14),
                    ..._faqList.map((faq) => _FaqTile(question: faq['q']!, answer: faq['a']!)),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF25D366).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.support_agent, color: Color(0xFF25D366)),
                              SizedBox(width: 8),
                              Text(
                                'Masih Ada Kendala?',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Jika mengalami bug, error, atau masalah lain pada aplikasi yang belum terjawab di FAQ, silakan hubungi Developer langsung melalui WhatsApp.',
                            style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _openDeskripsiDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: const Icon(Icons.chat, color: Colors.white),
                              label: const Text(
                                'Hubungi Developer via WhatsApp',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textGrey,
          title: Text(
            question,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}