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
  bool passwordVisible = false;

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
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          color: Colors.purple.shade100,
                          width: 250,
                          height: 250,
                          child: const Center(
                            child: Icon(Icons.image_outlined, size: 50),
                          ),
                        ),
                      ),
                      const Text(
                        'Company',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                      PasswordField(
                        passwordController: passwordController,
                        onSubmit: () => logginIn(
                          context,
                          usernameController.text,
                          passwordController.text,
                        ),
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

class PasswordField extends StatefulWidget {
  const PasswordField(
      {super.key, required this.passwordController, required this.onSubmit});
  final TextEditingController passwordController;
  final Function onSubmit;
  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool passwordVisible = false;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.passwordController,
      obscureText: !passwordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(
            passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.purple.shade800,
            size: 16,
          ),
          onPressed: () {
            setState(() {
              passwordVisible = !passwordVisible;
            });
          },
        ),
      ),
      onSubmitted: (value) {
        widget.onSubmit();
      },
    );
  }
}
