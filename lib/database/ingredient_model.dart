// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class IngredientModel {
  final String name;
  final int stock;
  final int? unitCost;
  final String companyName;
  final String supplierName;

  IngredientModel({
    required this.name,
    required this.stock,
    this.unitCost,
    required this.companyName,
    required this.supplierName,
  });

  IngredientModel copyWith({
    String? name,
    int? stock,
    int? unitCost,
    String? companyName,
    String? supplierName,
  }) {
    return IngredientModel(
      name: name ?? this.name,
      stock: stock ?? this.stock,
      unitCost: unitCost ?? this.unitCost,
      companyName: companyName ?? this.companyName,
      supplierName: supplierName ?? this.supplierName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'stock': stock,
      'unitCost': unitCost,
      'companyName': companyName,
      'supplierName': supplierName,
    };
  }

  factory IngredientModel.fromMap(Map<String, dynamic> map) {
    return IngredientModel(
      name: map['name'] as String,
      stock: map['stock'] as int,
      unitCost: map['unitCost'] != null ? map['unitCost'] as int : null,
      companyName: map['companyName'] as String,
      supplierName: map['supplierName'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory IngredientModel.fromJson(String source) =>
      IngredientModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ProductModel(name: $name, stock: $stock, unitCost: $unitCost, companyName: $companyName, supplierName: $supplierName)';
  }

  @override
  bool operator ==(covariant IngredientModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.stock == stock &&
        other.unitCost == unitCost &&
        other.companyName == companyName &&
        other.supplierName == supplierName;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        stock.hashCode ^
        unitCost.hashCode ^
        companyName.hashCode ^
        supplierName.hashCode;
  }
}
