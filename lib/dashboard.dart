// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:point_of_sale_app/database/purchase_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xl;

import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/order_item_model.dart';
import 'package:point_of_sale_app/database/order_model.dart';
import 'package:point_of_sale_app/general/drawer.dart';
import 'package:point_of_sale_app/general/my_custom_appbar.dart';
import 'package:point_of_sale_app/general/my_custom_snackbar.dart';

class NewOrdersWithProfit {
  NewOrdersWithProfit({
    required this.orderId,
    required this.orderDate,
    required this.grandTotal,
    required this.discountPercent,
    required this.profit,
    required this.orderItemsList,
    required this.gstPercent,
    required this.serviceCharges,
    required this.total,
  });
  final int orderId;
  final DateTime orderDate;
  final List<OrderItemModel> orderItemsList;
  final int discountPercent;
  final int gstPercent;
  final int serviceCharges;
  final num total;
  final num grandTotal;
  final num profit;
}

class PieData {
  PieData(this.name, this.totalSold, this.totalQty);
  final String name;
  final num totalSold;
  final num totalQty;
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<OrderModel> _orders = [];
  String orderByField = 'orderDate';
  String sortByFeild = 'DESC';
  DateTime toDate = DateTime.now();
  DateTime fromDate = Jiffy.now().subtract(days: 30).dateTime;
  List<NewOrdersWithProfit> ordersWithProfit = [];
  String exportReport = 'Sale and Purchase';
  List<String> dropDownItemsList = [
    'orderDate',
    'grandTotal',
    'total',
    'discountPercent',
    'serviceCharges'
  ];

  @override
  void initState() {
    super.initState();
    _loadOrdersData();
  }

  Future<void> _loadOrdersData() async {
    final result = await DatabaseHelper.instance.getOrders(
      orderBy: '$orderByField $sortByFeild',
      where: 'orderDate BETWEEN ? AND ?',
      fromDate: fromDate.toString(),
      toDate: toDate.toString(),
    );
    setState(() {
      _orders = result!;
      ordersWithProfit = buildData(_orders);
      groupByOrders(_orders);
    });
  }

  List<PieData> groupByProducts() {
    List<PieData> groupedList = [];
    Map<String, Map<String, dynamic>> groupedItems = {};

    for (var order in _orders) {
      List<Map<String, dynamic>> orderItemsList =
          List<Map<String, dynamic>>.from(jsonDecode(order.orderItemsList));

      for (var item in orderItemsList) {
        OrderItemModel orderItem = OrderItemModel.fromMap(item);

        if (groupedItems.containsKey(orderItem.prodName)) {
          groupedItems[orderItem.prodName]!['price'] +=
              orderItem.price * orderItem.quantity;
          groupedItems[orderItem.prodName]!['quantity'] += orderItem.quantity;
        } else {
          groupedItems[orderItem.prodName] = {
            'price': orderItem.price * orderItem.quantity,
            'quantity': orderItem.quantity,
          };
        }
      }
    }

    groupedItems.forEach((prodName, data) {
      groupedList.add(PieData(prodName, data['price'], data['quantity']));
    });
    return groupedList;
  }

  Map<String, double> groupByOrders(List<OrderModel> orders) {
    Map<String, double> groupedItems = {};

    for (var order in orders) {
      var orderDate = DateFormat('yyyyMMdd').format(order.orderDate);
      if (groupedItems.containsKey(orderDate)) {
        groupedItems[orderDate] = groupedItems[orderDate]! + order.grandTotal;
      } else {
        groupedItems[orderDate] = order.grandTotal;
      }
    }
    return groupedItems;
  }

  Map<String, double> groupByPurchase(List<PurchaseModel> purchases) {
    Map<String, double> groupedItems = {};
    for (var purchase in purchases) {
      var orderDate = DateFormat('yyyyMMdd').format(purchase.purchaseDate);
      if (groupedItems.containsKey(orderDate)) {
        groupedItems[orderDate] =
            groupedItems[orderDate]! + purchase.grandTotal;
      } else {
        groupedItems[orderDate] = purchase.grandTotal;
      }
    }
    return groupedItems;
  }

