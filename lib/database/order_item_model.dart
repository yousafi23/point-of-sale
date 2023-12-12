// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class OrderItemModel {
  final int productId;
  final String prodName;
  final int price;
  final int cost;
  final int quantity;
  int? itemDiscount;
  final int? orderItemId;

  OrderItemModel({
    required this.productId,
    required this.prodName,
    required this.price,
    required this.cost,
    required this.quantity,
    this.itemDiscount,
    this.orderItemId,
  });

  OrderItemModel copyWith({
    int? productId,
    String? prodName,
    int? price,
    int? cost,
    int? quantity,
    int? itemDiscount,
    int? orderItemId,
  }) {
    return OrderItemModel(
      productId: productId ?? this.productId,
      prodName: prodName ?? this.prodName,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      quantity: quantity ?? this.quantity,
      itemDiscount: itemDiscount ?? this.itemDiscount,
      orderItemId: orderItemId ?? this.orderItemId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productId': productId,
      'prodName': prodName,
      'price': price,
      'cost': cost,
      'quantity': quantity,
      'itemDiscount': itemDiscount,
      'orderItemId': orderItemId,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] as int,
      prodName: map['prodName'] as String,
      price: map['price'] as int,
      cost: map['cost'] as int,
      quantity: map['quantity'] as int,
      itemDiscount:
          map['itemDiscount'] != null ? map['itemDiscount'] as int : null,
      orderItemId:
          map['orderItemId'] != null ? map['orderItemId'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderItemModel.fromJson(String source) =>
      OrderItemModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrderItemModel(productId: $productId, prodName: $prodName, price: $price, cost: $cost, quantity: $quantity, itemDiscount: $itemDiscount, orderItemId: $orderItemId)';
  }

  @override
  bool operator ==(covariant OrderItemModel other) {
    if (identical(this, other)) return true;

    return other.productId == productId &&
        other.prodName == prodName &&
        other.price == price &&
        other.cost == cost &&
        other.quantity == quantity &&
        other.itemDiscount == itemDiscount &&
        other.orderItemId == orderItemId;
  }

  @override
  int get hashCode {
    return productId.hashCode ^
        prodName.hashCode ^
        price.hashCode ^
        cost.hashCode ^
        quantity.hashCode ^
        itemDiscount.hashCode ^
        orderItemId.hashCode;
  }
}
