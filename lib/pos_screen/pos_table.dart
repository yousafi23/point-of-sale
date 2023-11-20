// ignore_for_file: use_build_context_synchronously, must_be_immutable, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/order_item_model.dart';
import 'package:point_of_sale_app/general/my_custom_snackbar.dart';

class PosTableWidget extends StatefulWidget {
  PosTableWidget({
    super.key,
    required this.productsData,
    required this.reloadCallback,
  });

  final Function reloadCallback;
  List<Map<String, dynamic>> productsData;

  @override
  _PosTableWidgetState createState() => _PosTableWidgetState();
}

class _PosTableWidgetState extends State<PosTableWidget> {
  late List<String> categories;

  @override
  void initState() {
    super.initState();
    categories = [];
    _loadData();
  }

  Future<void> _loadData() async {
    final database = await DatabaseHelper.instance.database;
    final result = await database?.query('Products');
    setState(() {
      widget.productsData = result!;
      categories = getUniqueCategories();
    });
  }

  List<String> getUniqueCategories() {
    return widget.productsData
        .map<String>((product) => product['category'] as String)
        .toSet()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .4,
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(
            categories.length,
            (index) {
              final category = categories[index];
              final categoryProducts = widget.productsData
                  .where((product) => product['category'] == category)
                  .toList();

              return CategoryWidget(
                categoryName: category,
                products: categoryProducts,
                reloadCallback: widget.reloadCallback,
              );
            },
          ),
        ),
      ),
    );
  }
}

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({
    Key? key,
    required this.categoryName,
    required this.products,
    required this.reloadCallback,
  }) : super(key: key);

  final String categoryName;
  final List<Map<String, dynamic>> products;
  final Function reloadCallback;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.green.shade200,
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                categoryName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        PosTableCategory(
          categoryProducts: products,
          reloadCallback: reloadCallback,
        ),
      ],
    );
  }
}

class PosTableCategory extends StatelessWidget {
  const PosTableCategory({
    super.key,
    required this.categoryProducts,
    required this.reloadCallback,
  });

  final List<Map<String, dynamic>> categoryProducts;
  final Function reloadCallback;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columnSpacing: 30.0,
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Barcode')),
        DataColumn(label: Text('Stock')),
        DataColumn(label: Text('Unit Price')),
        DataColumn(label: Text('')),
      ],
      rows: categoryProducts.map<DataRow>((Map<String, dynamic> row) {
        return DataRow(
          cells: [
            DataCell(Text(row['productId'].toString())),
            DataCell(SizedBox(
                width: 100,
                child: Text(
                  row['prodName'],
                  maxLines: 2,
                ))),
            DataCell(Text(row['barCode'].toString())),
            DataCell(Text(row['stock'].toString())),
            DataCell(Text(row['unitPrice'].toString())),
            DataCell(
              GestureDetector(
                child: const Icon(Icons.add),
                onTap: () async {
                  OrderItemModel orderItemModel = OrderItemModel(
                    productId: row['productId'],
                    prodName: row['prodName'],
                    price: row['unitPrice'],
                    quantity: 1,
                  );

                  int? productCount = await DatabaseHelper.instance
                      .productCount(row['productId']);

                  if (productCount! < 1) {
                    await DatabaseHelper.instance
                        .insertRecord('OrderItems', orderItemModel.toMap());

                    await DatabaseHelper.instance
                        .updateStock(row['productId'], true);

                    reloadCallback(); // Trigger reload

                    myCustomSnackBar(
                        message: '${row['prodName']} Added',
                        warning: false,
                        context: context);
                  } else {
                    myCustomSnackBar(
                        message: 'Product Already in Order List!',
                        warning: true,
                        context: context);
                  }
                },
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
