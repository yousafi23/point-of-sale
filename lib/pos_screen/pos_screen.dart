import 'package:flutter/material.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/general/drawer.dart';
import 'package:point_of_sale_app/general/my_custom_appbar.dart';
import 'package:point_of_sale_app/pos_screen/order_selection.dart';
import 'package:point_of_sale_app/pos_screen/pos_table.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  List<Map<String, dynamic>> productsData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ReusableDrawer(
        title: 'POS',
        currentPage: PosScreen(),
      ),
      appBar: myCustomAppBar(
        "POS",
        const Color.fromARGB(255, 2, 122, 4),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                child: PosTableWidget(
                  reloadCallback: () async {
                    final database = await DatabaseHelper.instance.database;
                    final result = await database?.query('OrderItems');
                    setState(() {
                      productsData = result!;
                    });
                  },
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [OrderSelection(orderItems: productsData)],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
