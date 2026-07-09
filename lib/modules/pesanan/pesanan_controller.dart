import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_repo_controller.dart';

class PesananController extends GetxController {
  late final CartController cart;
  late final ProductRepoController repo;

  @override
  void onInit() {
    super.onInit();
    cart = Get.find<CartController>();
    repo = Get.find<ProductRepoController>();
  }
}