// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/purchase_model.dart';
import 'package:point_of_sale_app/database/purhcase_item_model.dart';
import 'package:point_of_sale_app/general/drawer.dart';
import 'package:point_of_sale_app/general/my_custom_appbar.dart';
import 'package:point_of_sale_app/general/my_custom_snackbar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xl;

class PieData {
  PieData(this.name, this.totalPurchasedValue, this.totalQty);
  final String name;
  final num totalPurchasedValue;
  final num totalQty;
}

class PurchaseHistory extends StatefulWidget {
  const PurchaseHistory({super.key});

  @override
  State<PurchaseHistory> createState() => _PurchaseHistoryState();
}

class _PurchaseHistoryState extends State<PurchaseHistory> {
  List<PurchaseModel> purchases = [];
  String orderByField = 'purchaseDate';
  String sortByFeild = 'DESC';
  DateTime toDate = DateTime.now();
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
  List<String> dropDownItemsList = [
    'purchaseDate',
    'grandTotal',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final database = await DatabaseHelper.instance.database;
    final result = await database?.query('Purchases',
        orderBy: '$orderByField $sortByFeild',
        where: 'purchaseDate BETWEEN ? AND ?',
        whereArgs: [fromDate.toString(), toDate.toString()]);

    purchases = [];
    setState(() {
      if (result != null) {
        for (var purchase in result) {
          purchases.add(PurchaseModel.fromMap(purchase));
        }
      }
    });
  }

  String formatFieldName(String input) {
    String str = input.replaceAllMapped(
      RegExp(r'(^|(?<=[a-z]))[A-Z]'),
      (match) => (match.group(1) != null ? ' ' : '') + match.group(0)!,
    );
    str = str.replaceRange(0, 1, str[0].toUpperCase());
    return str;
  }

  List<PieData> groupByProducts() {
    List<PieData> groupedList = [];
    Map<String, Map<String, dynamic>> groupedItems = {};

    for (var purchase in purchases) {
      List<Map<String, dynamic>> purchaseItemsList =
          List<Map<String, dynamic>>.from(
              jsonDecode(purchase.purchaseItemsList));

      for (var item in purchaseItemsList) {
        PurchaseItemModel purchaseItem = PurchaseItemModel.fromMap(item);

        // Check if the product name is already in the grouped map
        if (groupedItems.containsKey(purchaseItem.name)) {
          // If yes, update the existing entry
          groupedItems[purchaseItem.name]!['price'] +=
              purchaseItem.price * purchaseItem.quantity;
          groupedItems[purchaseItem.name]!['quantity'] += purchaseItem.quantity;
        } else {
          // If not, create a new entry in the grouped map
          groupedItems[purchaseItem.name] = {
            'price': purchaseItem.price * purchaseItem.quantity,
            'quantity': purchaseItem.quantity,
          };
        }
      }
    }

    groupedItems.forEach((prodName, data) {
      groupedList.add(PieData(prodName, data['price'], data['quantity']));
    });
    return groupedList;
  }

