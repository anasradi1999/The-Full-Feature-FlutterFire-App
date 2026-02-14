import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/products_cubit.dart';
import '../logic/products_state.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'id': 'all', 'name': 'الكل'},
    {'id': 'phones', 'name': 'هواتف'},
    {'id': 'laptops', 'name': 'لابتوبات'},
    {'id': 'fashion', 'name': 'ملابس'},
    {'id': 'shoes', 'name': 'أحذية'},
    {'id': 'electronics', 'name': 'إلكترونيات'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          return BlocBuilder<ProductsCubit, ProductsState>(
            builder: (context, state) {
              // استخرج التصنيف الحالي من Cubit
              final selectedCategory = (context.read<ProductsCubit>().state is ProductsLoaded)
                  ? (context.read<ProductsCubit>().state as ProductsLoaded).selectedCategoryId ?? 'all'
                  : 'all';

              final isSelected = selectedCategory == category['id'];

              return GestureDetector(
                onTap: () {
                  // أخبر الـ Cubit بجلب المنتجات حسب التصنيف الجديد
                  context.read<ProductsCubit>().fetchProducts(categoryId: category['id']);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.amber : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5)],
                  ),
                  child: Center(
                    child: Text(
                      category['name'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}