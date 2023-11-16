import 'package:flutter/material.dart';
import 'package:point_of_sale_app/admin/add_products_form.dart';
import 'package:point_of_sale_app/admin/products_data_table.dart';
import 'package:point_of_sale_app/general/drawer.dart';
import 'package:point_of_sale_app/general/my_custom_appbar.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ReusableDrawer(
        title: 'Products',
        currentPage: ProductsScreen(),
      ),
      appBar: myCustomAppBar(
        "Products",
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
