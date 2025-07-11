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

  @override
  void dispose() {
    _productNameController.dispose();
    _unitValueController.dispose();
    _eventNameController.dispose();
    super.dispose();
  }

  Future<void> _registerProduct() async {
    if (_formKey.currentState!.validate()) {
      final newProduct = Product(
        name: _productNameController.text,
        unitValue: double.parse(_unitValueController.text),
        eventName: _eventNameController.text.isEmpty ? null : _eventNameController.text,
      );

      await isarService.addProduct(newProduct);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto "${newProduct.name}" cadastrado com sucesso!')),
      );

      _clearForm();
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
        title: const Text('Cadastro de Produto'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Produto',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Valor Unitário',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null || double.parse(value)! <= 0) {
                    return 'Por favor, insira um valor unitário válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Evento (Opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton.icon(
                onPressed: _registerProduct,
                icon: const Icon(Icons.save),
                label: const Text('Cadastrar Produto'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
