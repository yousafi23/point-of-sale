// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PurchaseItemModel {
  final int? purchaseItemId;
  final String name;
  final int price;
  final int quantity;
  final int ingredientId;

  PurchaseItemModel({
    this.purchaseItemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.ingredientId,
  });

  PurchaseItemModel copyWith({
    int? purchaseItemId,
    String? name,
    int? price,
    int? quantity,
    int? ingredientId,
  }) {
    return PurchaseItemModel(
      purchaseItemId: purchaseItemId ?? this.purchaseItemId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      ingredientId: ingredientId ?? this.ingredientId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'price': price,
      'quantity': quantity,
      'ingredientId': ingredientId,
    };
  }

  factory PurchaseItemModel.fromMap(Map<String, dynamic> map) {
    return PurchaseItemModel(
      purchaseItemId:
          map['purchaseItemId'] != null ? map['purchaseItemId'] as int : null,
      name: map['name'] as String,
      price: map['price'] as int,
      quantity: map['quantity'] as int,
      ingredientId: map['ingredientId'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory PurchaseItemModel.fromJson(String source) =>
      PurchaseItemModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PurchaseItemModel(purchaseItemId: $purchaseItemId, name: $name, price: $price, quantity: $quantity, ingredientId: $ingredientId)';
  }

  @override
  bool operator ==(covariant PurchaseItemModel other) {
    if (identical(this, other)) return true;

    return other.purchaseItemId == purchaseItemId &&
        other.name == name &&
        other.price == price &&
        other.quantity == quantity &&
        other.ingredientId == ingredientId;
  }

  @override
  int get hashCode {
    return purchaseItemId.hashCode ^
        name.hashCode ^
        price.hashCode ^
        quantity.hashCode ^
        ingredientId.hashCode;
  }
}
