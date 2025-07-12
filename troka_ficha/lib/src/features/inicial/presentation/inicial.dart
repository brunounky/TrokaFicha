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
  String _selectedPaymentMethodInDialog = 'Dinheiro';
  final TextEditingController _cashReceivedController = TextEditingController();
  double _changeDue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _cashReceivedController.dispose();
    super.dispose();
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

    _showPaymentDialog();
  }

  void _calculateChange(String value) {
    final cash = double.tryParse(value) ?? 0.0;
    setState(() {
      _changeDue = cash - _currentSaleTotal;
    });
  }

  Future<void> _showPaymentDialog() async {
    _selectedPaymentMethodInDialog = 'Dinheiro';
    _cashReceivedController.clear();
    _changeDue = 0.0;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final ColorScheme colorScheme = Theme.of(context).colorScheme;
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Center(
                child: Text(
                  'Confirmar Pagamento',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildPaymentMethodCard(
                                context,
                                setState,
                                'Cartão',
                                Icons.credit_card,
                                _selectedPaymentMethodInDialog,
                                colorScheme,
                              ),
                              _buildPaymentMethodCard(
                                context,
                                setState,
                                'PIX',
                                Icons.qr_code,
                                _selectedPaymentMethodInDialog,
                                colorScheme,
                              ),
                            ],
                          ),
                          const Spacer(),
                          _buildPaymentMethodCard(
                            context,
                            setState,
                            'Dinheiro',
                            Icons.money,
                            _selectedPaymentMethodInDialog,
                            colorScheme,
                          ),
                        ],
                      ),
                    ),
                    VerticalDivider(width: 1, thickness: 1, color: colorScheme.outline),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Total a Pagar: R\$ ${_currentSaleTotal.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.secondary),
                            ),
                            const SizedBox(height: 20),
                            if (_selectedPaymentMethodInDialog == 'Dinheiro') ...[
                              TextFormField(
                                controller: _cashReceivedController,
                                decoration: InputDecoration(
                                  labelText: 'Valor Recebido (Dinheiro)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                                  prefixIcon: const Icon(Icons.money),
                                  filled: true,
                                  fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    _calculateChange(value);
                                  });
                                },
                                style: TextStyle(color: colorScheme.onSurface),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Troco: R\$ ${_changeDue.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _changeDue >= 0 ? colorScheme.tertiary : colorScheme.error,
                                ),
                              ),
                            ] else ...[
                              Text(
                                'Pagamento via ${_selectedPaymentMethodInDialog}',
                                style: TextStyle(fontSize: 18, color: colorScheme.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: colorScheme.error, fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_selectedPaymentMethodInDialog == 'Dinheiro' && _changeDue < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Valor recebido insuficiente!')),
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
                      paymentMethod: _selectedPaymentMethodInDialog,
                      saleDate: DateTime.now(),
                    );

                    await isarService.addSaleTicket(newTicket);

                    setState(() {
                      _cart.clear();
                      _currentSaleTotal = 0.0;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Venda emitida com sucesso via $_selectedPaymentMethodInDialog!')),
                    );
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.tertiary,
                    foregroundColor: colorScheme.onTertiary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Confirmar Pagamento'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context,
    StateSetter setState,
    String method,
    IconData icon,
    String currentSelectedMethod,
    ColorScheme colorScheme,
  ) {
    final bool isSelected = currentSelectedMethod == method;
    return Card(
      color: isSelected ? colorScheme.tertiary.withOpacity(0.2) : colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? colorScheme.tertiary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedPaymentMethodInDialog = method;
            _cashReceivedController.clear();
            _changeDue = 0.0;
          });
        },
        child: SizedBox(
          width: 120,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: isSelected ? colorScheme.tertiary : colorScheme.onSurfaceVariant),
              const SizedBox(height: 8),
              Text(
                method,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? colorScheme.tertiary : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme customColorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFF10454F), // 22:38-1-hex
      onPrimary: Colors.white,
      secondary: const Color(0xFF506266), // 22:38-2-hex
      onSecondary: Colors.white,
      error: Colors.red.shade700,
      onError: Colors.white,
      background: const Color(0xFF10454F), // Usando a cor primária para o background para um tema mais coeso
      onBackground: Colors.white,
      surface: const Color(0xFF506266), // 22:38-2-hex para superfície de cards do carrinho
      onSurface: Colors.white,
      surfaceVariant: const Color(0xFF818274), // 22:38-3-hex para superfície de cards de produto
      onSurfaceVariant: const Color(0xFFA3AB78), // 22:38-4-hex para texto em surfaceVariant
      outline: const Color(0xFF506266), // 22:38-2-hex para divisores
      inversePrimary: const Color(0xFF10454F), // 22:38-1-hex para AppBar e DrawerHeader
      onInverseSurface: Colors.white,
      tertiary: const Color(0xFFBDE038), 
      onTertiary: Colors.black,
    );

    final ColorScheme colorScheme = customColorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: colorScheme.inversePrimary,
        title: Text(
          'TrokaFicha',
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
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16.0),
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
                            crossAxisCount: 4,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 0.9,
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
