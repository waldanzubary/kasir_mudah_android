import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/product.dart';
import '../services/storage_service.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Product> products = [];
  List<String> categories = [];
  
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController categoryCtrl = TextEditingController();

  String imagePath = '';
  String scannedBarcode = '';
  String selectedCategory = '';
  String filterCategory = '';
  bool isScanning = false;

  // Modern Color Palette (Sesuai preferensi UI Anda)
  final Color primaryColor = const Color(0xFF00AA5B); 
  final Color surfaceColor = const Color(0xFFFFFFFF);
  final Color bgColor = const Color(0xFFF7F9FA);
  final Color textDark = const Color(0xFF2E3137);
  final Color textLight = const Color(0xFF6D7588);

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await loadProducts();
    await loadCategories();
  }

  Future<void> loadProducts() async {
    final data = await StorageService.loadProducts();
    setState(() => products = data);
  }

  Future<void> loadCategories() async {
    final data = await StorageService.loadCategories();
    setState(() => categories = data);
  }

  // ================= LOGIC FUNCTIONS =================

  void deleteProduct(String id) async {
    setState(() => products.removeWhere((p) => p.id == id));
    await StorageService.saveProducts(products);
    _showToast("Produk berhasil dihapus");
  }

  void addCategory(String cat) {
    if (cat.isEmpty) return;
    if (!categories.contains(cat)) {
      categories.add(cat);
      StorageService.saveCategories(categories);
    }
    setState(() {
      selectedCategory = cat;
      categoryCtrl.clear();
    });
  }

  void _showToast(String msg, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        msg,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white, // ⬅️ INI KUNCINYA
        ),
      ),
      backgroundColor: isError ? Colors.redAccent : textDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ),
  );
}


  // ================= UI BUILDERS =================

  @override
  Widget build(BuildContext context) {
    final filteredItems = filterCategory.isEmpty
        ? products
        : products.where((p) => p.category == filterCategory).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          _buildCategoryFilter(),
          filteredItems.isEmpty 
              ? _buildEmptyState() 
              : _buildProductList(filteredItems),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      pinned: true,
      elevation: 0,
      backgroundColor: surfaceColor,
      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text('Katalog Produk', 
          style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 22)),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _buildFilterChip('Semua', filterCategory.isEmpty, () => setState(() => filterCategory = '')),
            ...categories.map((cat) => _buildFilterChip(cat, filterCategory == cat, () => setState(() => filterCategory = cat))),
            IconButton(
              onPressed: _showAddCategoryDialog,
              icon: Icon(Icons.add_circle_outline_rounded, color: primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool active, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => onTap(),
        selectedColor: primaryColor,
        backgroundColor: Colors.white,
        elevation: 0,
        pressElevation: 0,
        labelStyle: TextStyle(
          color: active ? Colors.white : textLight, 
          fontWeight: active ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: active ? primaryColor : Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _buildProductList(List<Product> items) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final p = items[i];
            return Dismissible(
              key: Key(p.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => deleteProduct(p.id),
              background: _buildDeleteBackground(),
              child: _buildProductCard(p),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
    );
  }

  Widget _buildProductCard(Product p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildProductImage(p.imagePath),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.category.toUpperCase(), 
                      style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(p.name, style: TextStyle(color: textDark, fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Rp ${p.price}', 
                      style: TextStyle(color: textDark, fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
              ),
            ),
            _buildBarcodeBadge(p.barcode),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String path) {
    return Container(
      width: 90, height: 90,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: path.isNotEmpty && File(path).existsSync()
          ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(File(path), fit: BoxFit.cover))
          : Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade300, size: 30),
    );
  }

  Widget _buildBarcodeBadge(String code) {
    return Container(
      width: 40,
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.5),
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: RotatedBox(
        quarterTurns: 1,
        child: Center(
          child: Text(code, 
            style: TextStyle(fontSize: 9, color: textLight.withOpacity(0.5), fontWeight: FontWeight.w800, letterSpacing: 1)),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _showScanBarcode,
      backgroundColor: textDark,
      elevation: 4,
      icon: const Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 20),
      label: const Text('TAMBAH PRODUK', 
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  // ================= MODALS & DIALOGS =================

  void _showScanBarcode() {
    isScanning = false;
    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: MobileScanner(onDetect: (cap) {
        if (isScanning) return;
        final code = cap.barcodes.first.rawValue;
        if (code != null) {
          isScanning = true;
          Navigator.pop(context);
          _handleScanned(code);
        }
      }),
    )));
  }

  void _handleScanned(String code) {
    final existing = products.where((p) => p.barcode == code).toList();
    if (existing.isNotEmpty) {
      _showToast("Produk ini sudah ada: ${existing.first.name}", isError: true);
      return;
    }
    scannedBarcode = code;
    _showAddSheet();
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModal) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 24),
                Text('Lengkapi Produk', style: TextStyle(color: textDark, fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 24),
                
                // Image Picker
                GestureDetector(
                  onTap: () => _pickImage(setModal),
                  child: Container(
                    height: 160, width: double.infinity,
                    decoration: BoxDecoration(
                      color: bgColor, 
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: imagePath.isEmpty
                        ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_rounded, color: primaryColor, size: 40), const SizedBox(height: 8), Text('Ketuk untuk Foto', style: TextStyle(color: textLight, fontWeight: FontWeight.w600))])
                        : ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.file(File(imagePath), fit: BoxFit.cover)),
                  ),
                ),
                
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedCategory.isEmpty ? null : selectedCategory,
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setModal(() => selectedCategory = v ?? ''),
                  decoration: _inputDeco('Kategori Produk', Icons.grid_view_rounded),
                ),
                
                const SizedBox(height: 16),
                TextField(controller: nameCtrl, decoration: _inputDeco('Nama Produk', Icons.edit_rounded)),
                
                const SizedBox(height: 16),
                TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: _inputDeco('Harga Jual (Rp)', Icons.payments_rounded)),
                
                const SizedBox(height: 24),
                _buildBarcodeStatus(),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity, height: 60,
                  child: ElevatedButton(
                    onPressed: _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: const Text('KONFIRMASI & SIMPAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Kategori Baru',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
      content: TextField(
        controller: categoryCtrl,
        style: const TextStyle(color: Colors.black87),
        decoration: _inputDeco(
          'Nama Kategori',
          Icons.category_rounded,
        ).copyWith(
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(color: Colors.black38),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(
            'Batal',
            style: TextStyle(color: Colors.black54),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            addCategory(categoryCtrl.text);
            Navigator.pop(ctx);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Simpan',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}


  // ================= HELPERS =================

  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      labelText: hint,
      prefixIcon: Icon(icon, color: primaryColor, size: 20),
      filled: true, fillColor: bgColor,
      labelStyle: TextStyle(color: textLight, fontWeight: FontWeight.w500),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryColor, width: 2)),
    );
  }

  Widget _buildBarcodeStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [Icon(Icons.qr_code_rounded, color: primaryColor), const SizedBox(width: 12), Text('Barcode: $scannedBarcode', style: TextStyle(fontWeight: FontWeight.w800, color: primaryColor))]),
    );
  }

  Future<void> _pickImage(StateSetter setModal) async {
    final picker = ImagePicker();
   final img = await picker.pickImage(
  source: ImageSource.gallery,
  imageQuality: 70,
);

    if (img != null) {
      final dir = await getApplicationDocumentsDirectory();
      final saved = await File(img.path).copy('${dir.path}/${p.basename(img.path)}');
      setModal(() => imagePath = saved.path);
    }
  }

  void _saveProduct() async {
    if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty || selectedCategory.isEmpty) {
      _showToast("Mohon lengkapi semua data", isError: true);
      return;
    }
    final p = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameCtrl.text,
      price: int.tryParse(priceCtrl.text) ?? 0,
      imagePath: imagePath,
      barcode: scannedBarcode,
      category: selectedCategory,
    );
    products.add(p);
    await StorageService.saveProducts(products);
    nameCtrl.clear(); priceCtrl.clear(); imagePath = ''; scannedBarcode = '';
    Navigator.pop(context);
    loadProducts();
    _showToast("Produk berhasil disimpan");
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade200),
            const SizedBox(height: 16),
            Text('Katalog produk masih kosong', style: TextStyle(color: textLight, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}