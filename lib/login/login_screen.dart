// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:point_of_sale_app/admin/products_screen.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/user_model.dart';
import 'package:point_of_sale_app/general/my_custom_snackbar.dart';
import 'package:point_of_sale_app/pos_screen/pos_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                final username = usernameController.text;
                final password = passwordController.text;

                UserModel? user = await DatabaseHelper.instance
                    .loginCheck(username, password);

                // print('USERRR=$user');

                if (user != null) {
                  if (user.isAdmin) {
                    ScaffoldMessenger.of(context).showSnackBar(myCustomSnackBar(
                        message: 'Admin LogIn:  ${user.name}', warning: false));
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProductsScreen()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(myCustomSnackBar(
                        message: 'User LogIn:  ${user.name}', warning: false));
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PosScreen()));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(myCustomSnackBar(
                      message: 'Wrong Password Or Username', warning: true));
                }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
