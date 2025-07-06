# Deploy Firestore Security Rules

## Option 1: Firebase Console (Recommended)
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project Anda
3. Masuk ke **Firestore Database**
4. Klik tab **Rules**
5. Copy paste isi file `firestore.rules` ke editor
6. Klik **Publish**

## Option 2: Firebase CLI
```bash
# Install Firebase CLI jika belum ada
npm install -g firebase-tools

# Login ke Firebase
firebase login

# Initialize Firebase di project
firebase init firestore

# Deploy rules
firebase deploy --only firestore:rules
```

## Firestore Rules Content
Copy paste rules berikut ke Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      // Allow users to read and write their own data
      allow read, write: if request.auth != null && request.auth.uid == userId;
      // Allow creation of user document during registration
      allow create: if request.auth != null;
      
      // Cart subcollection
      match /cart/{cartItemId} {
        // Allow users to read and write their own cart
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Products collection
    match /products/{productId} {
      // Allow everyone to read products
      allow read: if true;
      // Only authenticated users with admin role can write
      allow write: if request.auth != null && 
        exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Orders collection
    match /orders/{orderId} {
      // Allow users to read their own orders
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid ||
         (exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
          get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'));
      
      // Allow users to create their own orders
      allow create: if request.auth != null && request.auth.uid == resource.data.userId;
      
      // Allow admins to update order status
      allow update: if request.auth != null && 
        exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## Testing
Setelah deploy rules, test:
1. Login sebagai customer
2. Coba tambah produk ke keranjang
3. Cek apakah berhasil masuk ke koleksi cart
4. Login sebagai admin
5. Coba tambah produk baru
