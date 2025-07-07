import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _selectedFilter = 'all';

  String formatRupiah(double amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return formatter.format(amount);
  }

  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'shipped':
        return 'Dalam Pengiriman';
      case 'delivered':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status pesanan berhasil diperbarui')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status: $e')),
      );
    }
  }

  void _showStatusUpdateDialog(String orderId, String currentStatus) {
    final statuses = ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'];
    String selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Update Status Pesanan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((status) {
              return RadioListTile<String>(
                title: Text(getStatusText(status)),
                value: status,
                groupValue: selectedStatus,
                onChanged: (value) {
                  setDialogState(() => selectedStatus = value!);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateOrderStatus(orderId, selectedStatus);
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Pesanan'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('all', 'Semua'),
                _buildFilterChip('pending', 'Pending'),
                _buildFilterChip('confirmed', 'Dikonfirmasi'),
                _buildFilterChip('shipped', 'Dikirim'),
                _buildFilterChip('delivered', 'Selesai'),
                _buildFilterChip('cancelled', 'Dibatalkan'),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _selectedFilter == 'all'
            ? FirebaseFirestore.instance
                .collection('orders')
                .orderBy('createdAt', descending: true)
                .snapshots()
            : FirebaseFirestore.instance
                .collection('orders')
                .where('status', isEqualTo: _selectedFilter)
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Tidak ada pesanan',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;
              final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

              return Card(
                margin: EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${order.id.substring(0, 8)}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(data['userId'])
                                  .get(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.hasData) {
                                  final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                                  return Text(
                                    userData?['email'] ?? 'User tidak ditemukan',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  );
                                }
                                return Text('Loading...', style: TextStyle(fontSize: 12));
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: getStatusColor(data['status'] ?? '').withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          getStatusText(data['status'] ?? ''),
                          style: TextStyle(
                            color: getStatusColor(data['status'] ?? ''),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(formatDate(data['createdAt'])),
                      SizedBox(height: 4),
                      Text(
                        formatRupiah(data['total']?.toDouble() ?? 0),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detail Pesanan:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          ...items.map((item) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: item['image_url'] != null && 
                                           item['image_url'].toString().isNotEmpty
                                        ? Image.network(
                                            item['image_url'],
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Icon(Icons.broken_image, size: 50),
                                          )
                                        : Container(
                                            width: 50,
                                            height: 50,
                                            color: Colors.grey.shade200,
                                            child: Icon(Icons.image, color: Colors.grey),
                                          ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'] ?? 'Unknown Product',
                                          style: TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          '${item['quantity']}x ${formatRupiah(item['price']?.toDouble() ?? 0)}',
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    formatRupiah((item['price'] * item['quantity'])?.toDouble() ?? 0),
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }),
                          Divider(height: 20),
                          if (data['shippingAddress'] != null) ...[
                            Text(
                              'Alamat Pengiriman:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(data['shippingAddress']['name'] ?? ''),
                            Text(data['shippingAddress']['phone'] ?? ''),
                            Text(data['shippingAddress']['address'] ?? ''),
                            Text('${data['shippingAddress']['city']} ${data['shippingAddress']['postalCode']}'),
                            SizedBox(height: 12),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Metode Pembayaran:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                data['paymentMethod'] == 'cod' 
                                    ? 'Cash on Delivery'
                                    : data['paymentMethod'] == 'bank_transfer'
                                        ? 'Transfer Bank'
                                        : 'E-Wallet',
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showStatusUpdateDialog(order.id, data['status'] ?? ''),
                                  icon: Icon(Icons.edit),
                                  label: Text('Update Status'),
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
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: _selectedFilter == value,
        onSelected: (selected) {
          setState(() => _selectedFilter = value);
        },
      ),
    );
  }
}
