import 'dart:async';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../controllers/product_repo_controller.dart';
import '../database/db_helper.dart';
import '../database/session.dart';
import '../data/qris_repo.dart';
import '../utils/qris_helper.dart';


class PembayaranController extends GetxController {
  late final CartController cart;
  late final ProductRepoController repo;

  final metode = 'Tunai'.obs;
  final uangDiterima = 0.obs;
  final isProcessing = false.obs;
  final qrisPayload = Rxn<String>();
  final qrisError = ''.obs;
  final qrisSisaDetik = (5 * 60).obs; // 5 menit
  Timer? _qrisTimer;

  late final String orderNumber;

  @override
  void onInit() {
    super.onInit();
    cart = Get.find<CartController>();
    repo = Get.find<ProductRepoController>();
    orderNumber = 'DJ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    _loadQris();
  }

  Future<void> _loadQris() async {
  final staticQris = await QrisRepo.getStaticString();
  if (staticQris == null) {
    qrisError.value = 'QRIS belum diatur. Atur dulu di Settings > Atur QRIS Toko.';
    return;
  }
  try {
    qrisPayload.value = QrisHelper.setAmount(staticQris, total.toInt());
  } catch (e) {
    qrisError.value = 'QRIS gagal diproses: $e';
  }
}

  double get total => cart.totalHarga;

  double get kembalian {
    final sisa = uangDiterima.value - total;
    return sisa > 0 ? sisa : 0;
  }

  bool get isTunaiCukup => uangDiterima.value >= total;

  void gantiMetode(String m) {
    metode.value = m;
    if (m == 'QRIS') {
      _startQrisTimer();
    } else {
      _qrisTimer?.cancel();
    }
  }

  void _startQrisTimer() {
    qrisSisaDetik.value = 5 * 60;
    _qrisTimer?.cancel();
    _qrisTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (qrisSisaDetik.value <= 0) {
        timer.cancel();
      } else {
        qrisSisaDetik.value--;
      }
    });
  }

  String get qrisWaktuFormatted {
    final m = qrisSisaDetik.value ~/ 60;
    final s = qrisSisaDetik.value % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  bool get qrisExpired => qrisSisaDetik.value <= 0;

  void inputDigit(String digit) {
    if (uangDiterima.value > 99999999) return;
    uangDiterima.value = uangDiterima.value * 10 + int.parse(digit);
  }

  void backspace() {
    uangDiterima.value = uangDiterima.value ~/ 10;
  }

  void clearInput() {
    uangDiterima.value = 0;
  }

  void tambahNominal(int nominal) {
    uangDiterima.value += nominal;
  }

  Future<int?> konfirmasiBayar() async {
  if (metode.value == 'Tunai' && !isTunaiCukup) return null;
  if (metode.value == 'QRIS' && qrisExpired) return null;

  isProcessing.value = true;

  final itemsIncluded = cart.items.values.where((i) => i.included).toList();
  final items = itemsIncluded
      .map((item) => {
            'productId': item.productId,
            'nama': item.nama,
            'qty': item.qty,
            'harga': item.harga,
            'subtotal': item.subtotal,
          })
      .toList();

  final transactionId = await DBHelper.instance.insertTransaction(
    {
      'kodeTransaksi': orderNumber,
      'kasirNama': Session.nama,
      'subtotal': total,
      'total': total,
      'metodePembayaran': metode.value,
      'uangDiterima': metode.value == 'Tunai' ? uangDiterima.value.toDouble() : total,
      'kembalian': metode.value == 'Tunai' ? kembalian : 0,
      'createdAt': DateTime.now().toIso8601String(),
    },
    items,
  );

  cart.clear();
  await repo.reload();

  isProcessing.value = false;
  return transactionId;
}

  @override
  void onClose() {
    _qrisTimer?.cancel();
    super.onClose();
  }
}