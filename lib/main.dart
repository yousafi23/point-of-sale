import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sale_app/dashboard.dart';
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
    return GetMaterialApp(
      title: 'Yousaf',
      theme: ThemeData(
          primaryColor: Colors.white,
          elevatedButtonTheme: const ElevatedButtonThemeData(
              style: ButtonStyle(
                  foregroundColor: MaterialStatePropertyAll(Colors.white))),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.purple, foregroundColor: Colors.white),
          useMaterial3: true,
          textTheme:
              const TextTheme(headlineLarge: TextStyle(color: Colors.white))),
      // home: const Dashboard(),
      home: LoginScreen(),
    );
  }
}
