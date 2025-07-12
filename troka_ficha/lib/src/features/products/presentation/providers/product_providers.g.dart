// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productRepositoryHash() => r'e507522953b435c1eaf400e83e3c40c482868ca5';

/// See also [productRepository].
@ProviderFor(productRepository)
final productRepositoryProvider =
    AutoDisposeProvider<ProductRepository>.internal(
  productRepository,
  name: r'productRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ProductRepositoryRef = AutoDisposeProviderRef<ProductRepository>;
String _$watchProductsHash() => r'710a87fe0d976fcf8b351fbe93b57fcc98063fca';

/// See also [watchProducts].
@ProviderFor(watchProducts)
final watchProductsProvider = AutoDisposeProvider<WatchProducts>.internal(
  watchProducts,
  name: r'watchProductsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$watchProductsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WatchProductsRef = AutoDisposeProviderRef<WatchProducts>;
String _$saveProductHash() => r'59c75999ee7d38fc29aee1d5e92dfd82d9e42304';

/// See also [saveProduct].
@ProviderFor(saveProduct)
final saveProductProvider = AutoDisposeProvider<SaveProduct>.internal(
  saveProduct,
  name: r'saveProductProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$saveProductHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SaveProductRef = AutoDisposeProviderRef<SaveProduct>;
String _$deleteProductHash() => r'5e900a09690e5ab35aa1b0db8081c1ea8d2a6c6b';

/// See also [deleteProduct].
@ProviderFor(deleteProduct)
final deleteProductProvider = AutoDisposeProvider<DeleteProduct>.internal(
  deleteProduct,
  name: r'deleteProductProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deleteProductHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeleteProductRef = AutoDisposeProviderRef<DeleteProduct>;
String _$productListHash() => r'888707dcff84cb214b439c8d81d373e2e0f15096';

/// See also [productList].
@ProviderFor(productList)
final productListProvider = AutoDisposeStreamProvider<List<Product>>.internal(
  productList,
  name: r'productListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$productListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ProductListRef = AutoDisposeStreamProviderRef<List<Product>>;
String _$editingProductHash() => r'fffa24763a4ae1c71aadd8b54bfdb49129aff0b5';

/// See also [EditingProduct].
@ProviderFor(EditingProduct)
final editingProductProvider =
    AutoDisposeNotifierProvider<EditingProduct, Product?>.internal(
  EditingProduct.new,
  name: r'editingProductProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$editingProductHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EditingProduct = AutoDisposeNotifier<Product?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
