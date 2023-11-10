import 'dart:typed_data';

class CompanyModel {
  final int? companyId;
  final String companyName;
  final Uint8List companyLogo;

  CompanyModel({this.companyId, required this.companyName, required this.companyLogo});

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'companyLogo': companyLogo,
    };
  }

  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    return CompanyModel(
      companyId : map['companyId'],
      companyName: map['companyName'],
      companyLogo: map['companyLogo'],
    );
  }
}
