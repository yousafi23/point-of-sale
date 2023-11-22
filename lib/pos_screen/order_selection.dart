// ignore_for_file: use_build_context_synchronously

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
  double total = 0.0;
  double gstAmount = 0.0;
  double discountAmount = 0.0;
  int orderItemId = 0;
  int serviceCharges = 0;
  int gst = 0;
  int discount = 0;
  // final discount = TextEditingController();
  final discountCont = TextEditingController();
  final serviceChargesCont = TextEditingController();

  // int discount = int.parse(discountCont.text);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final database = await DatabaseHelper.instance.database;
    final result = await database?.query('OrderItems');
    final result1 =
        await DatabaseHelper.instance.getRecord('Company', 'companyId=?', 0);
    setState(() {
      widget.orderItems = result!;
      calculateGrandTotal();
      serviceCharges = result1![0]['serviceCharges'] as int;
      gst = result1[0]['gst'] as int;
      discount = result1[0]['discount'] as int;
    });
    discountCont.text = discount.toString();
    serviceChargesCont.text = serviceCharges.toString();
  }

  void calculateGrandTotal() {
    grandTotal = 0.0;
    total = 0.0;

    // Iterate through each order item and update grandTotal
    for (var item in widget.orderItems) {
      int itemTotal =
          item['quantity'] * item['price']; // Calculate total for each item
      total += itemTotal; // Add item total to grandTotal
    }

    gstAmount = total * (gst / 100);
    discountAmount = total * (discount / 100);
    grandTotal = total + serviceCharges + gstAmount - discountAmount;
    setState(() {});
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
                      // print('add btn');

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

                          // print('before=${widget.orderItems.length}');

                          await widget.quantityCallback(
                              row['productId'], false); //triger

                          // print('after=${widget.orderItems.length}');

                          // print('min btn');
                        } else {
                          await DatabaseHelper.instance.deleteRecord(
                              dbTable: "OrderItems",
                              where: 'orderItemId=?',
                              id: row['orderItemId']);

                          await widget.quantityCallback(
                              row['productId'], false); //triger
                          // print('deleted');

                          myCustomSnackBar(
                              message: 'Product Removed',
                              warning: true,
                              context: context);
                        }

                        await _loadData();
                        // print('loaded aft del/min');
                      }),
                ),
              ],
            );
          }).toList(),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: SizedBox(
            width: 250,
            height: 130,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total'),
                    Text('Rs ${total.toString()}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Service Charges'),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Rs '),
                        SizedBox(
                          width: 30,
                          height: 25,
                          child: TextField(
                            controller: serviceChargesCont,
                            onChanged: (value) {
                              serviceCharges = int.tryParse(value) ?? 0;
                              calculateGrandTotal();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('GST'),
                    Text('$gst% = ${gstAmount.toStringAsFixed(1)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Discount'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 30,
                          height: 25,
                          child: TextField(
                            controller: discountCont,
                            onChanged: (value) {
                              int disVal = int.tryParse(value) ?? 0;
                              if (disVal <= 100) {
                                discount = disVal;
                              } else {
                                discountCont.text = '';
                                myCustomSnackBar(
                                    context: context,
                                    message:
                                        'Discount can NOT be greater than 100',
                                    warning: true);
                              }
                              calculateGrandTotal();
                            },
                          ),
                        ),
                        Text('% = ${discountAmount.toStringAsFixed(1)}'),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Grand Total',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Rs ${grandTotal.toStringAsFixed(1)}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
        FloatingActionButton.extended(
          onPressed: () async {
            if (total > 0) {
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

                myCustomSnackBar(
                  message:
                      'Order Placed!\t\t\t\t Total: ${grandTotal.toStringAsFixed(1)}',
                  warning: false,
                  context: context,
                );
              }
              await _loadData();
            } else {
              myCustomSnackBar(
                message: 'Can NOT place empty Order!',
                warning: true,
                context: context,
              );
            }
          },
          label: const Text('Place Order'),
        )
      ],
    );
  }
}
