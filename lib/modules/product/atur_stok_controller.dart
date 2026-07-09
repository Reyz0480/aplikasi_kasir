import 'package:get/get.dart';
import '../../database/db_helper.dart';
import '../../controllers/product_repo_controller.dart';

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
}