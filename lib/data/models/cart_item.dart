class CartItem {
  final int productId;
  final String nama;
  final double harga;
  final String? fotoPath;
  int qty;
  bool included;

  CartItem({
    required this.productId,
    required this.nama,
    required this.harga,
    required this.fotoPath,
    this.qty = 1,
    this.included = true,
  });

  double get subtotal => harga * qty;
}