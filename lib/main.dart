import 'package:flutter/material.dart';
import 'package:point_of_sale_app/Dashboard/dashboard.dart';
import 'package:point_of_sale_app/admin/products_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future main() async {
// Initialize FFI
  sqfliteFfiInit();

  databaseFactory = databaseFactoryFfi;
  runApp(const Home());
}

// void main() {
//   runApp(const Home());
// }

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yousaf',
      theme: ThemeData(
          useMaterial3: true,
          textTheme:
              const TextTheme(headlineLarge: TextStyle(color: Colors.white))),
      // home: const Dashboard(),
      home: const ProductsScreen(),
    );
  }
}
