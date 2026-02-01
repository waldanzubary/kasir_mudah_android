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

  // Preload kategori default
  static Future<void> initDefaultCategories() async {
    final path = await _getCategoriesFilePath();
    final file = File(path);

    if (!file.existsSync()) {
      await saveCategories([
        "Makanan",
        "Minuman",
        "Snack",
        
      ]);
    }
  }

  static Future<List<String>> loadCategories() async {
    try {
      final path = await _getCategoriesFilePath();
      if (!File(path).existsSync()) {
        // Kalau belum ada, langsung preload
        await initDefaultCategories();
      }
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

// ================= BACKUP & RESTORE =================
static Future<Map<String, dynamic>> getAllData() async {
  final products = await loadProducts();
  
  // Konversi produk ke format yang menyertakan data gambar (Base64)
  List<Map<String, dynamic>> productsWithImages = [];
  
  for (var p in products) {
    String? base64Image;
    if (p.imagePath != null && File(p.imagePath!).existsSync()) {
      // Baca file gambar dan ubah jadi Base64
      List<int> imageBytes = await File(p.imagePath!).readAsBytes();
      base64Image = base64Encode(imageBytes);
    }
    
    var json = p.toJson();
    json['image_data_base64'] = base64Image; // Sisipkan data gambar aslinya
    productsWithImages.add(json);
  }

  return {
    "products": productsWithImages,
    "categories": await loadCategories(),
    "transactions": (await loadTransactions()).map((e) => e.toJson()).toList(),
    "backup_date": DateTime.now().toIso8601String(),
  };
}

  static Future<void> restoreAllData(Map<String, dynamic> data) async {
  final dir = await getApplicationDocumentsDirectory();

  // 1. Restore Products & Images
  if (data.containsKey('products')) {
    final List list = data['products'];
    List<Product> restoredProducts = [];

    for (var item in list) {
      String? newPath;
      
      // Jika ada data gambar Base64, tulis ulang ke memori HP
      if (item['image_data_base64'] != null) {
        String base64Str = item['image_data_base64'];
        List<int> bytes = base64Decode(base64Str);
        
        // Buat nama file unik agar tidak bentrok
        String fileName = 'img_${DateTime.now().microsecondsSinceEpoch}.jpg';
        File imgFile = File('${dir.path}/$fileName');
        await imgFile.writeAsBytes(bytes);
        newPath = imgFile.path;
      }

      // Buat objek produk dengan path gambar yang baru
      var p = Product.fromJson(item);
      restoredProducts.add(Product(
        id: p.id,
        name: p.name,
        price: p.price,
        category: p.category,
        barcode: p.barcode,
        imagePath: newPath ?? p.imagePath, // Gunakan path baru jika berhasil di-restore
      ));
    }
    await saveProducts(restoredProducts);
  }

  // 2. Restore Categories (Sama seperti sebelumnya)
  if (data.containsKey('categories')) {
    await saveCategories(List<String>.from(data['categories']));
  }

  // 3. Restore Transactions (Sama seperti sebelumnya)
  if (data.containsKey('transactions')) {
    final List trxList = data['transactions'];
    final transactions = trxList.map((e) => TransactionModel.fromJson(e)).toList();
    final path = await _getTransactionsFilePath();
    await File(path).writeAsString(jsonEncode(transactions.map((e) => e.toJson()).toList()));
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
