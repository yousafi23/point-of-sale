// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class OrderModel {
  final DateTime orderDate;
  final double grandTotal;
  final String orderItemsList;
  final int? orderId;

  OrderModel({
    required this.orderDate,
    required this.grandTotal,
    required this.orderItemsList,
    this.orderId,
  });

  OrderModel copyWith({
    DateTime? orderDate,
    double? grandTotal,
    String? orderItemsList,
  }) {
    return OrderModel(
      orderDate: orderDate ?? this.orderDate,
      grandTotal: grandTotal ?? this.grandTotal,
      orderItemsList: orderItemsList ?? this.orderItemsList,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'orderDate': orderDate.toString(),
      'grandTotal': grandTotal,
      'orderItemsList': orderItemsList,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderDate: map['orderDate'],
      grandTotal: map['grandTotal'] as double,
      orderItemsList: map['orderItemsList'] as String,
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
    );
  }

  @override
  String toString() =>
      'OrderModel(orderDate: $orderDate, grandTotal: $grandTotal, orderItemsList: $orderItemsList)';

  @override
  bool operator ==(covariant OrderModel other) {
    if (identical(this, other)) return true;

    return other.orderDate == orderDate &&
        other.grandTotal == grandTotal &&
        other.orderItemsList == orderItemsList;
  }

  @override
  int get hashCode =>
      orderDate.hashCode ^ grandTotal.hashCode ^ orderItemsList.hashCode;
}
