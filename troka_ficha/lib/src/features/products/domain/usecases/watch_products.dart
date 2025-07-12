import 'package:troka_ficha/src/features/products/domain/entities/product.dart';
import 'package:troka_ficha/src/features/products/domain/repositories/product_repository.dart';

class WatchProducts {
  final ProductRepository repository;
  WatchProducts(this.repository);

  Stream<List<Product>> call() {
    return repository.watchAllProducts();
  }
}