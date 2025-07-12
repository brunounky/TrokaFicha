import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troka_ficha/src/core/theme/app_theme.dart';
import 'package:troka_ficha/src/features/products/presentation/screens/product_management_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrokaFicha',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const ProductManagementScreen(),
    );
  }
}
