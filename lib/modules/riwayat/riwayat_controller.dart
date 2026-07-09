import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../database/db_helper.dart';

class RiwayatController extends GetxController {
  final searchCtrl = TextEditingController();
  final filterHariIni = false.obs;
  final isLoading = true.obs;
  final transaksiList = <Map<String, dynamic>>[].obs;
  final expandedId = Rxn<int>();
  final itemsCache = <int, List<Map<String, dynamic>>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    searchCtrl.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (searchCtrl.text.trim().isEmpty) {
      loadData();
    } else {
      _search(searchCtrl.text.trim());
    }
  }

  Future<void> loadData() async {
    isLoading.value = true;
    if (filterHariIni.value) {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));
      transaksiList.value = await DBHelper.instance.getTransactionsByDateRange(start, end);
    } else {
      transaksiList.value = await DBHelper.instance.getAllTransactions();
    }
    isLoading.value = false;
  }

  Future<void> _search(String keyword) async {
    isLoading.value = true;
    transaksiList.value = await DBHelper.instance.searchTransactions(keyword);
    isLoading.value = false;
  }

  void setFilterHariIni(bool value) {
    filterHariIni.value = value;
    searchCtrl.clear();
    loadData();
  }

  Future<void> toggleExpand(int transactionId) async {
    if (expandedId.value == transactionId) {
      expandedId.value = null;
      return;
    }
    if (!itemsCache.containsKey(transactionId)) {
      final items = await DBHelper.instance.getItemsByTransactionId(transactionId);
      itemsCache[transactionId] = items;
    }
    expandedId.value = transactionId;
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }
}