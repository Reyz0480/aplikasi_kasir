import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import 'tambah_produk_controller.dart';

class TambahProdukScreen extends StatelessWidget {
  const TambahProdukScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(TambahProdukController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
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
                  const Text(
                    'Tambah Produk',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Obx(
                () => GestureDetector(
                  onTap: c.pilihFoto,
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: c.fotoPath.value != null
                        ? Image.file(File(c.fotoPath.value!), fit: BoxFit.cover, width: double.infinity)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add_a_photo, color: Colors.white),
                              ),
                              const SizedBox(height: 10),
                              const Text('Unggah Foto Produk', style: TextStyle(fontWeight: FontWeight.w600)),
                              const Text('Rekomendasi: 1:1, Maks 2MB',
                                  style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text('Nama Produk', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: c.namaCtrl,
                decoration: _inputDecoration('Contoh: Es Teh Manis Jumbo'),
              ),

              const SizedBox(height: 18),

              const Text('Kategori', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
              const SizedBox(height: 8),
              Obx(
                () => Wrap(
                  spacing: 8,
                  children: c.kategoriList.map((k) {
                    final selected = c.kategori.value == k;
                    return ChoiceChip(
                      label: Text(k),
                      selected: selected,
                      onSelected: (_) => c.kategori.value = k,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.cardWhite,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: selected ? AppColors.primary : AppColors.borderLight),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Harga Jual', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: c.hargaJualCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: _inputDecoration('0', prefixText: 'Rp '),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Harga Modal', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: c.hargaModalCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: _inputDecoration('0', prefixText: 'Rp '),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const Text('Stok Awal', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Obx(() => Text('${c.stok.value}')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _RoundIconButton(icon: Icons.remove, onTap: c.kurangiStok),
                  const SizedBox(width: 8),
                  _RoundIconButton(icon: Icons.add, onTap: c.tambahStok),
                ],
              ),

              const SizedBox(height: 18),

              Obx(
                () => Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status Aktif', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            Text('Produk akan tampil di menu kasir',
                                style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                          ],
                        ),
                      ),
                      Switch(
                        value: c.statusAktif.value,
                        activeColor: AppColors.accent,
                        onChanged: (val) => c.statusAktif.value = val,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.lightbulb_outline, color: Color(0xFFB8860B)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tips Cepat: Gunakan foto asli dengan pencahayaan terang untuk menarik minat pembeli.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: c.isSaving.value
                        ? null
                        : () async {
                            final berhasil = await c.simpanProduk();
                            if (berhasil) {
                              Get.back();
                              Get.snackbar(
                                'Berhasil',
                                'Produk berhasil disimpan',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.green.shade100,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: c.isSaving.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.save, color: Colors.white),
                    label: const Text('Simpan Produk',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {String? prefixText}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      filled: true,
      fillColor: AppColors.cardWhite,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}