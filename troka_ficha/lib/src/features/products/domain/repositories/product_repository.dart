import 'package:troka_ficha/src/features/products/domain/entities/product.dart';

abstract class ProductRepository {
  Stream<List<Product>> watchAllProducts();

  Future<void> saveProduct(Product product);

  Future<void> deleteProduct(int productId);
}