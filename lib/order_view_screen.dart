// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/order_item_model.dart';
import 'package:point_of_sale_app/database/order_model.dart';
import 'package:point_of_sale_app/general/drawer.dart';
import 'package:point_of_sale_app/general/my_custom_appbar.dart';

class OrderViewScreen extends StatefulWidget {
  const OrderViewScreen({super.key});

  @override
  _OrderViewScreenState createState() => _OrderViewScreenState();
}

class _OrderViewScreenState extends State<OrderViewScreen> {
  List<OrderModel> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrdersData();
  }

  Future<void> _loadOrdersData() async {
    final orders = await DatabaseHelper.instance
        .getOrders(orderBy: 'orderDate DESC', limit: 10);

    setState(() {
      _orders = orders!;
    });
  }

  String calculateTotal(OrderItemModel item) {
    if (item.itemDiscount != 0) {
      var discountprice = item.price * (item.itemDiscount! / 100);
      var finalPrice = item.quantity * (item.price - discountprice);
      return '${item.price} x ${item.quantity} - ${item.itemDiscount}% = ${finalPrice.toStringAsFixed(1)}';
    } else {
      return '${item.price} x ${item.quantity} = ${item.price * item.quantity}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ReusableDrawer(
        title: 'Orders',
        currentPage: OrderViewScreen(),
      ),
      appBar: myCustomAppBar(
        "Orders",
        const Color.fromARGB(255, 2, 122, 4),
      ),
      body: _orders.isEmpty
          ? const Center(
              child: Text('No Orders yet'),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 410.0, // maximum width
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                ),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  List<Map<String, dynamic>> orderItemsList =
                      List<Map<String, dynamic>>.from(
                          jsonDecode(order.orderItemsList));

                  double gstAmount = order.total * (order.gstPercent / 100);
                  double discountAmount =
                      order.total * (order.discountPercent / 100);

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    color: Colors.green.shade100,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${order.orderId}',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    DateFormat('dd-MM-yy - h:mm a')
                                        .format(order.orderDate),
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Column(
                              children: orderItemsList.map((temp) {
                                OrderItemModel item =
                                    OrderItemModel.fromMap(temp);
                                String str = calculateTotal(item);

                                return Tooltip(
                                  decoration: BoxDecoration(
                                      color: Colors.green[700],
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5))),
                                  message: '${item.prodName}\n$str',
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Text(
                                          item.prodName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: item.itemDiscount != 0
                                                  ? Colors.red
                                                  : null),
                                        ),
                                      ),
                                      Text(
                                        str,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: item.itemDiscount != 0
                                                ? Colors.red
                                                : null),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const Divider(color: Color.fromARGB(255, 1, 77, 4)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total'),
                                Text(order.total.toStringAsFixed(1))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('GST'),
                                Text(
                                    '${order.gstPercent}% = ${gstAmount.toStringAsFixed(1)}')
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Discount '),
                                Text(
                                  '${order.discountPercent}% = - ${discountAmount.toStringAsFixed(1)}',
                                  style: TextStyle(
                                      color: order.discountPercent != 0
                                          ? Colors.red
                                          : null),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Service Charges'),
                                Text(order.serviceCharges.toString())
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(order.grandTotal.toString(),
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
