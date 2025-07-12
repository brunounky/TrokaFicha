import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:troka_ficha/src/core/app_globals.dart';
import 'package:troka_ficha/src/features/products/data/repositories/product_repository_impl.dart';
import 'package:troka_ficha/src/features/products/domain/entities/product.dart';
import 'package:troka_ficha/src/features/products/domain/repositories/product_repository.dart';
import 'package:troka_ficha/src/features/products/domain/usecases/delete_product.dart';
import 'package:troka_ficha/src/features/products/domain/usecases/save_product.dart';
import 'package:troka_ficha/src/features/products/domain/usecases/watch_products.dart';

part 'product_providers.g.dart';

// --- Providers de Infraestrutura ---

// 1. CORREÇÃO: Usamos um FutureProvider para lidar com a inicialização assíncrona do Isar.
@riverpod
Future<Isar> isar(IsarRef ref) async {
  // Agora aguardamos o Future<Isar> do seu serviço ser completado.
  return await isarService.db;
}

// 2. O provider do repositório agora também é assíncrono.
// Ele vai esperar o isarProvider estar pronto.
@riverpod
Future<ProductRepository> productRepository(ProductRepositoryRef ref) async {
  // ref.watch(isarProvider.future) garante que vamos esperar o Isar carregar.
  final isarInstance = await ref.watch(isarProvider.future);
  return ProductRepositoryImpl(isarInstance);
}

// --- Providers de Casos de Uso (Use Cases) ---
// Eles também se tornam assíncronos para aguardar o repositório.

@riverpod
Future<WatchProducts> watchProducts(WatchProductsRef ref) async {
  final repository = await ref.watch(productRepositoryProvider.future);
  return WatchProducts(repository);
}

@riverpod
Future<SaveProduct> saveProduct(SaveProductRef ref) async {
  final repository = await ref.watch(productRepositoryProvider.future);
  return SaveProduct(repository);
}

@riverpod
Future<DeleteProduct> deleteProduct(DeleteProductRef ref) async {
  final repository = await ref.watch(productRepositoryProvider.future);
  return DeleteProduct(repository);
}


// --- Providers de Estado para a UI ---

@riverpod
Stream<List<Product>> productList(ProductListRef ref) {
  // Usamos .when para lidar com o estado do FutureProvider.
  // Quando o repositório estiver carregado, pegamos o stream.
  final watchProductsUseCase = ref.watch(watchProductsProvider);
  return watchProductsUseCase.when(
    data: (useCase) => useCase.call(),
    loading: () => const Stream.empty(), // Retorna um stream vazio enquanto carrega
    error: (err, stack) => Stream.error(err), // Propaga o erro
  );
}

@riverpod
class EditingProduct extends _$EditingProduct {
  @override
  Product? build() => null;

  void setProduct(Product? product) => state = product;
  void clear() => state = null;
}
