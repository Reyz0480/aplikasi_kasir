class QrisHelper {
  /// Menyisipkan nominal ke QRIS statis, mengembalikan string QRIS dinamis
  /// yang siap digambar jadi kode QR.
  static String setAmount(String staticQris, int amount) {
    String qris = staticQris.trim();

    // Buang CRC lama (4 karakter kode "63" + panjang "04" + 4 karakter checksum = 8 karakter terakhir)
    if (qris.length < 8) {
      throw Exception('QRIS tidak valid atau terlalu pendek');
    }
    qris = qris.substring(0, qris.length - 8);

    // Ubah Point of Initiation Method dari statis ("010211") ke dinamis ("010212")
    if (qris.contains('010211')) {
      qris = qris.replaceFirst('010211', '010212');
    } else if (!qris.contains('010212')) {
      throw Exception('Format QRIS tidak dikenali (tag 01 tidak ditemukan)');
    }

    // Siapkan tag 54 (Transaction Amount)
    final amountStr = amount.toString();
    final tag54 = '54${amountStr.length.toString().padLeft(2, '0')}$amountStr';

    // Cari tag negara "5802ID" sebagai titik sisip (tag 54 harus sebelum tag 58)
    final idxCountry = qris.indexOf('5802ID');
    if (idxCountry == -1) {
      throw Exception('Format QRIS tidak dikenali (tag negara tidak ditemukan)');
    }

    qris = qris.substring(0, idxCountry) + tag54 + qris.substring(idxCountry);

    // Tambahkan header CRC "6304", lalu hitung checksum dari seluruh string
    final withCrcHeader = '${qris}6304';
    final crc = _crc16(withCrcHeader);

    return '$withCrcHeader$crc';
  }

  static String _crc16(String data) {
    int crc = 0xFFFF;
    for (int i = 0; i < data.length; i++) {
      crc ^= data.codeUnitAt(i) << 8;
      for (int j = 0; j < 8; j++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}