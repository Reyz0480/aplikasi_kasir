import 'package:get/get.dart';
import '../database/db_helper.dart';

class ProductRepoController extends GetxController {
  final products = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  Future<void> reload() async {
    isLoading.value = true;
    products.value = await DBHelper.instance.getAllProducts();
    isLoading.value = false;
  }
}