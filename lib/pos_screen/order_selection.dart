import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/order_model.dart';
import 'package:point_of_sale_app/general/confirmation_alert.dart';
import 'package:point_of_sale_app/general/my_custom_snackbar.dart';

// ignore: must_be_immutable
class OrderSelection extends StatefulWidget {
  OrderSelection(
      {super.key, required this.orderItems, required this.quantityCallback});

  final Function quantityCallback;
  List<Map<String, dynamic>> orderItems;

  @override
  State<OrderSelection> createState() => _OrderSelectionState();
}

class _OrderSelectionState extends State<OrderSelection> {
  double grandTotal = 0.0;
  int orderItemId = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final database = await DatabaseHelper.instance.database;
    final result = await database?.query('OrderItems');
    setState(() {
      widget.orderItems = result!;
      calculateGrandTotal();
      print('set from order');
    });
    print('Order _loadData()');
  }

  void calculateGrandTotal() {
    grandTotal = widget.orderItems.fold<double>(0.0, (sum, item) {
      return sum + (item['quantity'] * item['price']);
    });
  }

  @override
  Widget build(BuildContext context) {
    calculateGrandTotal();
    return Column(
      children: [
        DataTable(
          columnSpacing: 30.0,
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Unit Price')),
            DataColumn(label: Text('Qty')),
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('')),
            DataColumn(label: Text('')),
            // DataColumn(label: Text('')),
          ],
          rows: widget.orderItems.map<DataRow>((Map<String, dynamic> row) {
            return DataRow(
              cells: [
                DataCell(SizedBox(
                    width: 100,
                    child: Text(
                      row['prodName'],
                      maxLines: 2,
                    ))),
                DataCell(Text(row['price'].toString())),
                DataCell(Text(row['quantity'].toString())),
                DataCell(Text((row['quantity'] * row['price']).toString())),
                DataCell(
                  GestureDetector(
                    child: const Icon(Icons.add),
                    onTap: () async {
                      await DatabaseHelper.instance
                          .changeQuantity(row['orderItemId'], false);

                      await widget.quantityCallback(
                          row['productId'], true); //triger
                      print('add btn');

                      await _loadData();
                    },
                  ),
                ),
                DataCell(
                  GestureDetector(
                      child: const Icon(Icons.minimize),
                      onTap: () async {
                        var qty = await DatabaseHelper.instance
                            .getQuantity(row['orderItemId']);

                        if (qty > 1) {
                          await DatabaseHelper.instance
                              .changeQuantity(row['orderItemId'], true);

                          print('before=${widget.orderItems.length}');

                          await widget.quantityCallback(
                              row['productId'], false); //triger

                          print('after=${widget.orderItems.length}');

                          print('min btn');
                        } else {
                          await DatabaseHelper.instance.deleteRecord(
                              dbTable: "OrderItems",
                              where: 'orderItemId=?',
                              id: row['orderItemId']);

                          await widget.quantityCallback(
                              row['productId'], false); //triger
                          print('deleted');

                          ScaffoldMessenger.of(context).showSnackBar(
                              myCustomSnackBar(
                                  message: 'Product Removed', warning: true));
                        }

                        await _loadData();
                        // print('loaded aft del/min');
                      }),
                ),
                // DataCell(
                //   GestureDetector(
                //     child: const Icon(Icons.delete,
                //         color: Color.fromARGB(255, 255, 0, 0)),
                //     onTap: () async {
                //       await DatabaseHelper.instance.deleteRecord(
                //           dbTable: "OrderItems",
                //           where: 'orderItemId=?',
                //           id: row['orderItemId']);
                //       await _loadData();
                //     },
                //   ),
                // ),
              ],
            );
          }).toList(),
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Text('Grand Total:\t\t\tRs ${grandTotal.toStringAsFixed(1)}',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        FloatingActionButton.extended(
          onPressed: () async {
            OrderModel orderModel = OrderModel(
                orderDate: DateTime.now(),
                grandTotal: grandTotal,
                orderItemsList: jsonEncode(widget.orderItems));

            // print('Model=${orderModel.toMap()}');
            // print('str=${widget.orderItems}');
            final bool confirmed = await showPlaceOrderConfirmation(context);
            if (confirmed) {
              await DatabaseHelper.instance
                  .insertRecord('Orders', orderModel.toMap());
              await DatabaseHelper.instance.truncateTable('OrderItems');

              ScaffoldMessenger.of(context).showSnackBar(myCustomSnackBar(
                message: 'Order Placed!\t\t\t\t Total: $grandTotal',
                warning: false,
              ));
            }

            await _loadData();
          },
          label: const Text('Place Order'),
        )
      ],
    );
  }
}
