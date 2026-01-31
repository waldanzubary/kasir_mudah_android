import 'package:flutter/material.dart';
import 'package:kasir_mudah/pages/cashier_page.dart';
import 'package:kasir_mudah/pages/main_navigation.dart';
import 'package:kasir_mudah/pages/product_page.dart';
import 'package:kasir_mudah/pages/transaction_history.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kasir Kelontong',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MainNavigation(),
    );
  }
}
