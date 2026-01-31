import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../models/product.dart';
import '../services/storage_service.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Product> products = [];
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  String imagePath = '';

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    products = await StorageService.loadProducts();
    setState(() {});
  }

  Future<String> saveImage(XFile image) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = basename(image.path);
    final savedImage =
        await File(image.path).copy('${dir.path}/$fileName');
    return savedImage.path;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      imagePath = await saveImage(image);
      setState(() {});
    }
  }

  void addProduct() async {
    if (nameCtrl.text.isEmpty ||
        priceCtrl.text.isEmpty ||
        imagePath.isEmpty) return;

    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameCtrl.text,
      price: int.parse(priceCtrl.text),
      imagePath: imagePath,
    );

    products.add(product);
    await StorageService.saveProducts(products);

    nameCtrl.clear();
    priceCtrl.clear();
    imagePath = '';
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kasir - Produk')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Produk'),
                ),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Harga'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: pickImage,
                      child: const Text('Ambil Foto'),
                    ),
                    const SizedBox(width: 10),
                    if (imagePath.isNotEmpty)
                      Image.file(
                        File(imagePath),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: addProduct,
                  child: const Text('Tambah Produk'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, i) {
                final p = products[i];
                return ListTile(
                  leading: Image.file(
                    File(p.imagePath),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(p.name),
                  subtitle: Text('Rp ${p.price}'),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
