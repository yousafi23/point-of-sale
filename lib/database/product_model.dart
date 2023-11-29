// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ProductModel {
  final String prodName;
  final String category;
  final String barCode;
  final int stock;
  final int? unitCost;
  final int? unitPrice;
  final String companyName;
  final String supplierName;
  final int? productId;

  ProductModel({
    required this.prodName,
    required this.category,
    required this.barCode,
    required this.stock,
    this.unitCost,
    this.unitPrice,
    required this.companyName,
    required this.supplierName,
    this.productId,
  });

  ProductModel copyWith({
    String? prodName,
    String? category,
    String? barCode,
    int? stock,
    int? unitCost,
    int? unitPrice,
    String? companyName,
    String? supplierName,
    int? productId,
  }) {
    return ProductModel(
      prodName: prodName ?? this.prodName,
      category: category ?? this.category,
      barCode: barCode ?? this.barCode,
      stock: stock ?? this.stock,
      unitCost: unitCost ?? this.unitCost,
      unitPrice: unitPrice ?? this.unitPrice,
      companyName: companyName ?? this.companyName,
      supplierName: supplierName ?? this.supplierName,
      productId: productId ?? this.productId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'prodName': prodName,
      'category': category,
      'barCode': barCode,
      'stock': stock,
      'unitCost': unitCost,
      'unitPrice': unitPrice,
      'companyName': companyName,
      'supplierName': supplierName,
      'productId': productId,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      prodName: map['prodName'] as String,
      category: map['category'] as String,
      barCode: map['barCode'] as String,
      stock: map['stock'] as int,
      unitCost: map['unitCost'] != null ? map['unitCost'] as int : null,
      unitPrice: map['unitPrice'] != null ? map['unitPrice'] as int : null,
      companyName: map['companyName'] as String,
      supplierName: map['supplierName'] as String,
      productId: map['productId'] != null ? map['productId'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductModel.fromJson(String source) =>
      ProductModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ProductModel(prodName: $prodName, category: $category, barCode: $barCode, stock: $stock, unitCost: $unitCost, unitPrice: $unitPrice, companyName: $companyName, supplierName: $supplierName, productId: $productId)';
  }
}
