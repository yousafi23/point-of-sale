// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class OrderModel {
  final DateTime orderDate;
  final double grandTotal;
  final String orderItemsList;
  final int? orderId;
  final double total;
  final int serviceCharges;
  final int gstPercent;
  final int discountPercent;

  OrderModel({
    required this.orderDate,
    required this.grandTotal,
    required this.orderItemsList,
    this.orderId,
    required this.total,
    required this.serviceCharges,
    required this.gstPercent,
    required this.discountPercent,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'orderDate': orderDate.toString(),
      'grandTotal': grandTotal,
      'orderItemsList': orderItemsList,
      'total': total,
      'serviceCharges': serviceCharges,
      'gstPercent': gstPercent,
      'discountPercent': discountPercent
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderDate: map['orderDate'],
      grandTotal: map['grandTotal'] as double,
      orderItemsList: map['orderItemsList'] as String,
      total: map['total'],
      serviceCharges: map['serviceCharges'],
      gstPercent: map['gstPercent'],
      discountPercent: map['discountPercent'],
    );
  }

  String toJson() => json.encode(toMap());

  // factory OrderModel.fromJson(String source) =>
  //     OrderModel.fromMap(json.decode(source) as Map<String, dynamic>);

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'],
      orderDate: DateTime.parse(json['orderDate']),
      grandTotal: json['grandTotal'],
      orderItemsList: json['orderItemsList'],
      total: json['total'],
      serviceCharges: json['serviceCharges'],
      gstPercent: json['gstPercent'],
      discountPercent: json['discountPercent'],
    );
  }
}
