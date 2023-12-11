// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/purchase_model.dart';
import 'package:point_of_sale_app/database/purhcase_item_model.dart';
import 'package:point_of_sale_app/general/confirmation_alert.dart';
import 'package:point_of_sale_app/general/my_custom_snackbar.dart';

class PurchaseSelection extends StatefulWidget {
  PurchaseSelection({super.key, required this.purchaseItems});

  List<Map<String, dynamic>> purchaseItems;

  @override
  State<PurchaseSelection> createState() => _PurchaseSelectionState();
}

class _PurchaseSelectionState extends State<PurchaseSelection> {
  double grandTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final database = await DatabaseHelper.instance.database;
    final result = await database?.query('PurchaseItems');
    setState(() {
      widget.purchaseItems = result!;
      calculateGrandTotal();
    });
  }

  void calculateGrandTotal() {
    grandTotal = 0;

    // Iterate through each order item and update grandTotal
    for (var item in widget.purchaseItems) {
      int itemTotal =
          item['quantity'] * item['price']; // Calculate total for each item
      grandTotal += itemTotal; // Add item total to grandTotal
    }
    grandTotal = double.parse(grandTotal.toStringAsFixed(1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    calculateGrandTotal();
    return Column(
      children: [
        DataTable(
          headingRowColor:
              MaterialStateColor.resolveWith((states) => Colors.green.shade700),
          columnSpacing: 30.0,
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Unit Price')),
            DataColumn(label: Text('Qty')),
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('')),
            DataColumn(label: Text('')),
            DataColumn(label: Text('')),
          ],
          rows: widget.purchaseItems.map((Map<String, dynamic> row) {
            PurchaseItemModel purchaseItemModel =
                PurchaseItemModel.fromMap(row);

            return DataRow(
              cells: [
                DataCell(Text(purchaseItemModel.name)),
                DataCell(Text(purchaseItemModel.price.toString())),
                DataCell(Text(purchaseItemModel.quantity.toString())),
                DataCell(Text(
                    (purchaseItemModel.price * purchaseItemModel.quantity)
                        .toString())),
                DataCell(
                  GestureDetector(
                    child: const Icon(Icons.add),
                    onTap: () async {
                      await DatabaseHelper.instance.changeIngredientQuantity(
                          purchaseItemModel.purchaseItemId!, false);
                      _loadData();
                    },
                  ),
                ),
                DataCell(
                  GestureDetector(
                      child: const Icon(Icons.minimize),
                      onTap: () async {
                        var qty = await DatabaseHelper.instance
                            .getIngredientQuantity(
                                purchaseItemModel.purchaseItemId!);

                        if (qty > 1) {
                          await DatabaseHelper.instance
                              .changeIngredientQuantity(
                                  purchaseItemModel.purchaseItemId!, true);
                        } else {
                          await DatabaseHelper.instance.deleteRecord(
                              dbTable: "PurchaseItems",
                              where: 'purchaseItemId=?',
                              id: purchaseItemModel.purchaseItemId!);

                          myCustomSnackBar(
                              message: 'Ingredient Removed',
                              warning: true,
                              context: context);
                        }

                        await _loadData();
                      }),
                ),
                DataCell(
                  GestureDetector(
                    child: const Icon(Icons.delete,
                        color: Color.fromARGB(255, 255, 0, 0)),
                    onTap: () async {
                      await DatabaseHelper.instance.deleteRecord(
                          dbTable: "PurchaseItems",
                          where: 'purchaseItemId=?',
                          id: purchaseItemModel.purchaseItemId!);
                      await _loadData();
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: SizedBox(
            width: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Grand Total:',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('$grandTotal',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold))
              ],
            ),
          ),
        ),
        FloatingActionButton.extended(
          onPressed: () async {
            if (grandTotal > 0) {
              PurchaseModel purchaseModel = PurchaseModel(
                  purchaseDate: DateTime.now(),
                  grandTotal: grandTotal,
                  purchaseItemsList: jsonEncode(widget.purchaseItems));

              final bool confirmed = await showPlaceOrderConfirmation(context);
              if (confirmed) {
                await DatabaseHelper.instance
                    .insertRecord('Purchases', purchaseModel.toMap());
                await DatabaseHelper.instance.truncateTable('PurchaseItems');

                myCustomSnackBar(
                  message: 'Purchase Added!\t\t\t\t Total: $grandTotal',
                  warning: false,
                  context: context,
                );
              }
              await _loadData();
            } else {
              myCustomSnackBar(
                message: 'List is Empty!',
                warning: true,
                context: context,
              );
            }
          },
          backgroundColor: Colors.green.shade600,
          label: const Text('Add to Purchase'),
        )
      ],
    );
  }
}
