// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class OrderItemModel {
  final int productId;
  final String prodName;
  final int price;
  final int quantity;

  OrderItemModel({
    required this.productId,
    required this.prodName,
    required this.price,
    required this.quantity,
  });

  OrderItemModel copyWith({
    int? productId,
    String? prodName,
    int? price,
    int? quantity,
  }) {
    return OrderItemModel(
      productId: productId ?? this.productId,
      prodName: prodName ?? this.prodName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productId': productId,
      'prodName': prodName,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] as int,
      prodName: map['prodName'] as String,
      price: map['price'] as int,
      quantity: map['quantity'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderItemModel.fromJson(String source) =>
      OrderItemModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrderItemModel(productId: $productId, prodName: $prodName, price: $price, quantity: $quantity)';
  }

  @override
  bool operator ==(covariant OrderItemModel other) {
    if (identical(this, other)) return true;

    return other.productId == productId &&
        other.prodName == prodName &&
        other.price == price &&
        other.quantity == quantity;
  }

  @override
  int get hashCode {
    return productId.hashCode ^
        prodName.hashCode ^
        price.hashCode ^
        quantity.hashCode;
  }
}
