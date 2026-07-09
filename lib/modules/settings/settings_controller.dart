import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../database/session.dart';
import '../../data/qris_repo.dart';
import '../../data/profile_photo_repo.dart';
import '../../utils/qris_helper.dart';
import '../../routes/app_routes.dart';

class SettingsController extends GetxController {
  final qrisStringCtrl = TextEditingController();
  final qrisTersimpan = false.obs;
  final profileFotoPath = Rxn<String>();

  String get nama => Session.nama;
  String get role => Session.role;

  @override
  void onInit() {
    super.onInit();
    _loadQris();
    _loadProfileFoto();
  }

  Future<void> _loadQris() async {
    final saved = await QrisRepo.getStaticString();
    if (saved != null) {
      qrisStringCtrl.text = saved;
      qrisTersimpan.value = true;
    }
  }

  Future<void> _loadProfileFoto() async {
    profileFotoPath.value = await ProfilePhotoRepo.getPath();
  }

  Future<void> pilihFotoProfil() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final ext = p.extension(picked.path);
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}$ext';
    final savedImage = await File(picked.path).copy('${appDir.path}/$fileName');

    await ProfilePhotoRepo.savePath(savedImage.path);
    profileFotoPath.value = savedImage.path;

    Get.snackbar('Berhasil', 'Foto profil berhasil diperbarui',
        snackPosition: SnackPosition.TOP, backgroundColor: Colors.green.shade100);
  }

  // Sekarang mengembalikan bool: true kalau berhasil disimpan, false kalau validasi gagal
  Future<bool> simpanQris() async {
    final input = qrisStringCtrl.text.trim();
    if (input.isEmpty) {
      Get.snackbar('Gagal', 'Teks QRIS tidak boleh kosong', snackPosition: SnackPosition.TOP);
      return false;
    }

    try {
      QrisHelper.setAmount(input, 1000);
    } catch (e) {
      Get.snackbar('Format Salah', 'Teks QRIS tidak valid: $e',
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.red.shade100);
      return false;
    }

    await QrisRepo.saveStaticString(input);
    qrisTersimpan.value = true;
    Get.snackbar('Berhasil', 'QRIS berhasil disimpan',
        snackPosition: SnackPosition.TOP, backgroundColor: Colors.green.shade100);
    return true;
  }

  void logout() {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Yakin ingin keluar dari akun ini?',
      textConfirm: 'Ya, Logout',
      textCancel: 'Batal',
      confirmTextColor: const Color(0xFFFFFFFF),
      onConfirm: () {
        Session.clear();
        Get.offAllNamed(AppRoutes.login);
      },
    );
  }

  @override
  void onClose() {
    qrisStringCtrl.dispose();
    super.onClose();
  }
}