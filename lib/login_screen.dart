// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:point_of_sale_app/dashboard.dart';
import 'package:point_of_sale_app/controllers/login_controller.dart';
import 'package:point_of_sale_app/database/company_model.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/user_model.dart';
import 'package:point_of_sale_app/general/my_custom_snackbar.dart';
import 'package:point_of_sale_app/pos_screen/pos_screen.dart';

class LoginScreen extends StatelessWidget {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  LogInController logInController = Get.put(LogInController());

  LoginScreen({super.key});

  Future<void> logginIn(
      BuildContext context, String username, String password) async {
    UserModel? user =
        await DatabaseHelper.instance.loginCheck(username, password);

    if (user != null) {
      if (user.isAdmin) {
        logInController.setIsAdmin(user.isAdmin);
        myCustomSnackBar(
          message: 'Admin LogIn: ${user.name}',
          warning: false,
          context: context,
        );
        Get.to(() => const Dashboard());
      } else {
        logInController.setIsAdmin(user.isAdmin);
        myCustomSnackBar(
            message: 'User LogIn: ${user.name}',
            warning: false,
            context: context);
        Get.to(() => const PosScreen());
      }
    } else {
      myCustomSnackBar(
          message: 'Wrong Password Or Username',
          warning: true,
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<CompanyModel?>(
              future: DatabaseHelper.instance.loadCompanyData(0),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError || snapshot.data == null) {
                  return Container(
                    color: Colors.purple.shade100,
                    width: 200,
                    height: 200,
                    child: const Center(
                      child: Icon(Icons.image_outlined, size: 50),
                    ),
                  );
                } else {
                  final CompanyModel company = snapshot.data!;
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Image.memory(
                              company.companyLogo,
                              height: 250,
                              width: 250,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              company.companyName,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 300.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      const Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        obscureText: true,
                        onSubmitted: (value) =>
                            logginIn(context, usernameController.text, value),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => logginIn(context,
                            usernameController.text, passwordController.text),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                                (states) => Colors.purple.shade700)),
                        child: const Text('Log In'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
