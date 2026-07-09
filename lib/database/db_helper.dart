import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:collection/collection.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'doyan_jajan.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel users (kasir)
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        nama TEXT NOT NULL,
        role TEXT NOT NULL,
        fotoPath TEXT
      )
    ''');

    // Tabel products
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        kategori TEXT NOT NULL,
        hargaJual REAL NOT NULL,
        hargaModal REAL NOT NULL,
        stok INTEGER NOT NULL DEFAULT 0,
        fotoPath TEXT,
        aktif INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL
      )
    ''');

    // Tabel transactions
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kodeTransaksi TEXT NOT NULL,
        kasirNama TEXT NOT NULL,
        subtotal REAL NOT NULL,
        total REAL NOT NULL,
        metodePembayaran TEXT NOT NULL,
        uangDiterima REAL NOT NULL,
        kembalian REAL NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Tabel transaction_items (detail item per transaksi)
    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transactionId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        nama TEXT NOT NULL,
        qty INTEGER NOT NULL,
        harga REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (transactionId) REFERENCES transactions (id),
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');

    // Seed 1 akun kasir default: username "admin", password "admin123"
    await db.insert('users', {
      'username': 'admin',
      'password': _hashPassword('admin123'),
      'nama': 'Doyan',
      'role': 'Kasir Utama',
      'fotoPath': null,
    });
  }

  static String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // ---------- AUTH ----------

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final db = await database;
    final hashed = _hashPassword(password);
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashed],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> changePassword(int userId, String newPassword) async {
    final db = await database;
    await db.update(
      'users',
      {'password': _hashPassword(newPassword)},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // ---------- PRODUCTS ----------

  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    return await db.insert('products', product);
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await database;
    return await db.query('products', orderBy: 'nama ASC');
  }

  Future<List<Map<String, dynamic>>> getActiveProducts() async {
    final db = await database;
    return await db.query('products', where: 'aktif = 1', orderBy: 'nama ASC');
  }

  Future<int> updateProduct(int id, Map<String, dynamic> product) async {
    final db = await database;
    return await db.update('products', product, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateStok(int productId, int stokBaru) async {
    final db = await database;
    return await db.update(
      'products',
      {'stok': stokBaru},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- TRANSACTIONS ----------

  Future<int> insertTransaction(
    Map<String, dynamic> transaction,
    List<Map<String, dynamic>> items,
  ) async {
    final db = await database;
    return await db.transaction((txn) async {
      final transactionId = await txn.insert('transactions', transaction);

      for (final item in items) {
        await txn.insert('transaction_items', {
          ...item,
          'transactionId': transactionId,
        });

        // kurangi stok otomatis
        final produkRows = await txn.query(
          'products',
          where: 'id = ?',
          whereArgs: [item['productId']],
        );
        if (produkRows.isNotEmpty) {
          final stokSekarang = produkRows.first['stok'] as int;
          await txn.update(
            'products',
            {'stok': stokSekarang - (item['qty'] as int)},
            where: 'id = ?',
            whereArgs: [item['productId']],
          );
        }
      }

      return transactionId;
    });
  }

  Future<List<Map<String, dynamic>>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    return await db.query(
      'transactions',
      where: 'createdAt >= ? AND createdAt < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'createdAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    return await db.query('transactions', orderBy: 'createdAt DESC');
  }

  Future<List<Map<String, dynamic>>> getItemsByTransactionId(int transactionId) async {
    final db = await database;
    return await db.query(
      'transaction_items',
      where: 'transactionId = ?',
      whereArgs: [transactionId],
    );
  }


// ---------- DASHBOARD HELPERS ----------

  Future<List<Map<String, dynamic>>> getItemsBetweenDates(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT ti.*, t.createdAt
      FROM transaction_items ti
      INNER JOIN transactions t ON t.id = ti.transactionId
      WHERE t.createdAt >= ? AND t.createdAt < ?
    ''', [start.toIso8601String(), end.toIso8601String()]);
  }

Future<Map<String, dynamic>> getStatistikBulanan(DateTime bulan) async {
    final db = await database;
    final start = DateTime(bulan.year, bulan.month, 1);
    final end = DateTime(bulan.year, bulan.month + 1, 1);

    final trx = await db.query(
      'transactions',
      where: 'createdAt >= ? AND createdAt < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );

    final items = await getItemsBetweenDates(start, end);
    final allProducts = await getAllProducts();

    final totalPenjualan = trx.fold(0.0, (sum, t) => sum + (t['total'] as num));

    double totalModal = 0;
    for (final item in items) {
      final produk = allProducts.firstWhereOrNull((p) => p['id'] == item['productId']);
      if (produk != null) {
        totalModal += (produk['hargaModal'] as num) * (item['qty'] as int);
      }
    }

    return {
      'totalPenjualan': totalPenjualan,
      'totalKeuntungan': totalPenjualan - totalModal,
      'totalModal': totalModal,
    };
  }


Future<List<Map<String, dynamic>>> getProductsByCategory(String kategori) async {
    final db = await database;
    if (kategori == 'Semua') {
      return await db.query('products', where: 'aktif = 1', orderBy: 'nama ASC');
    }
    return await db.query(
      'products',
      where: 'aktif = 1 AND kategori = ?',
      whereArgs: [kategori],
      orderBy: 'nama ASC',
    );
  }

  Future<List<Map<String, dynamic>>> searchProducts(String keyword) async {
    final db = await database;
    return await db.query(
      'products',
      where: 'aktif = 1 AND nama LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'nama ASC',
    );
  }

  Future<int> toggleProductAktif(int id, bool aktif) async {
    final db = await database;
    return await db.update(
      'products',
      {'aktif': aktif ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  Future<Map<String, dynamic>?> getTransactionById(int id) async {
    final db = await database;
    final result = await db.query('transactions', where: 'id = ?', whereArgs: [id], limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

Future<List<Map<String, dynamic>>> searchTransactions(String keyword) async {
    final db = await database;
    return await db.query(
      'transactions',
      where: 'kodeTransaksi LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'createdAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getTransactionsInMonth(DateTime bulan) async {
    final db = await database;
    final start = DateTime(bulan.year, bulan.month, 1);
    final end = DateTime(bulan.year, bulan.month + 1, 1);
    return await db.query(
      'transactions',
      where: 'createdAt >= ? AND createdAt < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'createdAt ASC',
    );
  }

  Future<int> updateFotoProduk(int id, String fotoPath) async {
    final db = await database;
    return await db.update(
      'products',
      {'fotoPath': fotoPath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateHargaJual(int id, double hargaJual) async {
    final db = await database;
    return await db.update(
      'products',
      {'hargaJual': hargaJual},
      where: 'id = ?',
      whereArgs: [id],
    );
  }


}


