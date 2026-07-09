import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../database/db_helper.dart';
import '../../controllers/product_repo_controller.dart';

class TambahProdukController extends GetxController {
  final namaCtrl = TextEditingController();
  final hargaJualCtrl = TextEditingController();
  final hargaModalCtrl = TextEditingController();

  final kategori = 'Makanan'.obs;
  final stok = 0.obs;
  final statusAktif = true.obs;
  final fotoPath = Rxn<String>();
  final isSaving = false.obs;

  final kategoriList = ['Makanan', 'Minuman', 'Snack', 'Promo'];

  Future<void> pilihFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final ext = p.extension(picked.path);
    final fileName = 'produk_${DateTime.now().millisecondsSinceEpoch}$ext';
    final savedImage = await File(picked.path).copy('${appDir.path}/$fileName');

    fotoPath.value = savedImage.path;
  }

  void tambahStok() => stok.value++;
  void kurangiStok() {
    if (stok.value > 0) stok.value--;
  }

   Future<bool> simpanProduk() async {
    if (namaCtrl.text.trim().isEmpty) {
      Get.snackbar('Gagal', 'Nama produk wajib diisi', snackPosition: SnackPosition.TOP);
      return false;
    }
    final hargaJual = double.tryParse(hargaJualCtrl.text.trim()) ?? 0;
    final hargaModal = double.tryParse(hargaModalCtrl.text.trim()) ?? 0;

    if (hargaJual <= 0) {
      Get.snackbar('Gagal', 'Harga jual harus lebih dari 0', snackPosition: SnackPosition.TOP);
      return false;
    }

    isSaving.value = true;

    await DBHelper.instance.insertProduct({
      'nama': namaCtrl.text.trim(),
      'kategori': kategori.value,
      'hargaJual': hargaJual,
      'hargaModal': hargaModal,
      'stok': stok.value,
      'fotoPath': fotoPath.value,
      'aktif': statusAktif.value ? 1 : 0,
      'createdAt': DateTime.now().toIso8601String(),
    });

    isSaving.value = false;

    await Get.find<ProductRepoController>().reload(); // <-- BARIS PENTING INI

    return true;
  }


  @override
  void onClose() {
    namaCtrl.dispose();
    hargaJualCtrl.dispose();
    hargaModalCtrl.dispose();
    super.onClose();
  }
}