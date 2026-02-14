
import 'package:flutter/material.dart';
import 'package:the_full_feature_flutterfire_app/features/home/products/widget/category_selector.dart';
import 'package:the_full_feature_flutterfire_app/features/home/products/widget/product_card.dart';

import 'logic/products_cubit.dart';
import 'logic/products_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductsTab extends StatelessWidget {
  const ProductsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductsCubit()..fetchProducts(),
      child: Column(
        children: [
          // شريط التصنيفات
          CategorySelector(),
          // قائمة المنتجات
          Expanded(
            child: BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, state) {
                if (state is ProductsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProductsLoaded) {
                  final products = state.products;
                  if (products.isEmpty) return const Center(child: Text('لا توجد منتجات'));
                  return GridView.builder(
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.7
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(product: product, docId: product['id'],);
                    },
                  );
                } else if (state is ProductsError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}