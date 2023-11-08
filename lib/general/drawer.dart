import 'package:flutter/material.dart';
import 'package:point_of_sale_app/admin/admin_screen.dart';
import 'package:point_of_sale_app/admin/users_screen.dart';
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
            title: 'Home',
            page: const ProductsScreen(),
          ),
          _createDrawerItem(
            title: 'Users',
            page: const UsersScreen(),
          ),
          _createDrawerItem(
            title: 'Change Company',
            page: const PosScreen(),
          ),
          _createDrawerItem(
            title: 'POS',
            page: const PosScreen(),
          ),
        ],
      ),
    );
  }
}
