import 'package:troka_ficha/src/features/products/domain/entities/product.dart';
import 'package:troka_ficha/src/features/products/domain/repositories/product_repository.dart';

class SaveProduct {
  final ProductRepository repository;
  SaveProduct(this.repository);

  Future<void> call(Product product) {
    return repository.saveProduct(product);
  }
}