// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PurchaseModel {
  final int? purchaseId;
  final DateTime purchaseDate;
  final double grandTotal;
  final String purchaseItemsList;

  PurchaseModel({
    this.purchaseId,
    required this.purchaseDate,
    required this.grandTotal,
    required this.purchaseItemsList,
  });

  PurchaseModel copyWith({
    int? purchaseId,
    DateTime? purchaseDate,
    double? grandTotal,
    String? purchaseItemsList,
  }) {
    return PurchaseModel(
      purchaseId: purchaseId ?? this.purchaseId,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      grandTotal: grandTotal ?? this.grandTotal,
      purchaseItemsList: purchaseItemsList ?? this.purchaseItemsList,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'purchaseId': purchaseId,
      'purchaseDate': purchaseDate.toString(),
      'grandTotal': grandTotal,
      'purchaseItemsList': purchaseItemsList,
    };
  }

  factory PurchaseModel.fromMap(Map<String, dynamic> map) {
    return PurchaseModel(
      purchaseId: map['purchaseId'] != null ? map['purchaseId'] as int : null,
      purchaseDate: DateTime.parse(map['purchaseDate']),
      grandTotal: map['grandTotal'],
      purchaseItemsList: map['purchaseItemsList'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PurchaseModel.fromJson(String source) =>
      PurchaseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PurchaseModel(purchaseId: $purchaseId, purchaseDate: $purchaseDate, grandTotal: $grandTotal, purchaseItemsList: $purchaseItemsList)';
  }

  @override
  bool operator ==(covariant PurchaseModel other) {
    if (identical(this, other)) return true;

    return other.purchaseId == purchaseId &&
        other.purchaseDate == purchaseDate &&
        other.grandTotal == grandTotal &&
        other.purchaseItemsList == purchaseItemsList;
  }

  @override
  int get hashCode {
    return purchaseId.hashCode ^
        purchaseDate.hashCode ^
        grandTotal.hashCode ^
        purchaseItemsList.hashCode;
  }
}
