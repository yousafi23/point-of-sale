import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/order_model.dart';
import 'package:point_of_sale_app/general/drawer.dart';
import 'package:point_of_sale_app/general/my_custom_appbar.dart';

class OrderViewScreen extends StatefulWidget {
  const OrderViewScreen({Key? key}) : super(key: key);

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
    final orders = await DatabaseHelper.instance.getAllOrders();

    setState(() {
      _orders = orders!;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_orders.isEmpty) {
      return Scaffold(
        drawer: const ReusableDrawer(
          title: 'Orders',
          currentPage: OrderViewScreen(),
        ),
        appBar: myCustomAppBar(
          "Orders",
          const Color.fromARGB(255, 2, 122, 4),
        ),
        body: const Center(
          child: Text('No Orders yet'),
        ),
      );
    }

    return Scaffold(
      drawer: const ReusableDrawer(
        title: 'Orders',
        currentPage: OrderViewScreen(),
      ),
      appBar: myCustomAppBar(
        "Orders",
        const Color.fromARGB(255, 2, 122, 4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            // crossAxisCount: 4,
            maxCrossAxisExtent: 350.0, // maximum width
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            // childAspectRatio: 1,
          ),
          itemCount: _orders.length,
          itemBuilder: (context, index) {
            final order = _orders[index];
            List<Map<String, dynamic>> orderItemsList =
                List<Map<String, dynamic>>.from(
                    jsonDecode(order.orderItemsList));

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              color: Colors.green.shade100,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ID : ${order.orderId}',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        Text(DateFormat('EEE, dd-MMM-yy \n h:mm a')
                            .format(order.orderDate)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: orderItemsList.map((item) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${item['prodName']}'),
                            Text(
                              '${item['price']} x ${item['quantity']} = ${item['price'] * item['quantity']}',
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Text('= ${order.grandTotal.toString()}',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
