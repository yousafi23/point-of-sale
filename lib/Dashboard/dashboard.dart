import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/order_model.dart';
import 'package:point_of_sale_app/general/drawer.dart';
import 'package:point_of_sale_app/general/my_custom_appbar.dart';

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
        toDate: toDate.toString());

    setState(() {
      _orders = result!;
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
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text('Sort By '),
                DropdownButton<String>(
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
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'from ',
                        style: TextStyle(fontSize: 12),
                      ),
                      GestureDetector(
                        child: Text(
                          DateFormat('d MMM yyyy').format(fromDate),
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'To ',
                        style: TextStyle(fontSize: 12),
                      ),
                      GestureDetector(
                        child: Text(
                          DateFormat('d MMM yyyy').format(toDate),
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                        backgroundColor: Colors.purple.shade500),
                    child: const Text('Filter')),
              ],
            ),
          ),
          Expanded(
            child: _orders.isEmpty
                ? const Center(
                    child: Text('No orders available.'),
                  )
                : ListView.builder(
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      OrderModel order = _orders[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text('Order ID: ${order.orderId}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order Date: ${order.orderDate}'),
                              Text(
                                  'Grand Total: \$${order.grandTotal.toStringAsFixed(2)}'),
                              Text(
                                  'Total: \$${order.total.toStringAsFixed(2)}'),
                              Text(
                                  'Service Charges: \$${order.serviceCharges}'),
                              Text('GST Percent: ${order.gstPercent}%'),
                              Text(
                                  'Discount Percent: ${order.discountPercent}%'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
