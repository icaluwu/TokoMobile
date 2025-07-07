import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';
import 'profile_screen.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  void _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Konfirmasi Logout"),
        content: Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService().logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  String formatRupiah(int amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return formatter.format(amount);
  }

  Future<void> _addToCart({
    required String productId,
    required String name,
    required int price,
    required int stock,
    required String imageUrl,
    required BuildContext context,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('Menambahkan ke keranjang...'),
          ],
        ),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      print('DEBUG: Adding to cart for user: ${user.uid}');
      print('DEBUG: Product ID: $productId');
      print('DEBUG: Product name: $name');
      print('DEBUG: Product price: $price');
      
      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart');

      print('DEBUG: Cart reference created');

      // First, ensure user document exists
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      
      final userDoc = await userDocRef.get();
      if (!userDoc.exists) {
        print('DEBUG: Creating user document');
        await userDocRef.set({
          'email': user.email,
          'role': 'customer',
          'createdAt': Timestamp.now(),
        });
      }

      print('DEBUG: Checking existing cart item');
      final existing = await cartRef.doc(productId).get();

      if (existing.exists) {
        print('DEBUG: Item exists, updating quantity');
        await cartRef.doc(productId).update({
          'quantity': FieldValue.increment(1),
        });
        print('DEBUG: Quantity updated successfully');
      } else {
        print('DEBUG: Item does not exist, creating new');
        await cartRef.doc(productId).set({
          'productId': productId,
          'name': name,
          'price': price,
          'quantity': 1,
          'stock': stock,
          'image_url': imageUrl,
          'addedAt': Timestamp.now(),
        });
        print('DEBUG: New cart item created successfully');
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('$name ditambahkan ke keranjang'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('DEBUG: Error adding to cart: $e');
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('Gagal menambahkan ke keranjang: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Toko Mobile'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            tooltip: 'Riwayat Pesanan',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OrderHistoryScreen()),
            ),
          ),
          IconButton(
            icon: Icon(Icons.person),
            tooltip: 'Profil',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileScreen()),
            ),
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            tooltip: 'Keranjang',
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.pushNamed(context, '/cart');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Silakan login terlebih dahulu')),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.bug_report),
            tooltip: 'Debug',
            onPressed: () => Navigator.pushNamed(context, '/debug'),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Simple query - no filters, just get all products
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 80, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No data'));
          }

          final products = snapshot.data!.docs;
          
          print('DEBUG: Found ${products.length} products'); // Debug log

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada produk tersedia',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final data = product.data() as Map<String, dynamic>;
                
                print('DEBUG: Product $index: ${data['name']}'); // Debug log
                
                final id = product.id;
                final name = data['name'] ?? 'No Name';
                final description = data['description'] ?? 'No Description';
                final price = data['price'] ?? 0;
                final stock = data['stock'] ?? 0;
                final imageUrl = data['image_url'] ?? '';

                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                          child: Image.network(
                            imageUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              height: 180,
                              color: Colors.grey.shade200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, size: 50),
                                  Text('Image Error'),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 50, color: Colors.grey),
                              Text('No Image'),
                            ],
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              description,
                              style: TextStyle(color: Colors.grey[600]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formatRupiah(price),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text(
                                      'Stok: $stock',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: stock <= 0
                                      ? null
                                      : () => _addToCart(
                                            productId: id,
                                            name: name,
                                            price: price,
                                            stock: stock,
                                            imageUrl: imageUrl,
                                            context: context,
                                          ),
                                  icon: Icon(Icons.add_shopping_cart),
                                  label: Text('Tambah'),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: stock <= 0 ? Colors.grey : Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {}); // Manual refresh
        },
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }
}
