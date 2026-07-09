import 'package:shared_preferences/shared_preferences.dart';

class QrisRepo {
  static const _key = 'qris_static_string';

  static Future<String?> getStaticString() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> saveStaticString(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value);
  }
}