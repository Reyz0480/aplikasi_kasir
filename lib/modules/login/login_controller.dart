import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../database/db_helper.dart';
import '../../database/session.dart';
import '../../routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginController extends GetxController {
final lupaNamaCtrl = TextEditingController();
final lupaUsernameCtrl = TextEditingController();
final lupaKeteranganCtrl = TextEditingController();

Future<void> kirimLupaSandi() async {
  final nama = lupaNamaCtrl.text.trim();
  final username = lupaUsernameCtrl.text.trim();
  final keterangan = lupaKeteranganCtrl.text.trim();

  if (nama.isEmpty || username.isEmpty) {
    Get.snackbar('Gagal', 'Nama dan username wajib diisi', snackPosition: SnackPosition.TOP);
    return;
  }

  const nomorDeveloper = '6281362685887'; // format internasional tanpa + atau 0 di depan

  final pesan = Uri.encodeComponent(
    'Halo, saya ingin melaporkan lupa sandi / minta ganti sandi untuk aplikasi Doyan Jajan.id.\n\n'
    'Nama: $nama\n'
    'Username: $username\n'
    '${keterangan.isNotEmpty ? 'Keterangan: $keterangan\n' : ''}'
    '\nMohon bantuannya untuk reset/ganti sandi. Terima kasih.',
  );

  final url = Uri.parse('https://wa.me/$nomorDeveloper?text=$pesan');

try {
  final berhasil = await launchUrl(url, mode: LaunchMode.externalApplication);
  if (berhasil) {
    lupaNamaCtrl.clear();
    lupaUsernameCtrl.clear();
    lupaKeteranganCtrl.clear();
  } else {
    Get.snackbar('Gagal', 'Tidak bisa membuka WhatsApp', snackPosition: SnackPosition.TOP);
  }
} catch (e) {
  Get.snackbar('Gagal', 'WhatsApp tidak ditemukan di perangkat ini', snackPosition: SnackPosition.TOP);
}
}


  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  final isPasswordHidden = true.obs;
  final isLoading = false.obs;
  final rememberMe = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    final username = usernameCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Username dan kata sandi wajib diisi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    isLoading.value = true;

    final user = await DBHelper.instance.login(username, password);

    isLoading.value = false;

    if (user == null) {
      Get.snackbar(
        'Gagal Masuk',
        'Username atau kata sandi salah',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    Session.setUser(user);
    Get.offAllNamed(AppRoutes.dashboard);
  }


  Future<void> hubungiDeveloperDaftarAkun() async {
  const nomorDeveloper = '6281362685887';
  final pesan = Uri.encodeComponent(
    'Halo, saya ingin mendaftar akun kasir baru untuk aplikasi Doyan Jajan.id. Mohon bantuannya untuk pembuatan akun. Terima kasih.',
  );
  final url = Uri.parse('https://wa.me/$nomorDeveloper?text=$pesan');

  try {
    final berhasil = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!berhasil) {
      Get.snackbar('Gagal', 'Tidak bisa membuka WhatsApp', snackPosition: SnackPosition.TOP);
    }
  } catch (e) {
    Get.snackbar('Gagal', 'WhatsApp tidak ditemukan di perangkat ini', snackPosition: SnackPosition.TOP);
  }
}

  @override
  void onClose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    lupaNamaCtrl.dispose();       // <-- tambahkan
  lupaUsernameCtrl.dispose();   // <-- tambahkan
  lupaKeteranganCtrl.dispose(); // <-- tambahkan
    super.onClose();
  }
}