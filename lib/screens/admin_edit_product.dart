import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEditProduct extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const AdminEditProduct({super.key, required this.productId, required this.productData});

  @override
  State<AdminEditProduct> createState() => _AdminEditProductState();
}

class _AdminEditProductState extends State<AdminEditProduct> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.productData['name']);
    _descController = TextEditingController(text: widget.productData['description']);
    _priceController = TextEditingController(text: widget.productData['price'].toString());
    _stockController = TextEditingController(text: widget.productData['stock'].toString());
    _imageUrlController = TextEditingController(text: widget.productData['image_url']);
  }

  void _updateProduct() async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(widget.productId).update({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': int.parse(_priceController.text),
        'stock': int.parse(_stockController.text),
        'image_url': _imageUrlController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Produk berhasil diupdate")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal update: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Produk")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: "Nama")),
            TextField(controller: _descController, decoration: InputDecoration(labelText: "Deskripsi")),
            TextField(controller: _priceController, decoration: InputDecoration(labelText: "Harga"), keyboardType: TextInputType.number),
            TextField(controller: _stockController, decoration: InputDecoration(labelText: "Stok"), keyboardType: TextInputType.number),
            TextField(controller: _imageUrlController, decoration: InputDecoration(labelText: "Image URL")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _updateProduct, child: Text("Update Produk")),
          ],
        ),
      ),
    );
  }
}
