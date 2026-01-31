import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';

class StorageService {
  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/products.json');
  }

  static Future<List<Product>> loadProducts() async {
    final file = await _getFile();
    if (!await file.exists()) return [];

    final content = await file.readAsString();
    final List data = jsonDecode(content);
    return data.map((e) => Product.fromJson(e)).toList();
  }

  static Future<void> saveProducts(List<Product> products) async {
    final file = await _getFile();
    final jsonData = products.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonData));
  }
}
