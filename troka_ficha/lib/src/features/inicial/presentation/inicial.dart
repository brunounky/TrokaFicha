import 'package:flutter/material.dart';
import 'package:troka_ficha/src/features/inicial/domain/entities/sale_ticket_model.dart';
import 'package:troka_ficha/src/features/inicial/domain/entities/product_model.dart';
import 'package:troka_ficha/src/core/app_globals.dart';
import 'package:troka_ficha/src/features/produtos/presentation/cadastro_produtos.dart';

class InicialScreen extends StatefulWidget {
  const InicialScreen({super.key});

  @override
  State<InicialScreen> createState() => _InicialScreenState();
}

class _InicialScreenState extends State<InicialScreen> {
  List<Product> _availableProducts = [];
  Map<Product, int> _cart = {};
  double _currentSaleTotal = 0.0;
  String _currentEventName = "Evento Principal";

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await isarService.getAllProducts();
    if (products.isEmpty) {
      await isarService.addProduct(Product(name: 'Camiseta P', unitValue: 35.00, eventName: _currentEventName));
      await isarService.addProduct(Product(name: 'Camiseta M', unitValue: 35.00, eventName: _currentEventName));
      await isarService.addProduct(Product(name: 'Boné', unitValue: 25.00, eventName: _currentEventName));
      await isarService.addProduct(Product(name: 'Caneca', unitValue: 20.00, eventName: _currentEventName));
      await isarService.addProduct(Product(name: 'Chaveiro', unitValue: 10.00, eventName: _currentEventName));
      final updatedProducts = await isarService.getAllProducts();
      setState(() {
        _availableProducts = updatedProducts;
      });
    } else {
      setState(() {
        _availableProducts = products;
      });
    }
  }

  void _addProductToCart(Product product) {
    setState(() {
      _cart.update(product, (quantity) => quantity + 1, ifAbsent: () => 1);
      _updateTotal();
    });
  }

  void _removeProductFromCart(Product product) {
    setState(() {
      if (_cart.containsKey(product)) {
        if (_cart[product]! > 1) {
          _cart.update(product, (quantity) => quantity - 1);
        } else {
          _cart.remove(product);
        }
      }
      _updateTotal();
    });
  }

  void _updateTotal() {
    _currentSaleTotal = _cart.entries.fold(0.0, (sum, entry) => sum + (entry.key.unitValue * entry.value));
  }

  Future<void> _emitSaleTicket() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O carrinho está vazio! Adicione produtos para emitir a venda.')),
      );
      return;
    }

    final totalQuantity = _cart.values.fold(0, (sum, quantity) => sum + quantity);
    final productsSummary = _cart.entries.map((e) => "${e.key.name} (x${e.value})").join(', ');

    final newTicket = SaleTicket(
      eventName: _currentEventName,
      productName: "Venda de Múltiplos Itens: ($productsSummary)",
      unitValue: _currentSaleTotal / totalQuantity,
      quantity: totalQuantity,
      totalValue: _currentSaleTotal,
      paymentMethod: 'Dinheiro',
      saleDate: DateTime.now(),
    );

    await isarService.addSaleTicket(newTicket);

    setState(() {
      _cart.clear();
      _currentSaleTotal = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Venda emitida com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Vendas - $_currentEventName'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_shopping_cart),
              title: const Text('Cadastro de Produto'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CadastroProdutosScreen()),
                );
                _loadProducts();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações do Sistema'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Ver Fichas de Venda'),
              onTap: () async {
                Navigator.pop(context);
                final allTickets = await isarService.getAllSaleTickets();
                print('Todas as Fichas de Venda:');
                for (var ticket in allTickets) {
                  print('  - ${ticket.productName} (x${ticket.quantity}) - R\$ ${ticket.totalValue.toStringAsFixed(2)}');
                }
              },
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Produtos Disponíveis',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Expanded(
                  child: _availableProducts.isEmpty
                      ? const Center(child: Text('Nenhum produto disponível. Adicione alguns!'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 3 / 2,
                          ),
                          itemCount: _availableProducts.length,
                          itemBuilder: (context, index) {
                            final product = _availableProducts[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: InkWell(
                                onTap: () => _addProductToCart(product),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'R\$ ${product.unitValue.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 16, color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Carrinho de Compras',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Expanded(
                  child: _cart.isEmpty
                      ? const Center(child: Text('Carrinho vazio.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _cart.length,
                          itemBuilder: (context, index) {
                            final product = _cart.keys.elementAt(index);
                            final quantity = _cart[product]!;
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: ListTile(
                                title: Text('${product.name} (x$quantity)'),
                                subtitle: Text('R\$ ${(product.unitValue * quantity).toStringAsFixed(2)}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: () => _removeProductFromCart(product),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () => _addProductToCart(product),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total da Compra: R\$ ${_currentSaleTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _emitSaleTicket,
                        icon: const Icon(Icons.check),
                        label: const Text('Emitir Venda'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