  Map<String, Map<String, dynamic>> mergeLists(
      Iterable<MapEntry<String, double>> saleList,
      Iterable<MapEntry<String, double>> purchaseList) {
    Map<String, Map<String, dynamic>> resultMap = {};

    for (var entry in saleList) {
      resultMap[entry.key] = {
        'sale': entry.value,
        'purchase': 0,
      };
    }

    for (var entry in purchaseList) {
      if (resultMap.containsKey(entry.key)) {
        resultMap[entry.key]!['purchase'] = entry.value;
      } else {
        resultMap[entry.key] = {
          'sale': 0,
          'purchase': entry.value,
        };
      }
    }

    var sortedByDate = Map.fromEntries(
        resultMap.entries.toList()..sort((e2, e1) => e1.key.compareTo(e2.key)));

    return sortedByDate;
  }

  Future<void> excelProfits(
      List<OrderModel> orders, BuildContext context) async {
    final xl.Workbook workbook = xl.Workbook();
    final xl.Worksheet sheet = workbook.worksheets[0];
    List<PurchaseModel> purchases = [];
    List<dynamic> headings = [
      'DATE',
      'PURCHASE',
      'SALE',
      'PROFIT',
    ];

    //adding headings
    for (int colIndex = 0; colIndex < headings.length; colIndex++) {
      sheet.getRangeByIndex(1, colIndex + 1).setText(headings[colIndex]);
      //styling headings
      sheet.setColumnWidthInPixels(colIndex + 1, 120);
      xl.Style headingStyle = sheet.getRangeByIndex(1, colIndex + 1).cellStyle;
      headingStyle.bold = true;
      headingStyle.fontSize = 18;
    }
    xl.Style purchaseStyle = sheet.getRangeByIndex(1, 2).cellStyle;
    purchaseStyle.fontColor = '#A82323';
    xl.Style saleStyle = sheet.getRangeByIndex(1, 3).cellStyle;
    saleStyle.fontColor = '#23751A';

    final database = await DatabaseHelper.instance.database;
    final result = await database?.query('Purchases',
        where: 'purchaseDate BETWEEN ? AND ?',
        whereArgs: [fromDate.toString(), toDate.toString()]);
    if (result != null) {
      for (var purchase in result) {
        purchases.add(PurchaseModel.fromMap(purchase));
      }
    }
    Iterable<MapEntry<String, double>> purchaseList =
        groupByPurchase(purchases).entries;
    Iterable<MapEntry<String, double>> saleList = groupByOrders(orders).entries;

    var mergedList = mergeLists(saleList, purchaseList).entries;

    int rowIndex = 0;
    num totalSales = 0;
    num totalPurchases = 0;
    for (; rowIndex < mergedList.length; rowIndex++) {
      int colIndex = 1;
      sheet.getRangeByIndex(rowIndex + 2, colIndex++).setValue(
          DateFormat('d MMM yyyy')
              .format(DateTime.parse(mergedList.elementAt(rowIndex).key)));
      sheet
          .getRangeByIndex(rowIndex + 2, colIndex++)
          .setValue(mergedList.elementAt(rowIndex).value['purchase']);
      totalPurchases += mergedList.elementAt(rowIndex).value['purchase'];

      sheet
          .getRangeByIndex(rowIndex + 2, colIndex++)
          .setValue(mergedList.elementAt(rowIndex).value['sale']);
      totalSales += mergedList.elementAt(rowIndex).value['sale'];

      sheet.getRangeByIndex(rowIndex + 2, colIndex++).setValue(
          mergedList.elementAt(rowIndex).value['sale'] -
              mergedList.elementAt(rowIndex).value['purchase']);
    }

    sheet.getRangeByIndex(rowIndex + 3, 1).setValue('Total');
    sheet.getRangeByIndex(rowIndex + 3, 2).setValue(totalPurchases);
    sheet.getRangeByIndex(rowIndex + 3, 3).setValue(totalSales);
    xl.Style totalStyle =
        sheet.getRangeByIndex(rowIndex + 3, 1, rowIndex + 3, 3).cellStyle;
    totalStyle.fontSize = 13;
    totalStyle.bold = true;

    sheet
        .getRangeByIndex(rowIndex + 3, 4)
        .setValue(totalSales - totalPurchases);
    xl.Style profitStyle = sheet.getRangeByIndex(rowIndex + 3, 4).cellStyle;
    profitStyle.fontSize = 15;
    profitStyle.bold = true;

    //saving file
    final List<int> bytes = workbook.saveAsStream();
    //freeing memory
    workbook.dispose();

    final Directory? downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      try {
        String path = downloadsDir.path;
        final String fileName =
            '$path/Sale and Purchase ${DateFormat('d_MMM_yyyy').format(fromDate)} To ${DateFormat('d_MMM_yyyy').format(toDate)}.xlsx';
        final File file = File(fileName);
        await file.writeAsBytes(bytes, flush: true);
        myCustomSnackBar(
            context: context,
            message: 'Saved to:  $fileName',
            warning: false,
            duration: 10);
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

  String formatFieldName(String input) {
    String str = input.replaceAllMapped(
      RegExp(r'(^|(?<=[a-z]))[A-Z]'),
      (match) => (match.group(1) != null ? ' ' : '') + match.group(0)!,
    );
    str = str.replaceRange(0, 1, str[0].toUpperCase());
    return str;
  }

  List<NewOrdersWithProfit> buildData(List<OrderModel> orders) {
    List<NewOrdersWithProfit> ordersList = [];
    for (var order in _orders) {
      List<OrderItemModel> orderItems = [];
      List<Map<String, dynamic>> orderItemsList =
          List<Map<String, dynamic>>.from(jsonDecode(order.orderItemsList));

      num orderProfit = 0;
      for (var items in orderItemsList) {
        OrderItemModel item = OrderItemModel.fromMap(items);
        num prodTotal = calculateTotal(item, true);
        orderProfit += prodTotal - (item.quantity * item.cost);
        orderItems.add(item);
      }

      ordersList.add(NewOrdersWithProfit(
          orderId: order.orderId!,
          orderDate: order.orderDate,
          grandTotal: order.grandTotal,
          total: order.total,
          discountPercent: order.discountPercent,
          gstPercent: order.gstPercent,
          serviceCharges: order.serviceCharges,
          orderItemsList: orderItems,
          profit: orderProfit));
    }
    return ordersList;
  }

  dynamic calculateTotal(OrderItemModel item, bool onlyDiscountValue) {
    num discountprice;
    num finalPrice;

    if (item.itemDiscount != 0) {
      discountprice = item.price * (item.itemDiscount! / 100);
      finalPrice = item.quantity * discountprice;

      if (onlyDiscountValue == true) {
        return finalPrice;
      }

      return '${item.price} x ${item.quantity} - ${item.itemDiscount}% = ${finalPrice.toStringAsFixed(1)}';
    } else {
      if (onlyDiscountValue == true) {
        return item.price * item.quantity;
      }
      return '${item.price} x ${item.quantity} = ${item.price * item.quantity}';
    }
  }

  Future<void> exportOrderHistory(
      List<NewOrdersWithProfit> orders, BuildContext context) async {
    final xl.Workbook workbook = xl.Workbook();
    final xl.Worksheet sheet = workbook.worksheets[0];

    List<dynamic> headings = [
      'Order Id',
      'Order Date',
      'Order Items List',
      'Total',
      'Service Charges',
      'GST Percent',
      'Discount Percent',
      'Grand Total',
      'Order Profit',
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

    for (int rowIndex = 0; rowIndex < orders.length; rowIndex++) {
      NewOrdersWithProfit order = orders[rowIndex];
      String formattedOrderDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(order.orderDate);
      sheet.getRangeByIndex(rowIndex + 2, 1).setValue(order.orderId);
      sheet.getRangeByIndex(rowIndex + 2, 2).setText(formattedOrderDate);
      sheet
          .getRangeByIndex(rowIndex + 2, 3)
          .setValue(order.orderItemsList.toString());
      sheet.getRangeByIndex(rowIndex + 2, 4).setValue(order.total);
      sheet.getRangeByIndex(rowIndex + 2, 5).setValue(order.serviceCharges);
      sheet.getRangeByIndex(rowIndex + 2, 6).setValue(order.gstPercent);
      sheet.getRangeByIndex(rowIndex + 2, 7).setValue(order.discountPercent);
      sheet.getRangeByIndex(rowIndex + 2, 8).setValue(order.grandTotal);
      sheet.getRangeByIndex(rowIndex + 2, 9).setValue(order.profit);
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
            '$path/Order History ${DateFormat('d_MMM_yyyy').format(fromDate)} To ${DateFormat('d_MMM_yyyy').format(toDate)}.xlsx';
        final File file = File(fileName);
        await file.writeAsBytes(bytes, flush: true);
        myCustomSnackBar(
            context: context,
            message: 'Saved to:  $fileName',
            warning: false,
            duration: 10);
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
        title: 'Dashboard',
        currentPage: Dashboard(),
      ),
      appBar: myCustomAppBar(
        "Dashboard",
        const Color.fromARGB(255, 116, 2, 122),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 700,
                  child: SfCartesianChart(
                      primaryXAxis: DateTimeAxis(
                        // minimum: fromDate.add(Duration(hours: 1)),
                        // maximum: toDate.add(Durations.extralong1),
                        dateFormat: DateFormat('d MMM HH:mm'),
                      ),
                      primaryYAxis: NumericAxis(),
                      // title: ChartTitle(text: 'Grand Total'),
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
                        color: Colors.purple[600],
                        duration: 5,

                        enable: true,
                        // format: 'point.x || point.y',
                        // header: 'Grand Total',
                        builder:
                            (data, point, series, pointIndex, seriesIndex) {
                          return Container(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                                '${DateFormat('d MMM yyyy h:mm a').format(point.x)}\n${point.y}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white)),
                          );
                        },
                      ),
                      series: <LineSeries<NewOrdersWithProfit, DateTime>>[
                        LineSeries<NewOrdersWithProfit, DateTime>(
                            name: 'Profit',
                            sortingOrder: SortingOrder.ascending,
                            sortFieldValueMapper:
                                (NewOrdersWithProfit sales, _) =>
                                    sales.orderDate,
                            markerSettings: const MarkerSettings(
                                isVisible: true, height: 4, width: 4),
                            dataSource: ordersWithProfit,
                            xValueMapper: (NewOrdersWithProfit sales, _) =>
                                sales.orderDate,
                            yValueMapper: (NewOrdersWithProfit sales, _) =>
                                sales.profit),
                        LineSeries<NewOrdersWithProfit, DateTime>(
                            name: 'Grand Total',
                            sortingOrder: SortingOrder.ascending,
                            sortFieldValueMapper:
                                (NewOrdersWithProfit sales, _) =>
                                    sales.orderDate,
                            markerSettings: const MarkerSettings(
                                isVisible: true, height: 4, width: 4),
                            dataSource: ordersWithProfit,
                            xValueMapper: (NewOrdersWithProfit sales, _) =>
                                sales.orderDate,
                            yValueMapper: (NewOrdersWithProfit sales, _) =>
                                sales.grandTotal),
                        // LineSeries<LineData, DateTime>(
                        //     name: 'Discount value',
                        //     sortingOrder: SortingOrder.ascending,
                        //     sortFieldValueMapper: (LineData sales, _) =>
                        //         sales.time,
                        //     markerSettings: const MarkerSettings(
                        //         isVisible: true, height: 4, width: 4),
                        //     dataSource: buildData(_orders),
                        //     xValueMapper: (LineData sales, _) => sales.time,
                        //     yValueMapper: (LineData sales, _) =>
                        //         sales.discountValue),
                      ]),
                ),
                SizedBox(
                  width: 500,
                  child: SfCircularChart(
                    title: ChartTitle(
                      text: 'Products Sold By Quantity',
                      alignment: ChartAlignment.center,
                    ),
                    series: <CircularSeries>[
                      PieSeries<PieData, String>(
                        dataSource: groupByProducts(),
                        // pointColorMapper: (PieData data, _) => data.qty,
                        xValueMapper: (PieData data, _) => data.name,
                        yValueMapper: (PieData data, _) => data.totalQty,
                        dataLabelMapper: (PieData data, _) => data.name,
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          labelPosition: ChartDataLabelPosition.outside,
                          textStyle: TextStyle(),
                          connectorLineSettings:
                              ConnectorLineSettings(type: ConnectorType.line),
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
                )
              ],
            ),
            Container(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
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
                            fontWeight: FontWeight.bold, color: Colors.black),
                        value: orderByField,
                        onChanged: (value) {
                          setState(() {
                            orderByField = value!;
                            _loadOrdersData();
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
                              _loadOrdersData();
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
                              _loadOrdersData();
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
                                color: Colors.purple.shade200,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
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
                              await _loadOrdersData();
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
                                color: Colors.purple.shade200,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
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
                              await _loadOrdersData();
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
                        onPressed: () => _loadOrdersData(),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade500,
                            foregroundColor: Colors.white),
                        child: const Text('Filter')),
                    SizedBox(width: 10),
                    SizedBox(
                      height: 20,
                      child: DropdownButton<String>(
                        underline: const SizedBox(),
                        focusColor: Colors.transparent,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        value: exportReport,
                        onChanged: (value) {
                          setState(() {
                            exportReport = value!;
                          });
                        },
                        items: ['Sale and Purchase', 'Order History']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: ElevatedButton.icon(
                          onPressed: () => exportReport == 'Sale and Purchase'
                              ? excelProfits(_orders, context)
                              : exportOrderHistory(ordersWithProfit, context),
                          icon: const Icon(Icons.download),
                          style: ButtonStyle(
                              foregroundColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.purple.shade700)),
                          label: const Text('Export as Excel')),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _orders.isEmpty
                  ? Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.red),
                      child: const Center(
                        child: Text('No Orders Available.',
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
                      ))
                  : Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
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

                          double gstAmount =
                              order.total * (order.gstPercent / 100);
                          double discountAmount =
                              order.total * (order.discountPercent / 100);

                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${order.orderId}',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            DateFormat('dd-MM-yy - h:mm a')
                                                .format(order.orderDate),
                                            style:
                                                const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Column(
                                      children: orderItemsList.map((temp) {
                                        OrderItemModel item =
                                            OrderItemModel.fromMap(temp);
                                        String str =
                                            calculateTotal(item, false);
                                        return Tooltip(
                                          decoration: BoxDecoration(
                                              color: Colors.purple[700],
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(5))),
                                          message: '${item.prodName}\n$str',
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: 140,
                                                child: Text(
                                                  item.prodName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color:
                                                          item.itemDiscount != 0
                                                              ? Colors.red
                                                              : null),
                                                ),
                                              ),
                                              Text(
                                                str,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color:
                                                        item.itemDiscount != 0
                                                            ? Colors.red
                                                            : null),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const Divider(
                                        color: Color.fromARGB(255, 79, 4, 93)),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Total'),
                                        Text(order.total.toStringAsFixed(1))
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('GST'),
                                        Text(
                                            '${order.gstPercent}% = ${gstAmount.toStringAsFixed(1)}')
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Discount '),
                                        Text(
                                          '${order.discountPercent}% = ${discountAmount.toStringAsFixed(1)}',
                                          style: TextStyle(
                                              color: order.discountPercent != 0
                                                  ? Colors.red
                                                  : null),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
            )
          ],
        ),
      ),
    );
  }
}
