import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_add_product.dart';
import 'admin_edit_product.dart';
import 'admin_orders_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../utils/sample_data.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  void _logout(BuildContext context) async {
    await AuthService().logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _deleteProduct(String docId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Produk dihapus")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal hapus: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard Admin"), actions: [
        IconButton(
          icon: Icon(Icons.bug_report),
          tooltip: 'Add Sample Data',
          onPressed: () async {
            try {
              await SampleData.addSampleProducts();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sample products added!')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
        ),
        IconButton(
          icon: Icon(Icons.assignment),
          tooltip: 'Kelola Pesanan',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AdminOrdersScreen()),
          ),
        ),
        IconButton(
          icon: Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () => _logout(context),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminAddProduct())),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').orderBy('created_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final products = snapshot.data!.docs;

          if (products.isEmpty) return Center(child: Text("Belum ada produk"));

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (ctx, i) {
              final product = products[i];
              final data = product.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: Image.network(data['image_url'], width: 60, height: 60, fit: BoxFit.cover),
                  title: Text(data['name']),
                  subtitle: Text("Rp ${data['price']} | Stok: ${data['stock']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit), onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => AdminEditProduct(productId: product.id, productData: data),
                        ));
                      }),
                      IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteProduct(product.id, context)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
