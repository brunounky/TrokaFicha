import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:troka_ficha/src/features/products/data/repositories/product_repository_impl.dart';
import 'package:troka_ficha/src/features/products/domain/entities/product.dart';
import 'package:troka_ficha/src/features/products/domain/repositories/product_repository.dart';
import 'package:troka_ficha/src/features/products/domain/usecases/delete_product.dart';
import 'package:troka_ficha/src/features/products/domain/usecases/save_product.dart';
import 'package:troka_ficha/src/features/products/domain/usecases/watch_products.dart';
part 'product_providers.g.dart';

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError();
});

@riverpod
ProductRepository productRepository(ProductRepositoryRef ref) {
  final isar = ref.watch(isarProvider);
  return ProductRepositoryImpl(isar);
}


@riverpod
WatchProducts watchProducts(WatchProductsRef ref) {
  final repository = ref.watch(productRepositoryProvider);
  return WatchProducts(repository);
}

@riverpod
SaveProduct saveProduct(SaveProductRef ref) {
  final repository = ref.watch(productRepositoryProvider);
  return SaveProduct(repository);
}

@riverpod
DeleteProduct deleteProduct(DeleteProductRef ref) {
  final repository = ref.watch(productRepositoryProvider);
  return DeleteProduct(repository);
}

@riverpod
Stream<List<Product>> productList(ProductListRef ref) {
  final watchProductsUseCase = ref.watch(watchProductsProvider);
  return watchProductsUseCase.call();
}

@riverpod
class EditingProduct extends _$EditingProduct {
  @override
  Product? build() => null;

  void setProduct(Product? product) => state = product;
  void clear() => state = null;
}
