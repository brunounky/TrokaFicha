import 'package:troka_ficha/src/features/products/domain/repositories/product_repository.dart';

class DeleteProduct {
  final ProductRepository repository;
  DeleteProduct(this.repository);

  Future<void> call(int productId) {
    return repository.deleteProduct(productId);
  }
}