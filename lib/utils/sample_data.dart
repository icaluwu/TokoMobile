import 'package:cloud_firestore/cloud_firestore.dart';

class SampleData {
  static Future<void> addSampleProducts() async {
    final firestore = FirebaseFirestore.instance;
    
    // Sample products data
    final sampleProducts = [
      {
        'name': 'iPhone 15 Pro',
        'description': 'Latest iPhone with advanced camera and A17 Pro chip',
        'price': 15000000,
        'stock': 10,
        'image_url': 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400',
        'created_at': Timestamp.now(),
      },
      {
        'name': 'Samsung Galaxy S24',
        'description': 'Premium Android smartphone with excellent display',
        'price': 12000000,
        'stock': 15,
        'image_url': 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400',
        'created_at': Timestamp.now(),
      },
      {
        'name': 'iPad Air',
        'description': 'Powerful tablet for work and entertainment',
        'price': 8000000,
        'stock': 8,
        'image_url': 'https://images.unsplash.com/photo-1561154464-82e9adf32764?w=400',
        'created_at': Timestamp.now(),
      },
      {
        'name': 'MacBook Pro 14"',
        'description': 'Professional laptop with M3 chip',
        'price': 25000000,
        'stock': 5,
        'image_url': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
        'created_at': Timestamp.now(),
      },
      {
        'name': 'AirPods Pro',
        'description': 'Wireless earbuds with noise cancellation',
        'price': 3500000,
        'stock': 20,
        'image_url': 'https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?w=400',
        'created_at': Timestamp.now(),
      },
      {
        'name': 'Apple Watch Series 9',
        'description': 'Advanced smartwatch with health monitoring',
        'price': 5000000,
        'stock': 12,
        'image_url': 'https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=400',
        'created_at': Timestamp.now(),
      },
    ];

    try {
      // Add each product to Firestore
      for (var product in sampleProducts) {
        await firestore.collection('products').add(product);
        print('Added product: ${product['name']}');
      }
      print('All sample products added successfully!');
    } catch (e) {
      print('Error adding sample products: $e');
    }
  }

  static Future<void> createAdminUser() async {
    // This is just a reference - you need to manually create admin user
    // through Firebase Console or authentication flow
    print('To create admin user:');
    print('1. Register with email: admin@test.com, password: admin123');
    print('2. Then manually update the user document in Firestore:');
    print('   users/{userId} { email: "admin@test.com", role: "admin" }');
  }

  static Future<void> checkProductCount() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();
      
      print('Total products in database: ${snapshot.docs.length}');
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('- ${data['name']}: Rp ${data['price']} (Stock: ${data['stock']})');
      }
    } catch (e) {
      print('Error checking products: $e');
    }
  }
}
