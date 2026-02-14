import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_full_feature_flutterfire_app/features/home/products/logic/products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit() : super(ProductsInitial());

  void fetchProducts({String categoryId = 'all'}) async {
    emit(ProductsLoading());
    try {
      QuerySnapshot snapshot;
      if (categoryId == 'all') {
        snapshot = await FirebaseFirestore.instance
            .collection('products')
            .orderBy('createdAt', descending: true)
            .get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('products')
            .where('categoryId', isEqualTo: categoryId)
            .orderBy('createdAt', descending: true)
            .get();
      }

      final products = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      emit(ProductsLoaded(products: products, selectedCategoryId: categoryId));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  void changeCategory(String categoryId) {
    fetchProducts(categoryId: categoryId);
  }
}