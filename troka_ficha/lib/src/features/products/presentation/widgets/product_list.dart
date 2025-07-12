import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:troka_ficha/src/features/products/domain/entities/product.dart';
import 'package:troka_ficha/src/features/products/presentation/providers/product_providers.dart';

class ProductList extends ConsumerWidget {
  const ProductList({super.key});

  Future<void> _showDeleteConfirmation(BuildContext context, WidgetRef ref, Product product) async {
    final bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir o produto "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // CORREÇÃO: Aguardamos o provider do caso de uso estar pronto.
        final deleteUseCase = await ref.read(deleteProductProvider.future);
        await deleteUseCase.call(product.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Produto "${product.name}" excluído.'),
              backgroundColor: Colors.orange.shade800,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Acessar o stream de produtos agora é seguro, pois o provider lida com o estado de loading/error.
    final productsAsyncValue = ref.watch(productListProvider);
    final editingProduct = ref.watch(editingProductProvider);
    final theme = Theme.of(context);

    return productsAsyncValue.when(
      data: (products) {
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text('Nenhum produto cadastrado.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final isEditing = editingProduct?.id == product.id;

            return Card(
              color: isEditing ? theme.colorScheme.primary.withOpacity(0.1) : null,
              shape: isEditing
                  ? RoundedRectangleBorder(
                      side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  child: Text(
                    product.name.isNotEmpty ? product.name.substring(0, 1).toUpperCase() : '?',
                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('R\$ ${product.unitValue.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Editar',
                      color: theme.colorScheme.secondary,
                      onPressed: () {
                        ref.read(editingProductProvider.notifier).setProduct(product);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Excluir',
                      color: theme.colorScheme.error,
                      onPressed: () => _showDeleteConfirmation(context, ref, product),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: -0.1);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Erro ao carregar produtos: $err'),
        ),
      ),
    );
  }
}
