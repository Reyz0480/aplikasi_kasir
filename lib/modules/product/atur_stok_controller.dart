import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../database/db_helper.dart';
import '../../controllers/product_repo_controller.dart';
import 'package:flutter/material.dart';

class AturStokController extends GetxController {
  late final ProductRepoController repo;

  @override
  void onInit() {
    super.onInit();
    repo = Get.find<ProductRepoController>();
  }

  Future<void> tambahStok(int productId, int stokSekarang) async {
    final stokBaru = stokSekarang + 1;
    await DBHelper.instance.updateStok(productId, stokBaru);
    await repo.reload();
  }

  Future<void> kurangiStok(int productId, int stokSekarang) async {
    if (stokSekarang <= 0) return;
    final stokBaru = stokSekarang - 1;
    await DBHelper.instance.updateStok(productId, stokBaru);
    await repo.reload();
  }

  Future<void> hapusProduk(int productId) async {
    await DBHelper.instance.deleteProduct(productId);
    await repo.reload();
  }

  Future<void> ubahFoto(int productId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final ext = p.extension(picked.path);
    final fileName = 'produk_${DateTime.now().millisecondsSinceEpoch}$ext';
    final savedImage = await File(picked.path).copy('${appDir.path}/$fileName');

    await DBHelper.instance.updateFotoProduk(productId, savedImage.path);
    await repo.reload();
  }

  Future<void> ubahHarga(int productId, String hargaBaruStr) async {
    final hargaBaru = double.tryParse(hargaBaruStr.trim());
    if (hargaBaru == null || hargaBaru <= 0) {
      Get.snackbar('Gagal', 'Harga tidak valid', snackPosition: SnackPosition.TOP);
      return;
    }
    await DBHelper.instance.updateHargaJual(productId, hargaBaru);
    await repo.reload();
    Get.snackbar('Berhasil', 'Harga berhasil diperbarui',
        snackPosition: SnackPosition.TOP, backgroundColor: const Color(0xFFC8E6C9));
  }
}