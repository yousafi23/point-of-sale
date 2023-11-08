// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class SizeModel {
  final int productId;
  final String size;
  final int unitCost;
  final int? sizeId;
  SizeModel({
    required this.productId,
    required this.size,
    required this.unitCost,
    this.sizeId,
  });

  SizeModel copyWith({
    int? productId,
    String? size,
    int? unitCost,
    int? sizeId,
  }) {
    return SizeModel(
      productId: productId ?? this.productId,
      size: size ?? this.size,
      unitCost: unitCost ?? this.unitCost,
      sizeId: sizeId ?? this.sizeId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productId': productId,
      'size': size,
      'unitCost': unitCost,
    };
  }

  factory SizeModel.fromMap(Map<String, dynamic> map) {
    return SizeModel(
      productId: map['productId'] as int,
      size: map['size'] as String,
      unitCost: map['unitCost'] as int,
      sizeId: map['sizeId'] != null ? map['sizeId'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SizeModel.fromJson(String source) =>
      SizeModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SizeModel(productId: $productId, size: $size, unitCost: $unitCost, sizeId: $sizeId)';
  }

  @override
  bool operator ==(covariant SizeModel other) {
    if (identical(this, other)) return true;

    return other.productId == productId &&
        other.size == size &&
        other.unitCost == unitCost &&
        other.sizeId == sizeId;
  }

  @override
  int get hashCode {
    return productId.hashCode ^
        size.hashCode ^
        unitCost.hashCode ^
        sizeId.hashCode;
  }
}