  Future<void> exportAsExcel(
      List<PurchaseModel> purchases, BuildContext context) async {
    final xl.Workbook workbook = xl.Workbook();
    final xl.Worksheet sheet = workbook.worksheets[0];

    List<String> headings = [
      'purchaseId',
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
      Map<String, dynamic> purchaseMap = purchase.toMap();
      for (int colIndex = 0; colIndex < headings.length; colIndex++) {
        sheet.getRangeByIndex(rowIndex + 2, colIndex + 1).setText(
              purchaseMap[headings[colIndex]].toString(),
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
        final String fileName =
            '$path/Purchases History ${DateFormat('d_MMM_yyyy').format(fromDate)} To ${DateFormat('d_MMM_yyyy').format(toDate)}.xlsx';
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
                            Text(purchase.grandTotal.toString(),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
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
            const SizedBox(width: 25),
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.green.shade50,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(90, 0, 90, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sort By\t'),
                        SizedBox(
                          height: 20,
                          child: DropdownButton<String>(
                            underline: const SizedBox(),
                            focusColor: Colors.transparent,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            value: orderByField,
                            onChanged: (value) {
                              setState(() {
                                orderByField = value!;
                                _loadData();
                              });
                            },
                            items: dropDownItemsList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(formatFieldName(value)),
                              );
                            }).toList(),
                          ),
                        ),
                        Tooltip(
                          message: 'High to Low',
                          child: GestureDetector(
                              child: const Icon(Icons.arrow_upward_rounded),
                              onTap: () {
                                setState(() {
                                  sortByFeild = 'DESC';
                                  _loadData();
                                });
                              }),
                        ),
                        Tooltip(
                          message: 'Low to High',
                          child: GestureDetector(
                              child: const Icon(Icons.arrow_downward_rounded),
                              onTap: () {
                                setState(() {
                                  sortByFeild = 'ASC';
                                  _loadData();
                                });
                              }),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 5, 5, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'from ',
                                style: TextStyle(fontSize: 12),
                              ),
                              GestureDetector(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.green.shade200,
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(2, 0, 2, 0),
                                    child: Text(
                                      DateFormat('d MMM yyyy').format(fromDate),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  fromDate = (await showDatePicker(
                                      context: context,
                                      initialDate: fromDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now()))!;
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 15, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'To ',
                                style: TextStyle(fontSize: 12),
                              ),
                              GestureDetector(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.green.shade200,
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(2, 0, 2, 0),
                                    child: Text(
                                      DateFormat('d MMM yyyy').format(toDate),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  toDate = (await showDatePicker(
                                      context: context,
                                      initialDate: toDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now()))!;
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                        Tooltip(
                          message: 'Reset Filters',
                          child: GestureDetector(
                              child: const Icon(
                                Icons.refresh,
                              ),
                              onTap: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            super.widget));
                                // setState(() {});
                              }),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                            onPressed: () => _loadData(),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade500,
                                foregroundColor: Colors.white),
                            child: const Text('Filter')),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: ElevatedButton.icon(
                              onPressed: () =>
                                  exportAsExcel(purchases, context),
                              icon: const Icon(Icons.download),
                              style: ButtonStyle(
                                  overlayColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.green.shade50),
                                  foregroundColor:
                                      MaterialStateColor.resolveWith(
                                          (states) => Colors.green.shade700)),
                              label: const Text('Export as Excel')),
                        ),
                      ],
                    ),
                  ),
                ),
                purchases.isEmpty
                    ? Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.red),
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Text('No Purchases Available.',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
                          ),
                        ))
                    : SizedBox(
                        width: 750,
                        child: SfCartesianChart(
                            primaryXAxis: DateTimeAxis(
                              // minimum: fromDate.add(Duration(hours: 1)),
                              // maximum: toDate.add(Durations.extralong1),
                              dateFormat: DateFormat('d MMM'),
                            ),
                            primaryYAxis: NumericAxis(),
                            title: ChartTitle(text: 'Purchases'),
                            zoomPanBehavior: ZoomPanBehavior(
                              enablePanning: true,
                              enableDoubleTapZooming: true,
                              enablePinching: true,
                            ),
                            legend: const Legend(
                                isVisible: true,
                                position: LegendPosition.top,
                                offset: Offset(1, 1)),
                            tooltipBehavior: TooltipBehavior(
                              color: Colors.green[600],
                              duration: 5,
                              enable: true,
                              builder: (data, point, series, pointIndex,
                                  seriesIndex) {
                                return Container(
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                      '${DateFormat('d MMM yyyy h:mm a').format(point.x)}\n${point.y}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.white)),
                                );
                              },
                            ),
                            series: <LineSeries<PurchaseModel, DateTime>>[
                              LineSeries<PurchaseModel, DateTime>(
                                  name: 'Total',
                                  markerSettings: const MarkerSettings(
                                      isVisible: true, height: 4, width: 4),
                                  color: Colors.green.shade700,
                                  sortingOrder: SortingOrder.ascending,
                                  sortFieldValueMapper:
                                      (PurchaseModel data, _) =>
                                          data.purchaseDate,
                                  dataSource: purchases,
                                  xValueMapper: (PurchaseModel data, _) =>
                                      data.purchaseDate,
                                  yValueMapper: (PurchaseModel data, _) =>
                                      data.grandTotal),
                            ]),
                      ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Card(
                      color: Colors.green.shade100,
                      elevation: 0,
                      child: SizedBox(
                        width: 400,
                        child: SfCircularChart(
                          title: ChartTitle(
                            text: 'Ingredients Purchased By Quantity',
                            alignment: ChartAlignment.center,
                          ),
                          series: <CircularSeries>[
                            PieSeries<PieData, String>(
                              dataSource: groupByProducts(),
                              xValueMapper: (PieData data, _) => data.name,
                              yValueMapper: (PieData data, _) => data.totalQty,
                              dataLabelMapper: (PieData data, _) => data.name,
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                                labelPosition: ChartDataLabelPosition.outside,
                                textStyle: TextStyle(),
                                connectorLineSettings: ConnectorLineSettings(
                                    type: ConnectorType.line),
                              ),
                              explode: true,
                              explodeGesture: ActivationMode.singleTap,
                              enableTooltip: true,
                            )
                          ],
                          tooltipBehavior: TooltipBehavior(enable: true),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Card(
                      color: Colors.green.shade100,
                      elevation: 0,
                      child: SizedBox(
                        width: 400,
                        child: SfCircularChart(
                          title: ChartTitle(
                            text: 'Ingredients Purchased By Value',
                            alignment: ChartAlignment.center,
                          ),
                          series: <CircularSeries>[
                            PieSeries<PieData, String>(
                              dataSource: groupByProducts(),
                              xValueMapper: (PieData data, _) => data.name,
                              yValueMapper: (PieData data, _) =>
                                  data.totalPurchasedValue,
                              dataLabelMapper: (PieData data, _) => data.name,
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                                labelPosition: ChartDataLabelPosition.outside,
                                textStyle: TextStyle(),
                                connectorLineSettings: ConnectorLineSettings(
                                    type: ConnectorType.line),
                                // useSeriesColor: true,
                                // labelIntersectAction: LabelIntersectAction.shift,
                              ),
                              explode: true,
                              explodeGesture: ActivationMode.singleTap,
                              // groupMode: CircularChartGroupMode.point,
                              // As the grouping mode is point, 2 points will be grouped
                              // groupTo: 5,
                              enableTooltip: true,
                            )
                          ],
                          tooltipBehavior: TooltipBehavior(enable: true),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
