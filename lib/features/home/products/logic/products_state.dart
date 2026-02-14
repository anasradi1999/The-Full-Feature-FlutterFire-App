abstract class ProductsState {}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Map<String, dynamic>> products;
  final String selectedCategoryId; // أضف هذا الحقل

  ProductsLoaded({
    required this.products,
    required this.selectedCategoryId,
  });
}

class ProductsError extends ProductsState {
  final String message;
  ProductsError(this.message);
}