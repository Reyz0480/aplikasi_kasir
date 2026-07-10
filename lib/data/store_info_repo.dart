import 'package:shared_preferences/shared_preferences.dart';

class StoreInfoRepo {
  static const _kNama = 'store_nama';
  static const _kAlamat = 'store_alamat';
  static const _kTelepon = 'store_telepon';
  static const _kInstagram = 'store_instagram';

  static Future<Map<String, String>> getInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'nama': prefs.getString(_kNama) ?? 'DOYAN JAJAN.ID',
      'alamat': prefs.getString(_kAlamat) ?? 'Jl. Sudirman Gg. Dempet Cinta Rakyat\nPercut Sei Tuan, Medan',
      'telepon': prefs.getString(_kTelepon) ?? '0852-6199-6113',
      'instagram': prefs.getString(_kInstagram) ?? '@doyanjajan.id',
    };
  }

  static Future<void> saveInfo({
    required String nama,
    required String alamat,
    required String telepon,
    required String instagram,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNama, nama);
    await prefs.setString(_kAlamat, alamat);
    await prefs.setString(_kTelepon, telepon);
    await prefs.setString(_kInstagram, instagram);
  }
}