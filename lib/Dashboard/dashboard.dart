import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:point_of_sale_app/database/order_item_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/order_model.dart';
import 'package:point_of_sale_app/general/drawer.dart';
import 'package:point_of_sale_app/general/my_custom_appbar.dart';

class LineData {
  LineData(this.time, this.grandtotal, this.discount);
  final String time;
  final num grandtotal;
  final num discount;
}

class PieData {
  PieData(this.name, this.sold, this.qty);
  final String name;
  final num sold;
  final num qty;
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<OrderModel> _orders = [];
  String orderByField = 'orderDate';
  bool isHovered = false;
  String sortByFeild = 'ASC';
  DateTime toDate = DateTime.now();
  DateTime fromDate = Jiffy.now().subtract(days: 30).dateTime;
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
    });
  }

  List<PieData> groupByProducts(List<OrderModel> orders) {
    List<PieData> groupedList = [];
    Map<String, Map<String, dynamic>> groupedItems = {};

    for (var order in _orders) {
      List<Map<String, dynamic>> orderItemsList =
          List<Map<String, dynamic>>.from(jsonDecode(order.orderItemsList));

      for (var item in orderItemsList) {
        OrderItemModel orderItem = OrderItemModel.fromMap(item);

        // Check if the product name is already in the grouped map
        if (groupedItems.containsKey(orderItem.prodName)) {
          // If yes, update the existing entry
          groupedItems[orderItem.prodName]!['price'] +=
              orderItem.price * orderItem.quantity;
          groupedItems[orderItem.prodName]!['quantity'] += orderItem.quantity;
        } else {
          // If not, create a new entry in the grouped map
          groupedItems[orderItem.prodName] = {
            'price': orderItem.price * orderItem.quantity,
            'quantity': orderItem.quantity,
          };
        }
      }
    }

    List<MapEntry<String, Map<String, dynamic>>> sortedList =
        groupedItems.entries.toList();

// Sort the list based on 'price'
    sortedList.sort((a, b) => b.value['price'].compareTo(a.value['price']));

    groupedItems.forEach((prodName, data) {
      // print(groupedItems.runtimeType);
      // print('$prodName, ${data['price']}, ${data['quantity']}');
      groupedList.add(PieData(prodName, data['price'], data['quantity']));
    });

    for (var entry in sortedList) {
      String prodName = entry.key;
      int totalPrice = entry.value['price'];
      int totalQuantity = entry.value['quantity'];
      // print('$prodName, $totalPrice, $totalQuantity');
      groupedList.add(PieData(prodName, totalPrice, totalQuantity));
    }
    return groupedList;
  }

  String formatFieldName(String input) {
    String str = input.replaceAllMapped(
      RegExp(r'(^|(?<=[a-z]))[A-Z]'),
      (match) => (match.group(1) != null ? ' ' : '') + match.group(0)!,
    );
    str = str.replaceRange(0, 1, str[0].toUpperCase());
    return str;
  }

  List<LineData> buildData(List<OrderModel> orders) {
    List<LineData> ordersList = [];
    for (var order in _orders) {
      ordersList.add(LineData(order.orderDate.toString(), order.grandTotal,
          (order.total * (order.discountPercent / 100))));
    }
    return ordersList;
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 600,
                child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    // title: ChartTitle(text: 'Grand Total'),
                    // legend: const Legend(isVisible: true),
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      format: 'point.x || point.y',
                      header: 'Grand Total',
                      // builder: (data, point, series, pointIndex, seriesIndex) {
                      //   return Container(
                      //     padding: const EdgeInsets.all(5),
                      //     child: Text('${point.x} : ${point.y}',
                      //         style: const TextStyle(color: Colors.white)),
                      //   );
                      // },
                    ),
                    series: <LineSeries<LineData, String>>[
                      LineSeries<LineData, String>(
                          dataSource: buildData(_orders),
                          xValueMapper: (LineData sales, _) => sales.time,
                          yValueMapper: (LineData sales, _) =>
                              sales.grandtotal),
                      LineSeries<LineData, String>(
                          dataSource: buildData(_orders),
                          xValueMapper: (LineData sales, _) => sales.time,
                          yValueMapper: (LineData sales, _) => sales.discount),
                    ]),
              ),
              SizedBox(
                width: 600,
                child: SfCircularChart(
                  series: <CircularSeries>[
                    PieSeries<PieData, String>(
                      dataSource: groupByProducts(_orders),
                      // pointColorMapper: (PieData data, _) => data.qty,
                      xValueMapper: (PieData data, _) => data.name,
                      yValueMapper: (PieData data, _) => data.sold,
                      dataLabelMapper: (PieData data, _) => data.name,
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside,
                        textStyle: TextStyle(),
                        connectorLineSettings:
                            ConnectorLineSettings(type: ConnectorType.curve),
                        // overflowMode: OverflowMode.none
                        // useSeriesColor: true,
                      ),
                      explode: true,
                      // explodeAll: true,
                      explodeGesture: ActivationMode.singleTap,
                      groupMode: CircularChartGroupMode.point,
                      // As the grouping mode is point, 2 points will be grouped
                      groupTo: 5,
                      enableTooltip: true,
                    )
                  ],
                  tooltipBehavior: TooltipBehavior(enable: true),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
                ElevatedButton(
                    onPressed: () => _loadOrdersData(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade500,
                        foregroundColor: Colors.white),
                    child: const Text('Filter')),
              ],
            ),
          ),
          Expanded(
            child: _orders.isEmpty
                ? const Center(
                    child: Text('No orders available.'),
                  )
                : Center(
                    child: SizedBox(
                      width: 500,
                      child: ListView.builder(
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
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ExpansionTile(
                              shape: const Border(),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${order.orderId}',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    textAlign: TextAlign.start,
                                    DateFormat('dd-MMM-yy h:mm a')
                                        .format(order.orderDate),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  Text(
                                      textAlign: TextAlign.end,
                                      order.grandTotal.toString(),
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              children: [
                                for (var item in orderItemsList)
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(15, 0, 25, 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 140,
                                          child: Text(
                                            '${item['prodName']}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '${item['price']} x ${item['quantity']} = ${item['price'] * item['quantity']}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 0, 25, 10),
                                  child: Column(
                                    children: [
                                      const Divider(
                                          color:
                                              Color.fromARGB(255, 67, 2, 80)),
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
                                            style: const TextStyle(
                                                color: Colors.redAccent),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
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
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
