import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_repo_controller.dart';

class ProductController extends GetxController {
  final searchCtrl = TextEditingController();
  final selectedKategori = 'Semua'.obs;

  final kategoriList = ['Semua', 'Makanan', 'Minuman', 'Snack', 'Promo']; // <-- tambahkan baris ini

  late final CartController cart;
  late final ProductRepoController repo;

  final searchKeyword = ''.obs;

  @override
  void onInit() {
    super.onInit();
    cart = Get.find<CartController>();
    repo = Get.find<ProductRepoController>();
    searchCtrl.addListener(() => searchKeyword.value = searchCtrl.text.trim());
  }

  List<Map<String, dynamic>> get filteredProducts {
    var list = repo.products.where((p) => (p['aktif'] as int) == 1).toList();

    if (searchKeyword.value.isNotEmpty) {
      list = list
          .where((p) => (p['nama'] as String).toLowerCase().contains(searchKeyword.value.toLowerCase()))
          .toList();
    } else if (selectedKategori.value != 'Semua') {
      list = list.where((p) => p['kategori'] == selectedKategori.value).toList();
    }

    return list;
  }

  void gantiKategori(String kategori) {
    selectedKategori.value = kategori;
    searchCtrl.clear();
    searchKeyword.value = '';
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }
}