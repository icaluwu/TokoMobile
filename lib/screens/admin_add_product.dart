import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddProduct extends StatefulWidget {
  const AdminAddProduct({super.key});

  @override
  State<AdminAddProduct> createState() => _AdminAddProductState();
}

class _AdminAddProductState extends State<AdminAddProduct> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController(); // Tambahan

  bool _isLoading = false;

  void _addProduct() async {
    if (_nameController.text.isEmpty ||
        _descController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _stockController.text.isEmpty ||
        _imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Semua kolom harus diisi")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': int.parse(_priceController.text),
        'stock': int.parse(_stockController.text),
        'image_url': _imageUrlController.text.trim(),
        'created_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Produk berhasil ditambahkan")));

      _nameController.clear();
      _descController.clear();
      _priceController.clear();
      _stockController.clear();
      _imageUrlController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal: $e")));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Produk')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: "Nama Produk")),
            TextField(controller: _descController, decoration: InputDecoration(labelText: "Deskripsi")),
            TextField(controller: _priceController, decoration: InputDecoration(labelText: "Harga"), keyboardType: TextInputType.number),
            TextField(controller: _stockController, decoration: InputDecoration(labelText: "Stok"), keyboardType: TextInputType.number),
            TextField(controller: _imageUrlController, decoration: InputDecoration(labelText: "Gambar (URL)")), // input baru
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _addProduct,
              child: _isLoading ? CircularProgressIndicator() : Text("Tambah Produk"),
            ),
          ],
        ),
      ),
    );
  }
}
