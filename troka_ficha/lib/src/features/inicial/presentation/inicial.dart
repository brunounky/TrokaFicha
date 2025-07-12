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
  String _selectedPaymentMethod = 'Dinheiro';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await isarService.getAllProducts();
    setState(() {
      _availableProducts = products;
    });
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

  void _clearCart() {
    setState(() {
      _cart.clear();
      _currentSaleTotal = 0.0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Carrinho limpo!')),
    );
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
      paymentMethod: _selectedPaymentMethod,
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: Text(
          'Vendas - $_currentEventName',
          style: TextStyle(color: colorScheme.onInverseSurface, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: colorScheme.onInverseSurface),
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
                color: colorScheme.primary,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add_shopping_cart, color: colorScheme.secondary),
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
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Expanded(
                  child: _availableProducts.isEmpty
                      ? Center(
                          child: Text(
                            'Nenhum produto disponível. Cadastre produtos na opção "Cadastro de Produto" do menu.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: _availableProducts.length,
                          itemBuilder: (context, index) {
                            final product = _availableProducts[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              color: colorScheme.surfaceVariant,
                              child: InkWell(
                                onTap: () => _addProductToCart(product),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        product.name,
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'R\$ ${product.unitValue.toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 16, color: colorScheme.tertiary, fontWeight: FontWeight.w600),
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
          VerticalDivider(width: 1, thickness: 1, color: colorScheme.outline),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Carrinho de Compras',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (_cart.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear_all, color: colorScheme.error),
                          tooltip: 'Limpar Carrinho',
                          onPressed: _clearCart,
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: _cart.isEmpty
                      ? Center(
                          child: Text(
                            'Carrinho vazio. Adicione produtos da lista ao lado.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _cart.length,
                          itemBuilder: (context, index) {
                            final product = _cart.keys.elementAt(index);
                            final quantity = _cart[product]!;
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              color: colorScheme.surface,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                title: Text(
                                  '${product.name} (x$quantity)',
                                  style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  'R\$ ${(product.unitValue * quantity).toStringAsFixed(2)}',
                                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove_circle_outline, color: colorScheme.tertiary),
                                      onPressed: () => _removeProductFromCart(product),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add_circle_outline, color: colorScheme.tertiary),
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
                        'Forma de Pagamento:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: colorScheme.onSurface),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedPaymentMethod,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          filled: true,
                          fillColor: colorScheme.surfaceVariant,
                        ),
                        dropdownColor: colorScheme.surfaceVariant,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedPaymentMethod = newValue!;
                          });
                        },
                        items: <String>['Dinheiro', 'Cartão de Crédito', 'Cartão de Débito', 'PIX']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Total da Compra: R\$ ${_currentSaleTotal.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _emitSaleTicket,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Emitir Venda'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(55),
                          backgroundColor: colorScheme.tertiary,
                          foregroundColor: colorScheme.onTertiary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          elevation: 5,
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
