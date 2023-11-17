import 'package:flutter/material.dart';

import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/order_item_model.dart';
import 'package:point_of_sale_app/general/my_custom_snackbar.dart';

// ignore: must_be_immutable
class PosTableWidget extends StatefulWidget {
  PosTableWidget(
      {super.key, required this.productsData, required this.reloadCallback});

  final Function reloadCallback;
  List<Map<String, dynamic>> productsData;

  @override
  _PosTableWidgetState createState() => _PosTableWidgetState();
}

class _PosTableWidgetState extends State<PosTableWidget> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final database = await DatabaseHelper.instance.database;
    final result = await database?.query('Products');
    setState(() {
      widget.productsData = result!;
    });
    // print('Product _loadData()');
  }

  @override
  Widget build(BuildContext context) {
    // print("products count:${widget.productsData.length}");
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: DataTable(
            columnSpacing: 30.0,
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Barcode')),
              DataColumn(label: Text('Unit Price')),
              DataColumn(label: Text('Stock')),
              DataColumn(label: Text('')),
            ],
            rows: widget.productsData.map<DataRow>((Map<String, dynamic> row) {
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
                  DataCell(Text(row['unitPrice'].toString())),
                  DataCell(Text(row['stock'].toString())),
                  DataCell(
                    GestureDetector(
                      child: const Icon(Icons.add),
                      onTap: () async {
                        OrderItemModel orderItemModel = OrderItemModel(
                            productId: row['productId'],
                            prodName: row['prodName'],
                            price: row['unitPrice'],
                            quantity: 1);

                        int? productCount = await DatabaseHelper.instance
                            .productCount(row['productId']);

                        if (productCount! < 1) {
                          await DatabaseHelper.instance.insertRecord(
                              'OrderItems', orderItemModel.toMap());
                          await DatabaseHelper.instance
                              .updateStock(row['productId'], true);

                          widget.reloadCallback(); // Trigger reload

                          ScaffoldMessenger.of(context).showSnackBar(
                              myCustomSnackBar(
                                  message: '${row['prodName']} Added',
                                  warning: false));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              myCustomSnackBar(
                                  message: 'Product Already in Order List!',
                                  warning: true));
                        }
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
