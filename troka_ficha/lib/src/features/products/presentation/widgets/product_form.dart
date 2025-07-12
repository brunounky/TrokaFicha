import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troka_ficha/src/features/products/domain/entities/product.dart';
import 'package:troka_ficha/src/features/products/presentation/providers/product_providers.dart';

class ProductForm extends ConsumerStatefulWidget {
  const ProductForm({super.key});

  @override
  ConsumerState<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _valueController;
  late TextEditingController _eventNameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _valueController = TextEditingController();
    _eventNameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _eventNameController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final editingProduct = ref.read(editingProductProvider);

    final productToSave = Product(
      name: _nameController.text,
      unitValue: double.parse(_valueController.text.replaceAll(',', '.')),
      eventName: _eventNameController.text.isNotEmpty ? _eventNameController.text : null,
    );

    if (editingProduct != null) {
      productToSave.id = editingProduct.id;
    }

    try {
      // CORREÇÃO: Aguardamos o provider do caso de uso estar pronto antes de chamá-lo.
      final saveUseCase = await ref.read(saveProductProvider.future);
      await saveUseCase.call(productToSave);

      _clearForm();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produto "${productToSave.name}" salvo com sucesso!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar o produto: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _valueController.clear();
    _eventNameController.clear();
    ref.read(editingProductProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Product?>(editingProductProvider, (previous, next) {
      if (next != null) {
        _nameController.text = next.name;
        _valueController.text = next.unitValue.toStringAsFixed(2).replaceAll('.', ',');
        _eventNameController.text = next.eventName ?? '';
      }
    });

    final isEditing = ref.watch(editingProductProvider) != null;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              isEditing ? 'Editar Produto' : 'Novo Produto',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Produto',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: 'Valor Unitário (R\$)',
                prefixIcon: Icon(Icons.monetization_on_outlined),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,]'))],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Campo obrigatório';
                final val = double.tryParse(value.replaceAll(',', '.'));
                if (val == null || val <= 0) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _eventNameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Evento (Opcional)',
                prefixIcon: Icon(Icons.event_outlined),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _submitForm,
              icon: Icon(isEditing ? Icons.save_as_outlined : Icons.add_circle_outline),
              label: Text(isEditing ? 'Salvar Alterações' : 'Cadastrar Produto'),
            ),
            if (isEditing) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _clearForm,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancelar Edição'),
                style: TextButton.styleFrom(foregroundColor: theme.colorScheme.secondary),
              )
            ],
          ],
        ),
      ),
    );
  }
}
