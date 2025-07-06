# 🛒 E-Commerce Mobile App

Aplikasi e-commerce mobile yang dibangun dengan Flutter dan Firebase, lengkap dengan fitur manajemen produk, keranjang belanja, checkout, dan sistem pesanan.

## ✨ Fitur Utama

### 👤 **Customer Features**
- ✅ **Autentikasi**: Login/Register dengan Firebase Auth
- ✅ **Pencarian & Filter**: Cari produk berdasarkan nama/deskripsi, filter harga, sorting
- ✅ **Katalog Produk**: Melihat daftar produk dengan gambar, harga, dan stok
- ✅ **Keranjang Belanja**: Tambah/hapus produk, kelola quantity
- ✅ **Checkout**: Form alamat pengiriman dan pilihan metode pembayaran
- ✅ **Riwayat Pesanan**: Melihat status pesanan dan detail
- ✅ **Profile Management**: Edit profil, alamat, dan password
- ✅ **Batalkan Pesanan**: Batal pesanan yang masih pending

### 👨‍💼 **Admin Features**
- ✅ **Dashboard Admin**: Overview produk dan pesanan
- ✅ **Manajemen Produk**: CRUD produk (nama, deskripsi, harga, stok, gambar)
- ✅ **Manajemen Pesanan**: Lihat dan update status pesanan
- ✅ **Filter Pesanan**: Filter berdasarkan status (pending, confirmed, shipped, delivered, cancelled)

## 🏗️ **Struktur Proyek**

```
lib/
├── main.dart                    # Entry point aplikasi
├── firebase_options.dart       # Konfigurasi Firebase
├── models/
│   └── order_model.dart        # Model data untuk Order
├── screens/
│   ├── login_screen.dart       # Screen login
│   ├── register_screen.dart    # Screen registrasi
│   ├── customer_home.dart      # Home customer dengan search & filter
│   ├── admin_home.dart         # Dashboard admin
│   ├── admin_add_product.dart  # Tambah produk (admin)
│   ├── admin_edit_product.dart # Edit produk (admin)
│   ├── admin_orders_screen.dart # Kelola pesanan (admin)
│   ├── cart_screen.dart        # Keranjang belanja
│   ├── checkout_screen.dart    # Proses checkout
│   ├── order_history_screen.dart # Riwayat pesanan customer
│   └── profile_screen.dart     # Profile customer
├── services/
│   └── auth_service.dart       # Service untuk autentikasi
└── utils/
    └── validators.dart         # Utility untuk validasi form
```

## 🔧 **Setup & Installation**

### Prerequisites
- Flutter SDK (>= 3.8.1)
- Firebase Project
- Android Studio / VS Code

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Firebase Setup
1. Buat project di [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication (Email/Password)
3. Create Firestore Database
4. Download `google-services.json` (Android)
5. Jalankan Firebase CLI untuk generate `firebase_options.dart`

### 3. Run Application
```bash
flutter run
```

## 📊 **Database Structure (Firestore)**

### **Users Collection**
```javascript
users/{userId} {
  email: string,
  role: string, // "customer" atau "admin"
  name?: string,
  phone?: string,
  address?: string,
  city?: string,
  postalCode?: string
}
```

### **Products Collection**
```javascript
products/{productId} {
  name: string,
  description: string,
  price: number,
  stock: number,
  image_url: string,
  created_at: timestamp
}
```

### **Orders Collection**
```javascript
orders/{orderId} {
  userId: string,
  items: [{
    productId: string,
    name: string,
    price: number,
    quantity: number,
    image_url: string
  }],
  total: number,
  status: string, // "pending", "confirmed", "shipped", "delivered", "cancelled"
  paymentMethod: string, // "cod", "bank_transfer", "ewallet"
  shippingAddress: {
    name: string,
    phone: string,
    address: string,
    city: string,
    postalCode: string
  },
  createdAt: timestamp
}
```

## 🚀 **Usage Guide**

### **Customer Flow**
1. **Register/Login** → Buat akun atau masuk
2. **Browse Products** → Cari dan filter produk
3. **Add to Cart** → Tambahkan produk ke keranjang
4. **Checkout** → Isi alamat dan pilih pembayaran
5. **Track Orders** → Lihat status pesanan di riwayat

### **Admin Flow**
1. **Login as Admin** → Masuk dengan akun admin
2. **Manage Products** → Tambah, edit, hapus produk
3. **Manage Orders** → Update status pesanan customer

## 🛠️ **Dependencies Used**

```yaml
dependencies:
  firebase_core: ^2.30.0    # Firebase core
  firebase_auth: ^4.19.0    # Authentication
  cloud_firestore: ^4.17.0  # Database
  provider: ^6.1.2          # State management
  intl: ^0.18.1             # Internationalization
```

## 🚧 **Future Enhancements**

- [ ] **Push Notifications** (Firebase Messaging)
- [ ] **Image Upload** untuk produk (Firebase Storage)
- [ ] **Categories Management**
- [ ] **Payment Gateway** integration
- [ ] **Reviews & Ratings** system
- [ ] **Wishlist** functionality

---

**Happy Coding! 🎉**
