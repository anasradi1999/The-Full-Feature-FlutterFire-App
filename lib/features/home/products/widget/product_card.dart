import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../add_products.dart';
import '../logic/products_cubit.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final String docId;

  const ProductCard({
    super.key,
    required this.product,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = product['imageUrl'] ?? "none";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: imageUrl == "none"
                      ? Container(
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                  )
                      : Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      // زر تعديل
                      InkWell(
                        onTap: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddProductPage(
                                productData: {
                                  'id': docId,
                                  'name': product['name'],
                                  'price': product['price'],
                                  'categoryId': product['categoryId'],
                                  'categoryName': product['categoryName'],
                                  'imageUrl': product['imageUrl'],
                                },
                              ),
                            ),
                          );

                          if (updated == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم تعديل المنتج ✅')),
                            );
                            // إعادة تحميل المنتجات من Cubit
                            context.read<ProductsCubit>().fetchProducts();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue),
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          child: const Icon(Icons.edit, size: 16, color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // زر حذف
                      InkWell(
                        onTap: () async {
                          await FirebaseFirestore.instance.collection('products').doc(docId).delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم حذف المنتج ✅')),
                          );
                          context.read<ProductsCubit>().fetchProducts();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          child: const Icon(Icons.delete, size: 16, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  "\$${product['price']}",
                  style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  product['categoryName'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}