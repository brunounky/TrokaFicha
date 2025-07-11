import 'package:flutter/material.dart';
import 'package:troka_ficha/src/features/inicial/presentation/inicial.dart';
import 'package:troka_ficha/src/core/app_globals.dart';
import 'package:troka_ficha/src/core/database/isar_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  isarService = IsarService();

  await isarService.db;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const InicialScreen(),
      },
    );
  }
}
