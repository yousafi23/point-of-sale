import 'package:flutter/material.dart';
import 'package:point_of_sale_app/admin/add_ingredient_form.dart';
import 'package:point_of_sale_app/admin/products_screen.dart';
import 'package:point_of_sale_app/login_screen.dart';
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
      home: ProductsScreen(),
      // home: LoginScreen(),
    );
  }
}
