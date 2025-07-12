import 'package:isar/isar.dart';
import 'package:troka_ficha/src/features/products/domain/entities/product.dart';
import 'package:troka_ficha/src/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final Isar isar;

  ProductRepositoryImpl(this.isar);

  @override
  Stream<List<Product>> watchAllProducts() {
    return isar.products.where().watch(fireImmediately: true);
  }

  @override
  Future<void> saveProduct(Product product) async {
    await isar.writeTxn(() async {
      await isar.products.put(product);
    });
  }

  @override
  Future<void> deleteProduct(int productId) async {
    await isar.writeTxn(() async {
      await isar.products.delete(productId);
    });
  }
}