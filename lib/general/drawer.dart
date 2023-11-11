import 'package:flutter/material.dart';
import 'package:point_of_sale_app/admin/ingredients_screen.dart';
import 'package:point_of_sale_app/admin/products_screen.dart';
import 'package:point_of_sale_app/admin/users_screen.dart';
import 'package:point_of_sale_app/company_settings.dart';
import 'package:point_of_sale_app/login_screen.dart';
import 'package:point_of_sale_app/pos_screen/pos_screen.dart';

class ReusableDrawer extends StatelessWidget {
  final String title;
  final Widget currentPage;

  const ReusableDrawer({
    Key? key,
    required this.title,
    required this.currentPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ListTile _createDrawerItem({
      required String title,
      required Widget page,
    }) {
      // if (page == CompanySettingsScreen()) {
      //   Future<CompanyModel?> companyModel =
      //       DatabaseHelper.instance.loadCompanyData(0);
      //   return ListTile(
      //     title: Text(title),
      //     onTap: () {
      //       Navigator.of(context).push(
      //         MaterialPageRoute(
      //             builder: (context) =>
      //                 CompanySettingsScreen(companyModel: )),
      //       );
      //     },
      //   );
      // } else {
      //   return ListTile(
      //     title: Text(title),
      //     onTap: () {
      //       Navigator.of(context).push(
      //         MaterialPageRoute(builder: (context) => page),
      //       );
      //     },
      //   );
      // }

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
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Drawer Header'),
          ),
          _createDrawerItem(
            title: 'Products',
            page: const ProductsScreen(),
          ),
          _createDrawerItem(
            title: 'Ingredients',
            page: const IngredientsScreen(),
          ),
          _createDrawerItem(
            title: 'Users',
            page: const UsersScreen(),
          ),
          _createDrawerItem(
            title: 'Company Settings',
            page: CompanySettingsScreen(),
          ),
          _createDrawerItem(
            title: 'POS',
            page: const PosScreen(),
          ),
          _createDrawerItem(
            title: 'Log Out',
            page: LoginScreen(),
          ),
        ],
      ),
    );
  }
}
