import 'package:get/get.dart';

class Session {
  static final currentUser = Rxn<Map<String, dynamic>>();

  static void setUser(Map<String, dynamic> user) {
    currentUser.value = user;
  }

  static void clear() {
    currentUser.value = null;
  }

  static String get nama => currentUser.value?['nama'] ?? 'Kasir';
  static String get role => currentUser.value?['role'] ?? '';
  static int get userId => currentUser.value?['id'] ?? 0;
}