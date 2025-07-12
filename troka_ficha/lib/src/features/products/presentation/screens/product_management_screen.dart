import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troka_ficha/src/features/products/presentation/widgets/product_form.dart';
import 'package:troka_ficha/src/features/products/presentation/widgets/product_list.dart';

class ProductManagementScreen extends ConsumerWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 800;
      if (isMobile) {
        return _MobileLayout();
      } else {
        return _DesktopLayout();
      }
    });
  }
}

class _DesktopLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciamento de Produtos')),
      body: const Row(
        children: [
          Expanded(flex: 2, child: ProductForm()),
          VerticalDivider(width: 1),
          Expanded(flex: 3, child: ProductList()),
        ],
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Produtos'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Cadastrar/Editar'),
              Tab(text: 'Lista'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProductForm(),
            ProductList(),
          ],
        ),
      ),
    );
  }
}