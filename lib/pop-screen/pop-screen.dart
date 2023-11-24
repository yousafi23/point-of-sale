import 'package:flutter/material.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/general/drawer.dart';
import 'package:point_of_sale_app/general/my_custom_appbar.dart';
import 'package:point_of_sale_app/pop-screen/pop-table.dart';
import 'package:point_of_sale_app/pop-screen/prurchase_selection.dart';

class PopScreen extends StatefulWidget {
  const PopScreen({super.key});

  @override
  State<PopScreen> createState() => _PopScreenState();
}

class _PopScreenState extends State<PopScreen> {
  List<Map<String, dynamic>> purchaseProducts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ReusableDrawer(
        title: 'POP',
        currentPage: PopScreen(),
      ),
      appBar: myCustomAppBar(
        "POP",
        const Color.fromARGB(255, 2, 122, 4),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PopTableWidget(
                  reloadCallback: () async {
                    final database = await DatabaseHelper.instance.database;
                    final result = await database?.query('PurchaseItems');

                    setState(() {
                      purchaseProducts = result!;
                    });
                  },
                ),
                PurchaseSelection(purchaseItems: purchaseProducts)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
