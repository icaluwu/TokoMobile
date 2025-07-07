import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String _debugInfo = '';
  bool _isLoading = false;

  void _addDebugInfo(String info) {
    setState(() {
      _debugInfo += '$info\n';
    });
    print('DEBUG: $info');
  }

  Future<void> _testCartFunctionality() async {
    setState(() {
      _isLoading = true;
      _debugInfo = 'Starting cart test...\n';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _addDebugInfo('❌ No user logged in');
        return;
      }
      
      _addDebugInfo('✅ User logged in: ${user.email}');
      _addDebugInfo('User UID: ${user.uid}');

      // Test 1: Check user document
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      
      final userDoc = await userDocRef.get();
      if (userDoc.exists) {
        _addDebugInfo('✅ User document exists');
        _addDebugInfo('User data: ${userDoc.data()}');
      } else {
        _addDebugInfo('⚠️ User document does not exist, creating...');
        await userDocRef.set({
          'email': user.email,
          'role': 'customer',
          'createdAt': Timestamp.now(),
        });
        _addDebugInfo('✅ User document created');
      }

      // Test 2: Test cart write
      _addDebugInfo('\n🧪 Testing cart write...');
      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart');

      final testProduct = {
        'productId': 'test-product-123',
        'name': 'Test Product',
        'price': 100000,
        'quantity': 1,
        'stock': 10,
        'image_url': 'https://via.placeholder.com/200',
        'addedAt': Timestamp.now(),
      };

      await cartRef.doc('test-product-123').set(testProduct);
      _addDebugInfo('✅ Test product added to cart');

      // Test 3: Test cart read
      _addDebugInfo('\n📖 Testing cart read...');
      final cartSnapshot = await cartRef.get();
      _addDebugInfo('Cart items count: ${cartSnapshot.docs.length}');
      
      for (var doc in cartSnapshot.docs) {
        _addDebugInfo('Cart item: ${doc.id} - ${doc.data()}');
      }

      // Test 4: Test cart update
      _addDebugInfo('\n🔄 Testing cart update...');
      await cartRef.doc('test-product-123').update({
        'quantity': FieldValue.increment(1),
      });
      _addDebugInfo('✅ Cart quantity updated');

      // Test 5: Verify update
      final updatedDoc = await cartRef.doc('test-product-123').get();
      if (updatedDoc.exists) {
        _addDebugInfo('Updated quantity: ${updatedDoc.data()!['quantity']}');
      }

      // Test 6: Test cart delete
      _addDebugInfo('\n🗑️ Testing cart delete...');
      await cartRef.doc('test-product-123').delete();
      _addDebugInfo('✅ Test product removed from cart');

      _addDebugInfo('\n🎉 All cart tests passed!');

    } catch (e) {
      _addDebugInfo('❌ Error: $e');
      _addDebugInfo('Error type: ${e.runtimeType}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkFirestoreConnection() async {
    setState(() {
      _isLoading = true;
      _debugInfo = 'Testing Firestore connection...\n';
    });

    try {
      // Test basic Firestore read
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .limit(1)
          .get();
      
      _addDebugInfo('✅ Firestore connection working');
      _addDebugInfo('Products found: ${snapshot.docs.length}');
      
      if (snapshot.docs.isNotEmpty) {
        _addDebugInfo('Sample product: ${snapshot.docs.first.data()}');
      }

    } catch (e) {
      _addDebugInfo('❌ Firestore connection error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkUserAuth() async {
    setState(() {
      _debugInfo = 'Checking user authentication...\n';
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _addDebugInfo('✅ User is authenticated');
      _addDebugInfo('Email: ${user.email}');
      _addDebugInfo('UID: ${user.uid}');
      _addDebugInfo('Email verified: ${user.emailVerified}');
    } else {
      _addDebugInfo('❌ No user authenticated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Cart'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Control buttons
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _checkUserAuth,
                  child: Text('Check Auth'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _checkFirestoreConnection,
                  child: Text('Check Firestore'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testCartFunctionality,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('Test Cart'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _debugInfo = '';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Clear'),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Loading indicator
            if (_isLoading)
              LinearProgressIndicator(),
            
            SizedBox(height: 16),
            
            // Debug output
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _debugInfo.isEmpty ? 'Click a button to start debugging...' : _debugInfo,
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
