import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme/app_colors.dart';
import 'routes/app_routes.dart';
import 'controllers/cart_controller.dart';
import 'controllers/product_repo_controller.dart';
import 'modules/login/login_screen.dart';
import 'modules/dashboard/dashboard_screen.dart';
import 'modules/dashboard/dashboard_controller.dart';
import 'modules/settings/settings_screen.dart';
import 'modules/settings/settings_controller.dart';
import 'modules/product/tambah_produk_screen.dart';
import 'modules/product/product_screen.dart';
import 'modules/product/product_controller.dart';
import 'modules/pesanan/pesanan_screen.dart';
import 'modules/pesanan/pesanan_controller.dart';
import 'modules/pembayaran/pembayaran_screen.dart';
import 'modules/struk/struk_screen.dart';
import 'modules/riwayat/riwayat_screen.dart';
import 'modules/riwayat/riwayat_controller.dart';
import 'modules/product/atur_stok_screen.dart';
import 'modules/settings/statistik_screen.dart';
import 'modules/splash/splash_screen.dart';
import 'modules/settings/tentang_aplikasi_screen.dart';
import 'modules/settings/bantuan_faq_screen.dart';
   // tambahkan import

void main() {
  Get.put(ProductRepoController(), permanent: true);   // <-- daftarkan pertama, karena yang lain butuh ini
  Get.put(CartController(), permanent: true);
  Get.put(ProductController(), permanent: true);
  Get.put(PesananController(), permanent: true);
  Get.put(DashboardController(), permanent: true);
  Get.put(SettingsController(), permanent: true);
  Get.put(RiwayatController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Doyan Jajan.id',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      getPages: [
  GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
  GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
  GetPage(name: AppRoutes.dashboard, page: () => const DashboardScreen()),
  GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
  GetPage(name: AppRoutes.tambahProduk, page: () => const TambahProdukScreen()),
  GetPage(name: AppRoutes.product, page: () => const ProductScreen()),
  GetPage(name: AppRoutes.pesanan, page: () => const PesananScreen()),
  GetPage(name: AppRoutes.pembayaran, page: () => const PembayaranScreen()),
  GetPage(name: AppRoutes.struk, page: () => const StrukScreen()),
  GetPage(name: AppRoutes.riwayat, page: () => const RiwayatScreen()),
  GetPage(name: AppRoutes.aturStok, page: () => const AturStokScreen()),
  GetPage(name: AppRoutes.statistik, page: () => const StatistikScreen()),
  GetPage(name: AppRoutes.tentangAplikasi, page: () => const TentangAplikasiScreen()),
  GetPage(name: AppRoutes.bantuanFaq, page: () => const BantuanFaqScreen()),   // <-- pastikan baris ini ADA
],
    );
  }
}