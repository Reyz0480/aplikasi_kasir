import 'package:shared_preferences/shared_preferences.dart';

class ProfilePhotoRepo {
  static const _key = 'profile_photo_path';

  static Future<String?> getPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> savePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, path);
  }
}