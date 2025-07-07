import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  
  String _selectedPayment = 'cod';
  bool _isLoading = false;

  String formatRupiah(int amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return formatter.format(amount);
  }

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      
      // Get cart items
      final cartSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .get();

      if (cartSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Keranjang kosong')),
        );
        return;
      }

      // Calculate total
      double total = 0;
      List<Map<String, dynamic>> orderItems = [];
      
      for (var doc in cartSnapshot.docs) {
        final data = doc.data();
        final price = data['price'] ?? 0;
        final quantity = data['quantity'] ?? 1;
        total += price * quantity;
        
        orderItems.add({
          'productId': data['productId'],
          'name': data['name'],
          'price': price,
          'quantity': quantity,
          'image_url': data['image_url'],
        });
      }

      // Create order
      final orderData = {
        'userId': user.uid,
        'items': orderItems,
        'total': total,
        'status': 'pending',
        'paymentMethod': _selectedPayment,
        'shippingAddress': {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'postalCode': _postalCodeController.text.trim(),
        },
        'createdAt': Timestamp.now(),
      };

      await FirebaseFirestore.instance.collection('orders').add(orderData);

      // Clear cart
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Update stock
      for (var item in orderItems) {
        final productRef = FirebaseFirestore.instance
            .collection('products')
            .doc(item['productId']);
        
        await productRef.update({
          'stock': FieldValue.increment(-item['quantity']),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pesanan berhasil dibuat!')),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Order Summary
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Pesanan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('cart')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return CircularProgressIndicator();
                        
                        final items = snapshot.data!.docs;
                        double total = 0;
                        
                        return Column(
                          children: [
                            ...items.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final price = data['price'] ?? 0;
                              final quantity = data['quantity'] ?? 1;
                              total += price * quantity;
                              
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(data['name']),
                                subtitle: Text('${quantity}x ${formatRupiah(price)}'),
                                trailing: Text(formatRupiah(price * quantity)),
                              );
                            }),
                            Divider(),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                'Total',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: Text(
                                formatRupiah(total.toInt()),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Shipping Address
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alamat Pengiriman',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Penerima',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama harus diisi';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Nomor Telepon',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor telepon harus diisi';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Alamat Lengkap',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat harus diisi';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            decoration: InputDecoration(
                              labelText: 'Kota',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Kota harus diisi';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _postalCodeController,
                            decoration: InputDecoration(
                              labelText: 'Kode Pos',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Kode pos harus diisi';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Payment Method
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metode Pembayaran',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    RadioListTile<String>(
                      title: Text('Cash on Delivery (COD)'),
                      subtitle: Text('Bayar saat barang diterima'),
                      value: 'cod',
                      groupValue: _selectedPayment,
                      onChanged: (value) {
                        setState(() => _selectedPayment = value!);
                      },
                    ),
                    RadioListTile<String>(
                      title: Text('Transfer Bank'),
                      subtitle: Text('Transfer ke rekening toko'),
                      value: 'bank_transfer',
                      groupValue: _selectedPayment,
                      onChanged: (value) {
                        setState(() => _selectedPayment = value!);
                      },
                    ),
                    RadioListTile<String>(
                      title: Text('E-Wallet'),
                      subtitle: Text('OVO, GoPay, DANA'),
                      value: 'ewallet',
                      groupValue: _selectedPayment,
                      onChanged: (value) {
                        setState(() => _selectedPayment = value!);
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // Checkout Button
            ElevatedButton(
              onPressed: _isLoading ? null : _processCheckout,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text(
                      'Buat Pesanan',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
