import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeProductsPage extends StatefulWidget {
  const HomeProductsPage({super.key});

  @override
  State<HomeProductsPage> createState() => _HomeProductsPageState();
}

class _HomeProductsPageState extends State<HomeProductsPage> {
  String selectedCategory = 'all';

  // 🔹 التصنيفات (قيم افتراضية)
  final List<Map<String, dynamic>> categories = [
    {'id': 'all', 'name': 'الكل', 'icon': Icons.apps},
    {'id': 'phones', 'name': 'هواتف', 'icon': Icons.phone_android},
    {'id': 'laptops', 'name': 'لابتوبات', 'icon': Icons.laptop},
    {'id': 'fashion', 'name': 'ملابس', 'icon': Icons.checkroom},
    {'id': 'shoes', 'name': 'أحذية', 'icon': Icons.shopping_bag},
    {'id': 'electronics', 'name': 'إلكترونيات', 'icon': Icons.devices},
  ];

  // 🔹 المنتجات (قيم افتراضية)
  final List<Map<String, dynamic>> products = [
    {'name': 'iPhone 15', 'category': 'phones', 'price': 999},
    {'name': 'Samsung S24', 'category': 'phones', 'price': 899},
    {'name': 'MacBook Pro', 'category': 'laptops', 'price': 1999},
    {'name': 'HP Spectre', 'category': 'laptops', 'price': 1499},
    {'name': 'Nike Air Max', 'category': 'shoes', 'price': 199},
    {'name': 'T-Shirt', 'category': 'fashion', 'price': 49},
    {'name': 'Headphones', 'category': 'electronics', 'price': 149},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = selectedCategory == 'all'
        ? products
        : products
        .where((p) => p['category'] == selectedCategory)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildCategories(),
          const SizedBox(height: 12),
          _buildProductsGrid(filteredProducts),
        ],
      ),
    );
  }

  // 🟡 AppBar بظل خارجي
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AppBar(
          title: const Text(
            'المنتجات',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
              onPressed: () async{
                GoogleSignIn googleSignIn = GoogleSignIn();
                //await googleSignIn.disconnect();
                await googleSignIn.signOut();
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                }
              },
              icon: Icon(Icons.logout),
            ),
          ],
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
      ),
    );
  }

  // 🟢 التصنيفات (تصفية جانبية)
  Widget _buildCategories() {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['id'];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category['id'];
              });
            },
            child: Container(
              width: 85,
              decoration: BoxDecoration(
                color: isSelected ? Colors.yellow : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category['icon'],
                    color: isSelected ? Colors.black : Colors.grey,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category['name'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔵 Grid المنتجات
  Widget _buildProductsGrid(List<Map<String, dynamic>> products) {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          final product = products[index];

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.image, size: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product['price']}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

