import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the_full_feature_flutterfire_app/features/home/products/add_products.dart';
import 'package:the_full_feature_flutterfire_app/features/home/products/show_products.dart';
import 'notifications/notifications_page.dart';

class HomeProductsPage extends StatefulWidget {
  const HomeProductsPage({super.key});

  @override
  State<HomeProductsPage> createState() => _HomeProductsPageState();
}

class _HomeProductsPageState extends State<HomeProductsPage> {
  int _currentIndex = 0; // الصفحة الحالية في BottomNavigationBar
  int unreadNotificationsCount = 0;

  final List<Widget> _pages = const [
    ProductsTab(),
    NotificationsTab(),
  ];

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    // يمكن إضافة إعادة توجيه للشاشة الرئيسية بعد تسجيل الخروج
  }

  Future<void> _deleteAllProducts() async {
    final products = await FirebaseFirestore.instance.collection('products').get();
    for (var doc in products.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المتجر"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: "حذف جميع المنتجات",
            onPressed: _deleteAllProducts,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "تسجيل الخروج",
            onPressed: _logout,
          ),
        ],
      ),
      body: _pages[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductPage()),
          );
          // إضافة إشعار تلقائي عند الإضافة يمكن تفعيلها هنا
        },
      )
          : null,
      bottomNavigationBar: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('isRead', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          unreadNotificationsCount =
          snapshot.hasData ? snapshot.data!.docs.length : 0;
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'المنتجات',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications),
                    if (unreadNotificationsCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadNotificationsCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'الإشعارات',
              ),
            ],
          );
        },
      ),
    );
  }
}