// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/purchase_model.dart';
import 'package:point_of_sale_app/general/drawer.dart';
import 'package:point_of_sale_app/general/my_custom_appbar.dart';
import 'package:point_of_sale_app/general/my_custom_snackbar.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xl;

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
    _loadData();
  }

  Future<void> _loadData() async {
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

  Future<void> exportAsExcel(
      List<PurchaseModel> purchases, BuildContext context) async {
    final xl.Workbook workbook = xl.Workbook();
    final xl.Worksheet sheet = workbook.worksheets[0];

    List<String> headings = [
      'purchaseDate',
      'purchaseItemsList',
      'grandTotal',
    ];

    //adding headings
    for (int colIndex = 0; colIndex < headings.length; colIndex++) {
      sheet.getRangeByIndex(1, colIndex + 1).setText(headings[colIndex]);
      //styling headings
      sheet.setColumnWidthInPixels(colIndex + 1, 100);
      xl.Style headingStyle = sheet.getRangeByIndex(1, colIndex + 1).cellStyle;
      headingStyle.bold = true;
      headingStyle.fontSize = 15;
    }

    // Add data rows
    for (int rowIndex = 0; rowIndex < purchases.length; rowIndex++) {
      PurchaseModel purchase = purchases[rowIndex];
      Map<String, dynamic> orderMap = purchase.toMap();
      for (int colIndex = 0; colIndex < headings.length; colIndex++) {
        sheet.getRangeByIndex(rowIndex + 2, colIndex + 1).setText(
              orderMap[headings[colIndex]].toString(),
            );
      }
    }

    //saving file
    final List<int> bytes = workbook.saveAsStream();
    //freeing memory
    workbook.dispose();

    final Directory? downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      try {
        String path = downloadsDir.path;
        final String fileName = '$path/Purchases.xlsx';
        final File file = File(fileName);
        await file.writeAsBytes(bytes, flush: true);
        myCustomSnackBar(
            context: context,
            message: 'Saved to:  $fileName',
            warning: false,
            duration: 6);
        OpenFile.open(fileName);
      } on Exception catch (e) {
        myCustomSnackBar(
            context: context,
            message: e.toString(),
            warning: true,
            duration: 15);
      }
    } else {
      myCustomSnackBar(
          context: context,
          message: 'Error: Unable to get the downloads directory.',
          warning: true);
    }
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .90,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${item['name']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
              child: ElevatedButton.icon(
                  onPressed: () => exportAsExcel(purchases, context),
                  icon: const Icon(Icons.download),
                  style: ButtonStyle(
                      overlayColor: MaterialStateColor.resolveWith(
                          (states) => Colors.green.shade50),
                      foregroundColor: MaterialStateColor.resolveWith(
                          (states) => Colors.green.shade700)),
                  label: const Text('Export as Excel')),
            ),
          ],
        ),
      ),
    );
  }
}
