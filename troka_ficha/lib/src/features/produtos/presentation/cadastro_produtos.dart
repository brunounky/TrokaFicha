import 'package:flutter/material.dart';
import 'package:troka_ficha/src/features/inicial/domain/entities/product_model.dart';
import 'package:troka_ficha/src/core/app_globals.dart';

class CadastroProdutosScreen extends StatefulWidget {
  const CadastroProdutosScreen({super.key});

  @override
  State<CadastroProdutosScreen> createState() => _CadastroProdutosScreenState();
}

class _CadastroProdutosScreenState extends State<CadastroProdutosScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _unitValueController = TextEditingController();
  final TextEditingController _eventNameController = TextEditingController();

  List<Product> _registeredProducts = [];
  Product? _editingProduct;

  @override
  void initState() {
    super.initState();
    _loadRegisteredProducts();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _unitValueController.dispose();
    _eventNameController.dispose();
    super.dispose();
  }

  Future<void> _loadRegisteredProducts() async {
    final products = await isarService.getAllProducts();
    setState(() {
      _registeredProducts = products;
    });
  }

  void _editProduct(Product product) {
    setState(() {
      _editingProduct = product;
      _productNameController.text = product.name;
      _unitValueController.text = product.unitValue.toStringAsFixed(2);
      _eventNameController.text = product.eventName ?? '';
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingProduct = null;
      _clearForm();
    });
  }

  Future<void> _registerOrUpdateProduct() async {
    if (_formKey.currentState!.validate()) {
      if (_editingProduct == null) {
        final newProduct = Product(
          name: _productNameController.text,
          unitValue: double.parse(_unitValueController.text),
          eventName: _eventNameController.text.isEmpty ? null : _eventNameController.text,
        );
        await isarService.addProduct(newProduct);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produto "${newProduct.name}" cadastrado com sucesso!')),
        );
      } else {
        _editingProduct!.name = _productNameController.text;
        _editingProduct!.unitValue = double.parse(_unitValueController.text);
        _editingProduct!.eventName = _eventNameController.text.isEmpty ? null : _eventNameController.text;
        await isarService.addProduct(_editingProduct!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produto "${_editingProduct!.name}" atualizado com sucesso!')),
        );
      }

      _clearForm();
      _editingProduct = null;
      await _loadRegisteredProducts();
    }
  }

  void _clearForm() {
    _productNameController.clear();
    _unitValueController.clear();
    _eventNameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingProduct == null ? 'Cadastro de Produto' : 'Editar Produto'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: ListView(
                  children: <Widget>[
                    Text(
                      _editingProduct == null ? 'Novo Produto' : 'Detalhes do Produto',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    TextFormField(
                      controller: _productNameController,
                      decoration: InputDecoration(
                        labelText: 'Nome do Produto',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        prefixIcon: const Icon(Icons.label),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome do produto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _unitValueController,
                      decoration: InputDecoration(
                        labelText: 'Valor Unitário',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty || double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Por favor, insira um valor unitário válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _eventNameController,
                      decoration: InputDecoration(
                        labelText: 'Nome do Evento (Opcional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        prefixIcon: const Icon(Icons.event),
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    ElevatedButton.icon(
                      onPressed: _registerOrUpdateProduct,
                      icon: Icon(_editingProduct == null ? Icons.add : Icons.save),
                      label: Text(_editingProduct == null ? 'Cadastrar Produto' : 'Salvar Alterações'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (_editingProduct != null) ...[
                      const SizedBox(height: 16.0),
                      OutlinedButton.icon(
                        onPressed: _cancelEdit,
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancelar Edição'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          foregroundColor: Theme.of(context).colorScheme.error,
                          side: BorderSide(color: Theme.of(context).colorScheme.error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1, indent: 16, endIndent: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Produtos Cadastrados',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: _registeredProducts.isEmpty
                      ? const Center(child: Text('Nenhum produto cadastrado ainda.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          itemCount: _registeredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _registeredProducts[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                title: Text(
                                  product.name,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Valor: R\$ ${product.unitValue.toStringAsFixed(2)}'),
                                    if (product.eventName != null && product.eventName!.isNotEmpty)
                                      Text('Evento: ${product.eventName}'),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                  onPressed: () => _editProduct(product),
                                ),
                              ),
                            );
                          },
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
