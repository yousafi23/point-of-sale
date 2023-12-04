// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class IngredientModel {
  final String name;
  final int unitCost;
  final String companyName;
  final String supplierName;
  final int? ingredientId;

  IngredientModel({
    required this.name,
    required this.unitCost,
    required this.companyName,
    required this.supplierName,
    this.ingredientId,
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
      unitCost: unitCost ?? this.unitCost,
      companyName: companyName ?? this.companyName,
      supplierName: supplierName ?? this.supplierName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'unitCost': unitCost,
      'companyName': companyName,
      'supplierName': supplierName,
    };
  }

  factory IngredientModel.fromMap(Map<String, dynamic> map) {
    return IngredientModel(
      name: map['name'] as String,
      unitCost: map['unitCost'] as int,
      companyName: map['companyName'] as String,
      supplierName: map['supplierName'] as String,
      ingredientId:
          map['ingredientId'] != null ? map['ingredientId'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory IngredientModel.fromJson(String source) =>
      IngredientModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ProductModel(name: $name, unitCost: $unitCost, companyName: $companyName, supplierName: $supplierName)';
  }

  @override
  bool operator ==(covariant IngredientModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.unitCost == unitCost &&
        other.companyName == companyName &&
        other.supplierName == supplierName;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        unitCost.hashCode ^
        companyName.hashCode ^
        supplierName.hashCode;
  }
}
