import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../models/product.dart';
import '../models/transaction.dart';

class StorageService {
  // ================= PRODUCT =================
  static Future<String> _getProductsFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/products.json';
  }

  static Future<List<Product>> loadProducts() async {
    try {
      final path = await _getProductsFilePath();
      if (!File(path).existsSync()) return [];
      final data = await File(path).readAsString();
      final list = jsonDecode(data) as List;
      return list.map((e) => Product.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveProducts(List<Product> products) async {
    final path = await _getProductsFilePath();
    final data = jsonEncode(products.map((e) => e.toJson()).toList());
    await File(path).writeAsString(data);
  }

  // ================= CATEGORY =================
  static Future<String> _getCategoriesFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/categories.json';
  }

  static Future<List<String>> loadCategories() async {
    try {
      final path = await _getCategoriesFilePath();
      if (!File(path).existsSync()) return [];
      final data = await File(path).readAsString();
      return (jsonDecode(data) as List).map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCategories(List<String> categories) async {
    final path = await _getCategoriesFilePath();
    await File(path).writeAsString(jsonEncode(categories));
  }

  // ================= TRANSACTION =================
  static Future<String> _getTransactionsFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/transactions.json';
  }

  static Future<List<TransactionModel>> loadTransactions() async {
    try {
      final path = await _getTransactionsFilePath();
      if (!File(path).existsSync()) return [];
      final data = await File(path).readAsString();
      final list = jsonDecode(data) as List;
      return list
          .map((e) => TransactionModel.fromJson(e))
          .toList()
          .reversed
          .toList(); // terbaru di atas
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveTransaction(TransactionModel trx) async {
    final path = await _getTransactionsFilePath();
    List<TransactionModel> list = await loadTransactions();
    list.add(trx);

    final data = jsonEncode(list.map((e) => e.toJson()).toList());
    await File(path).writeAsString(data);
  }
}
