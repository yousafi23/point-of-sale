import 'package:flutter/material.dart';
import 'package:point_of_sale_app/admin/add_user_form.dart';
import 'package:point_of_sale_app/admin/user_data_table.dart';
import 'package:point_of_sale_app/general/drawer.dart';
import 'package:point_of_sale_app/general/my_custom_appbar.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ReusableDrawer(
        title: 'Users',
        currentPage: UsersScreen(),
      ),
      appBar: myCustomAppBar(
        "Users",
        const Color.fromARGB(255, 116, 2, 122),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: const SingleChildScrollView(child: UserDataTable())),
            FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AddUser()),
                );
              },
              backgroundColor: Colors.purple.shade600,
              label: const Text("Add"),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
