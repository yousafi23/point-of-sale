import 'package:flutter/material.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/order_model.dart';
import 'package:point_of_sale_app/general/my_custom_snackbar.dart';

class OrderSelection extends StatefulWidget {
  const OrderSelection({super.key});

  @override
  State<OrderSelection> createState() => _OrderSelectionState();
}

final GlobalKey<_OrderSelectionState> orderSelectionKey =
    GlobalKey<_OrderSelectionState>();

class _OrderSelectionState extends State<OrderSelection> {
  List<Map<String, dynamic>> OrderItems = [];
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
      OrderItems = result!;
      calculateGrandTotal();
    });
  }

  // Add this function to calculate the grand total
  void calculateGrandTotal() {
    grandTotal = OrderItems.fold<double>(0.0, (sum, item) {
      return sum + (item['quantity'] * item['price']);
    });
  }

  // Add this function to trigger data reload
  void reloadData() {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () async {
            await DatabaseHelper.instance.truncateTable('OrderItems');
            _loadData();
          },
          child: const Text("Truncate orderItems "),
        ),
        TextButton(
          onPressed: () async {
            while (true) {
              await _loadData();
            }
          },
          child: const Text("Reload"),
        ),
        DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Unit Price')),
            DataColumn(label: Text('Qty')),
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('')),
            DataColumn(label: Text('')),
            DataColumn(label: Text('')),
          ],
          rows: OrderItems.map<DataRow>((Map<String, dynamic> row) {
            return DataRow(
              cells: [
                DataCell(Text(row['prodName'])),
                DataCell(Text(row['price'].toString())),
                DataCell(Text(row['quantity'].toString())),
                DataCell(Text((row['quantity'] * row['price']).toString())),
                DataCell(
                  GestureDetector(
                    child: const Icon(Icons.add),
                    onTap: () async {
                      await DatabaseHelper.instance
                          .changeQuantity(row['orderItemId'], false);

                      _loadData();
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
                        } else {
                          await DatabaseHelper.instance.deleteRecord(
                              dbTable: "OrderItems",
                              where: 'orderItemId=?',
                              id: row['orderItemId']);

                          ScaffoldMessenger.of(context).showSnackBar(
                              myCustomSnackBar(
                                  message: 'Product Removed', warning: true));
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
                          dbTable: "OrderItems",
                          where: 'orderItemId=?',
                          id: row['orderItemId']);
                      await _loadData();
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        Text('Grand Total:\t\t\tRs ${grandTotal.toStringAsFixed(1)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        FloatingActionButton.extended(
            onPressed: () {
              // print(currentdate);

              // OrderModel orderModel = OrderModel(
              //     orderDate: DateTime.now(),
              //     grandTotal: grandTotal,
              //     orderItemId: row['orderItemId']);
              // DatabaseHelper.instance.insertRecord('Orders', )
            },
            label: const Text('Place Order'))
      ],
    );
  }
}
