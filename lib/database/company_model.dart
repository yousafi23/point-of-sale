import 'dart:typed_data';

class CompanyModel {
  final int? companyId;
  final String companyName;
  final Uint8List companyLogo;
  final int serviceCharges;
  final int gst;
  final int discount;

  CompanyModel({
    this.companyId,
    required this.companyName,
    required this.companyLogo,
    required this.serviceCharges,
    required this.gst,
    required this.discount,
  });

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'companyLogo': companyLogo,
      'serviceCharges': serviceCharges,
      'gst': gst,
      'discount': discount,
    };
  }

  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    return CompanyModel(
        companyId: map['companyId'],
        companyName: map['companyName'],
        companyLogo: map['companyLogo'],
        serviceCharges: map['serviceCharges'],
        gst: map['gst'],
        discount: map['discount']);
  }
}
