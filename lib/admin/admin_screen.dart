import 'package:flutter/material.dart';
import 'package:point_of_sale_app/admin/add_products_form.dart';
import 'package:point_of_sale_app/admin/products_data_table.dart';
import 'package:point_of_sale_app/general/drawer.dart';
import 'package:point_of_sale_app/general/my_custom_appbar.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ReusableDrawer(
        title: 'Home',
        currentPage: AdminScreen(),
      ),
      appBar: myCustomAppBar(
        "Admin panel",
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
                child: const SingleChildScrollView(child: ProductsDataTable())),
            FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AddProduct()),
                );
              },
              label: const Text("Add"),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
