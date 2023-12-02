import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/purchase_model.dart';
import 'package:point_of_sale_app/general/drawer.dart';
import 'package:point_of_sale_app/general/my_custom_appbar.dart';

class PurchaseHistory extends StatefulWidget {
  const PurchaseHistory({super.key});

  @override
  State<PurchaseHistory> createState() => _PurchaseHistoryState();
}

class _PurchaseHistoryState extends State<PurchaseHistory> {
  List<PurchaseModel> purchases = [];

  @override
  void initState() {
    super.initState();
    _loadOrdersData();
  }

  Future<void> _loadOrdersData() async {
    final database = await DatabaseHelper.instance.database;
    final result = await database?.query('Purchases');

    setState(() {
      if (result != null) {
        for (var purchase in result) {
          purchases.add(PurchaseModel.fromMap(purchase));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (purchases.isEmpty) {
      return Scaffold(
        drawer: const ReusableDrawer(
          title: 'Purchase History',
          currentPage: PurchaseHistory(),
        ),
        appBar: myCustomAppBar(
          "Purchase History",
          const Color.fromARGB(255, 2, 122, 4),
        ),
        body: const Center(
          child: Text('No Purchases yet'),
        ),
      );
    }

    return Scaffold(
      drawer: const ReusableDrawer(
        title: 'Purchase History',
        currentPage: PurchaseHistory(),
      ),
      appBar: myCustomAppBar(
        "Purchase History",
        const Color.fromARGB(255, 2, 122, 4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SizedBox(
          width: 400,
          child: ListView.builder(
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              final purchase = purchases[index];
              List<Map<String, dynamic>> purchaseItemsList =
                  List<Map<String, dynamic>>.from(
                      jsonDecode(purchase.purchaseItemsList));

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.green.shade100,
                child: ExpansionTile(
                  textColor: Colors.green.shade800,
                  iconColor: Colors.green.shade800,
                  shape: const Border(),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ID: ${purchase.purchaseId}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(
                        DateFormat('dd-MMM-yy h:mm a')
                            .format(purchase.purchaseDate),
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text('Total: ${purchase.grandTotal.toString()}'),
                    ],
                  ),
                  children: [
                    for (var item in purchaseItemsList)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 25, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item['name']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${item['price']} x ${item['quantity']} = ${item['price'] * item['quantity']}',
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
