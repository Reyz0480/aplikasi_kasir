import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatter.dart';
import 'atur_stok_controller.dart';

class AturStokScreen extends StatefulWidget {
  const AturStokScreen({super.key});

  @override
  State<AturStokScreen> createState() => _AturStokScreenState();
}

class _AturStokScreenState extends State<AturStokScreen> {
  late final AturStokController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(AturStokController());
  }

  @override
  void dispose() {
    Get.delete<AturStokController>();
    super.dispose();
  }

  void _konfirmasiHapus(int productId, String nama) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "$nama"? Data yang sudah dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              c.hapusProduk(productId);
              Get.back();
              Get.snackbar('Berhasil', '"$nama" telah dihapus', snackPosition: SnackPosition.TOP);
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
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
                    'Atur Stok',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(
                () {
                  if (c.repo.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.accent));
                  }
                  final products = c.repo.products;
                  if (products.isEmpty) {
                    return const Center(
                      child: Text('Belum ada produk', style: TextStyle(color: AppColors.textGrey)),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.5,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _StokCard(
                        produk: products[index],
                        controller: c,
                        onHapus: _konfirmasiHapus,
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text(
                    'Selesai',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
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

class _StokCard extends StatefulWidget {
  final Map<String, dynamic> produk;
  final AturStokController controller;
  final void Function(int productId, String nama) onHapus;

  const _StokCard({required this.produk, required this.controller, required this.onHapus});

  @override
  State<_StokCard> createState() => _StokCardState();
}

class _StokCardState extends State<_StokCard> {
  late final TextEditingController hargaCtrl;

  @override
  void initState() {
    super.initState();
    final hargaAwal = (widget.produk['hargaJual'] as num).toInt();
    hargaCtrl = TextEditingController(text: '$hargaAwal');
  }

  @override
  void didUpdateWidget(covariant _StokCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // sinkronkan textfield kalau data produk berubah dari luar (misal setelah reload)
    final hargaBaru = (widget.produk['hargaJual'] as num).toInt();
    if (hargaCtrl.text != '$hargaBaru' && !hargaCtrl.selection.isValid) {
      hargaCtrl.text = '$hargaBaru';
    }
  }

  @override
  void dispose() {
    hargaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productId = widget.produk['id'] as int;
    final nama = widget.produk['nama'] as String;
    final stok = widget.produk['stok'] as int;
    final fotoPath = widget.produk['fotoPath'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.4,
                child: fotoPath != null && fotoPath.isNotEmpty
                    ? Image.file(File(fotoPath), fit: BoxFit.cover, width: double.infinity)
                    : Container(
                        color: AppColors.background,
                        child: const Icon(Icons.fastfood, color: AppColors.borderLight, size: 36),
                      ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () => widget.controller.ubahFoto(productId),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.edit, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 6),
                const Text('Stok', style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => widget.controller.kurangiStok(productId, stok),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(color: AppColors.borderLight, shape: BoxShape.circle),
                        child: const Icon(Icons.remove, size: 14, color: AppColors.primary),
                      ),
                    ),
                    Text('$stok', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    GestureDetector(
                      onTap: () => widget.controller.tambahStok(productId, stok),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.add, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Harga Jual', style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                const SizedBox(height: 4),
                TextField(
                  controller: hargaCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    prefixText: 'Rp ',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.accent),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check_circle, size: 18, color: AppColors.success),
                      onPressed: () => widget.controller.ubahHarga(productId, hargaCtrl.text),
                    ),
                  ),
                  onSubmitted: (val) => widget.controller.ubahHarga(productId, val),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => widget.onHapus(productId, nama),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                        SizedBox(width: 4),
                        Text('Hapus', style: TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}