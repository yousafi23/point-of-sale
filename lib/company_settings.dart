// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:point_of_sale_app/dashboard.dart';
import 'package:point_of_sale_app/database/company_model.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/general/my_custom_appbar.dart';
import 'package:point_of_sale_app/general/my_custom_snackbar.dart';

class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  _CompanySettingsScreenState createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  final companyNameController = TextEditingController();
  final serviceChargesCont = TextEditingController();
  final gstCont = TextEditingController();
  final discountCont = TextEditingController();
  File? logoImage;
  Uint8List? imageBytes;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final result =
        await DatabaseHelper.instance.getRecord('Company', 'companyId=?', 0);

    companyNameController.text = result![0]['companyName'].toString();
    gstCont.text = result[0]['gst'].toString();
    serviceChargesCont.text = result[0]['serviceCharges'].toString();
    discountCont.text = result[0]['discount'].toString();
    imageBytes = result[0]['companyLogo'] as Uint8List;

    setState(() {});
  }

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        logoImage = File(pickedFile.path);
      }
    });
  }

  Future<void> _saveToDatabase() async {
    // if (logoImage == null) return;

    final Uint8List bytes = (await logoImage?.readAsBytes()) ?? imageBytes!;

    final CompanyModel companyModel = CompanyModel(
      companyName: companyNameController.text.trim(),
      companyLogo: bytes,
      serviceCharges: int.tryParse(serviceChargesCont.text.trim()) ?? 0,
      gst: int.tryParse(gstCont.text.trim()) ?? 0,
      discount: int.tryParse(discountCont.text.trim()) ?? 0,
    );
    await DatabaseHelper.instance
        .updateRecord('Company', companyModel.toMap(), 'companyId=?', 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myCustomAppBar(
        "Settings",
        const Color.fromARGB(255, 116, 2, 122),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextField(
                          controller: companyNameController,
                          decoration:
                              const InputDecoration(labelText: 'Company Name'),
                        ),
                        TextField(
                            controller: serviceChargesCont,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: const InputDecoration(
                                labelText: 'Service Charges')),
                        TextField(
                            controller: gstCont,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration:
                                const InputDecoration(labelText: 'GST %')),
                        TextField(
                            controller: discountCont,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration:
                                const InputDecoration(labelText: 'Discount %')),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 300,
                        width: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.purple.shade100, // Placeholder color
                          image: logoImage != null
                              ? DecorationImage(
                                  image: FileImage(logoImage!),
                                  fit: BoxFit
                                      .contain, // This will maintain the aspect ratio
                                )
                              : null,
                        ),
                        child: logoImage == null
                            ? Image.memory(
                                imageBytes!,
                                fit: BoxFit.contain,
                              )
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: ElevatedButton(
                          onPressed: _getImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 116, 2, 112),
                          ),
                          child: const Text('Select Logo'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            FloatingActionButton.extended(
              onPressed: () async {
                await _saveToDatabase();

                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Dashboard()));
                myCustomSnackBar(
                    message: 'Company settings Saved',
                    warning: false,
                    context: context);
              },
              backgroundColor: const Color.fromARGB(255, 116, 2, 112),
              label: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
