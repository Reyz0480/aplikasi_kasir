import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import 'login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void _showLupaSandiDialog(BuildContext context, LoginController controller) {
  Get.dialog(
    AlertDialog(
      title: const Text('Lupa Sandi'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Isi data berikut untuk verifikasi. Pesan akan dikirim ke Developer via WhatsApp.',
              style: TextStyle(fontSize: 13, color: AppColors.textGrey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.lupaNamaCtrl,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.lupaUsernameCtrl,
              decoration: InputDecoration(
                labelText: 'Username yang lupa sandinya',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.lupaKeteranganCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Keterangan (opsional)',
                hintText: 'Contoh: ingin ganti sandi baru',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
        ElevatedButton.icon(
          onPressed: () async {
            await controller.kirimLupaSandi();
            Get.back();
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
          icon: const Icon(Icons.chat, color: Colors.white, size: 18),
          label: const Text('Kirim via WhatsApp', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
    final controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 0),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
  'lib/img/doyanjajan.jpeg',   // <-- ganti ini
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) => const Icon(
    Icons.storefront,
    size: 80,
    color: AppColors.primary,
  ),
),
              ),

              const SizedBox(height: 24),

              const Text(
                'Doyan\nJajan.id',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Sistem Kasir Untuk Jajanan Nagih',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Username',
                      style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: controller.usernameCtrl,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Masukkan username',
                        prefixIcon: const Icon(Icons.person_outline, color: AppColors.textGrey),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.accent),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Kata Sandi',
                      style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 6),
                    Obx(
                      () => TextField(
                        controller: controller.passwordCtrl,
                        obscureText: controller.isPasswordHidden.value,
                        decoration: InputDecoration(
                          hintText: 'Masukkan kata sandi',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textGrey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordHidden.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textGrey,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.borderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.borderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.accent),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => Row(
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: controller.rememberMe.value,
                                  activeColor: AppColors.accent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  onChanged: (val) {
                                    controller.rememberMe.value = val ?? false;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Ingat Saya',
                                style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
  onTap: () => _showLupaSandiDialog(context, controller),
  child: const Text(
    'Lupa Sandi?',
    style: TextStyle(
      fontSize: 13,
      color: AppColors.accent,
      fontWeight: FontWeight.w600,
    ),
  ),
),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.4,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Masuk Sekarang',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                  ],
                                ),
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
    );
  }
}