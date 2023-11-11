// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class OrderModel {
  final DateTime orderDate;
  final double grandTotal;
  final List<String> orderItemId;
  OrderModel({
    required this.orderDate,
    required this.grandTotal,
    required this.orderItemId,
  });

  OrderModel copyWith({
    DateTime? orderDate,
    double? grandTotal,
    List<String>? orderItemId,
  }) {
    return OrderModel(
      orderDate: orderDate ?? this.orderDate,
      grandTotal: grandTotal ?? this.grandTotal,
      orderItemId: orderItemId ?? this.orderItemId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'orderDate': orderDate.millisecondsSinceEpoch,
      'grandTotal': grandTotal,
      'orderItemId': orderItemId,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderDate: DateTime.fromMillisecondsSinceEpoch(map['orderDate'] as int),
      grandTotal: map['grandTotal'] as double,
      orderItemId: List<String>.from((map['orderItemId'] as List<String>)),
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderModel.fromJson(String source) =>
      OrderModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'OrderModel(orderDate: $orderDate, grandTotal: $grandTotal, orderItemId: $orderItemId)';

  @override
  bool operator ==(covariant OrderModel other) {
    if (identical(this, other)) return true;

    return other.orderDate == orderDate &&
        other.grandTotal == grandTotal &&
        listEquals(other.orderItemId, orderItemId);
  }

  @override
  int get hashCode =>
      orderDate.hashCode ^ grandTotal.hashCode ^ orderItemId.hashCode;
}
