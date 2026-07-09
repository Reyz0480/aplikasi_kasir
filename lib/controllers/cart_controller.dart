import 'package:get/get.dart';
import '../data/models/cart_item.dart';

class CartController extends GetxController {
  final items = <int, CartItem>{}.obs;

  void addItem({
    required int productId,
    required String nama,
    required double harga,
    required String? fotoPath,
    required int maxStok,
  }) {
    if (items.containsKey(productId)) {
      final current = items[productId]!;
      if (current.qty < maxStok) {
        current.qty++;
        items.refresh();
      }
    } else {
      if (maxStok > 0) {
        items[productId] = CartItem(
          productId: productId,
          nama: nama,
          harga: harga,
          fotoPath: fotoPath,
        );
      }
    }
  }

  void removeItem(int productId) {
    if (!items.containsKey(productId)) return;
    final current = items[productId]!;
    if (current.qty > 1) {
      current.qty--;
      items.refresh();
    } else {
      items.remove(productId);
    }
  }

  void toggleIncluded(int productId) {
    final current = items[productId];
    if (current == null) return;
    current.included = !current.included;
    items.refresh();
  }

  int qtyOf(int productId) => items[productId]?.qty ?? 0;

  bool isIncluded(int productId) => items[productId]?.included ?? true;

  int get totalItemCount =>
      items.values.where((i) => i.included).fold(0, (sum, item) => sum + item.qty);

  double get totalHarga =>
      items.values.where((i) => i.included).fold(0.0, (sum, item) => sum + item.subtotal);

  void clear() {
  items.value = {};
}
}