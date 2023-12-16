// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:point_of_sale_app/Dashboard/dashboard.dart';
import 'package:point_of_sale_app/admin/ingredients_screen.dart';
import 'package:point_of_sale_app/admin/products_screen.dart';
import 'package:point_of_sale_app/admin/users_screen.dart';
import 'package:point_of_sale_app/company_settings.dart';
import 'package:point_of_sale_app/controllers/login_controller.dart';
import 'package:point_of_sale_app/database/company_model.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/login_screen.dart';
import 'package:point_of_sale_app/order_view_screen.dart';
import 'package:point_of_sale_app/pop_screen/pop_screen.dart';
import 'package:point_of_sale_app/pos_screen/pos_screen.dart';
import 'package:point_of_sale_app/purchase_history.dart';

class ReusableDrawer extends StatelessWidget {
  final String title;
  final Widget currentPage;

  const ReusableDrawer({
    super.key,
    required this.title,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    LogInController logInController = Get.find();

    ListTile createDrawerItem({
      required String title,
      required Widget page,
    }) {
      return ListTile(
        title: Text(title),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => page),
          );
        },
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          FutureBuilder<CompanyModel?>(
            future: DatabaseHelper.instance.loadCompanyData(0),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                final CompanyModel company = snapshot.data!;
                return Image.memory(
                  company.companyLogo,
                  fit: BoxFit.cover,
                );
              } else {
                return Container(
                  color: Colors.purple.shade100,
                  width: 200,
                  height: 200,
                  child: const Center(
                    child: Icon(Icons.image_outlined, size: 50),
                  ),
                );
              }
            },
          ),
          if (logInController.isAdmin == true)
            createDrawerItem(
              title: 'Dashboard',
              page: const Dashboard(),
            ),
          if (logInController.isAdmin == true)
            createDrawerItem(
              title: 'Products',
              page: const ProductsScreen(),
            ),
          if (logInController.isAdmin == true)
            createDrawerItem(
              title: 'Ingredients',
              page: const IngredientsScreen(),
            ),
          createDrawerItem(
            title: 'POP',
            page: const PopScreen(),
          ),
          if (logInController.isAdmin == true)
            createDrawerItem(
              title: 'Purchase History',
              page: const PurchaseHistory(),
            ),
          if (logInController.isAdmin == true)
            createDrawerItem(
              title: 'Users',
              page: const UsersScreen(),
            ),
          createDrawerItem(
            title: 'Orders',
            page: const OrderViewScreen(),
          ),
          if (logInController.isAdmin == true)
            createDrawerItem(
              title: 'Company Settings',
              page: const CompanySettingsScreen(),
            ),
          createDrawerItem(
            title: 'POS',
            page: const PosScreen(),
          ),
          createDrawerItem(
            title: 'Log Out',
            page: LoginScreen(),
          ),
        ],
      ),
    );
  }
}
