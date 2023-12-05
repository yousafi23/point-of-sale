// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/order_item_model.dart';
import 'package:point_of_sale_app/database/order_model.dart';
import 'package:point_of_sale_app/general/confirmation_alert.dart';
import 'package:point_of_sale_app/general/my_custom_snackbar.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class OrderSelection extends StatefulWidget {
  OrderSelection(
      {super.key, required this.orderItems, required this.quantityCallback});

  final Function quantityCallback;
  List<Map<String, dynamic>> orderItems;

  @override
  State<OrderSelection> createState() => _OrderSelectionState();
}

class _OrderSelectionState extends State<OrderSelection> {
  double grandTotal = 0.0;
  double total = 0.0;
  double gstAmount = 0.0;
  double discountAmount = 0.0;
  int serviceCharges = 0;
  int gst = 0;
  int discount = 0;

  int itemDiscount = 0;

  final itemDiscountCont = TextEditingController();
  final discountCont = TextEditingController();
  final serviceChargesCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final database = await DatabaseHelper.instance.database;
    final result = await database?.query('OrderItems');
    final result1 =
        await DatabaseHelper.instance.getRecord('Company', 'companyId=?', 0);
    setState(() {
      widget.orderItems = result!;
      calculateGrandTotal();
      serviceCharges = result1![0]['serviceCharges'] as int;
      gst = result1[0]['gst'] as int;
      discount = result1[0]['discount'] as int;
    });
    discountCont.text = discount.toString();
    serviceChargesCont.text = serviceCharges.toString();
  }

  num calculateItemTotal(int qty, int price, {int? discount}) {
    if (discount != null) {
      // print('discounted');
      var discountprice = price * (discount / 100);
      return qty * (price - discountprice);
    } else {
      // print('simple');
      return qty * price;
    }
  }

  void calculateGrandTotal() {
    grandTotal = 0.0;
    total = 0.0;

    for (var item in widget.orderItems) {
      num itemTotal = calculateItemTotal(item['quantity'], item['price'],
          discount: item['itemDiscount']);
      total += itemTotal;
    }

    gstAmount = total * (gst / 100);
    discountAmount = total * (discount / 100);
    grandTotal = total + serviceCharges + gstAmount - discountAmount;

    grandTotal = double.parse(grandTotal.toStringAsFixed(1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    calculateGrandTotal();
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          DataTable(
            headingRowHeight: 40,
            headingRowColor: MaterialStateColor.resolveWith(
                (states) => Colors.green.shade100),
            columnSpacing: 30.0,
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Unit Price')),
              DataColumn(label: Text('Qty')),
              DataColumn(label: Text('Total')),
              DataColumn(label: Text('Discount')),
              DataColumn(label: Text('')),
              DataColumn(label: Text('')),
            ],
            rows: widget.orderItems.map<DataRow>((Map<String, dynamic> row) {
              OrderItemModel orderItemModel = OrderItemModel.fromMap(row);
              return DataRow(
                cells: [
                  DataCell(SizedBox(
                      width: 100,
                      child: Text(
                        orderItemModel.prodName,
                        maxLines: 2,
                      ))),
                  DataCell(Text(orderItemModel.price.toString())),
                  DataCell(Text(orderItemModel.quantity.toString())),
                  DataCell(Text((calculateItemTotal(
                          orderItemModel.quantity, orderItemModel.price,
                          discount: orderItemModel.itemDiscount))
                      .toString())),
                  DataCell(
                    SizedBox(
                      width: 30,
                      height: 25,
                      child: TextField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        controller: itemDiscountCont,
                        onChanged: (value) async {
                          itemDiscount = int.tryParse(value) ?? 0;

                          OrderItemModel newOrderItemModel = orderItemModel
                              .copyWith(itemDiscount: itemDiscount);

                          await DatabaseHelper.instance.updateRecord(
                              'OrderItems',
                              newOrderItemModel.toMap(),
                              'orderItemId=?',
                              orderItemModel.orderItemId!);

                          // print(newOrderItemModel);

                          calculateGrandTotal();
                          await _loadData();
                        },
                      ),
                    ),
                  ),
                  DataCell(
                    GestureDetector(
                      child: const Icon(Icons.add),
                      onTap: () async {
                        await DatabaseHelper.instance
                            .changeQuantity(orderItemModel.orderItemId!, false);

                        await widget.quantityCallback(
                            orderItemModel.productId, true); //triger

                        await _loadData();
                      },
                    ),
                  ),
                  DataCell(
                    GestureDetector(
                        child: const Icon(Icons.minimize),
                        onTap: () async {
                          var qty = await DatabaseHelper.instance
                              .getQuantity(orderItemModel.orderItemId!);

                          if (qty > 1) {
                            await DatabaseHelper.instance.changeQuantity(
                                orderItemModel.orderItemId!, true);

                            await widget.quantityCallback(
                                orderItemModel.productId, false); //triger
                          } else {
                            await DatabaseHelper.instance.deleteRecord(
                                dbTable: "OrderItems",
                                where: 'orderItemId=?',
                                id: orderItemModel.orderItemId!);

                            await widget.quantityCallback(
                                orderItemModel.productId, false); //triger

                            myCustomSnackBar(
                                message: 'Product Removed',
                                warning: true,
                                context: context);
                          }

                          await _loadData();
                        }),
                  ),
                ],
              );
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green.shade100),
              padding: const EdgeInsets.all(10),
              child: Center(
                child: SizedBox(
                  width: 270,
                  height: 130,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total'),
                          Text('Rs ${total.toString()}'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Service Charges'),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Rs '),
                              SizedBox(
                                width: 30,
                                height: 25,
                                child: TextField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: serviceChargesCont,
                                  onChanged: (value) {
                                    serviceCharges = int.tryParse(value) ?? 0;
                                    calculateGrandTotal();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('GST'),
                          Text('$gst% = ${gstAmount.toStringAsFixed(1)}'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Discount'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 30,
                                height: 25,
                                child: TextField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: discountCont,
                                  onChanged: (value) {
                                    int disVal = int.tryParse(value) ?? 0;
                                    if (disVal <= 100) {
                                      discount = disVal;
                                    } else {
                                      discountCont.text = '';
                                      myCustomSnackBar(
                                          context: context,
                                          message:
                                              'Discount can NOT be greater than 100',
                                          warning: true);
                                    }
                                    calculateGrandTotal();
                                  },
                                ),
                              ),
                              Text('% = ${discountAmount.toStringAsFixed(1)}'),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Grand Total',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('Rs ${grandTotal.toStringAsFixed(1)}',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          FloatingActionButton.extended(
            onPressed: () async {
              if (total > 0) {
                OrderModel orderModel = OrderModel(
                    orderDate: DateTime.now(),
                    grandTotal: grandTotal,
                    orderItemsList: jsonEncode(widget.orderItems),
                    total: total,
                    serviceCharges: serviceCharges,
                    gstPercent: gst,
                    discountPercent: discount);

                // print('Model=${orderModel.toMap()}');
                // print('str=${widget.orderItems}');
                final bool confirmed =
                    await showPlaceOrderConfirmation(context);
                if (confirmed) {
                  await DatabaseHelper.instance
                      .insertRecord('Orders', orderModel.toMap());
                  await DatabaseHelper.instance.truncateTable('OrderItems');

                  myCustomSnackBar(
                    message:
                        'Order Placed!\t\t\t\t Total: ${grandTotal.toStringAsFixed(1)}',
                    warning: false,
                    context: context,
                  );
                }
                await _loadData();
              } else {
                myCustomSnackBar(
                  message: 'Can NOT place empty Order!',
                  warning: true,
                  context: context,
                );
              }
            },
            backgroundColor: Colors.green.shade700,
            label: const Text('Place Order'),
          )
        ],
      ),
    );
  }
}
