// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:point_of_sale_app/admin/products_screen.dart';
import 'package:point_of_sale_app/database/company_model.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/general/my_custom_appbar.dart';
import 'package:point_of_sale_app/general/my_custom_snackbar.dart';

class CompanySettingsScreen extends StatefulWidget {
  CompanySettingsScreen({super.key});

  @override
  _CompanySettingsScreenState createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  final companyNameController = TextEditingController();
  final serviceChargesCont = TextEditingController();
  final gstCont = TextEditingController();
  final discountCont = TextEditingController();
  File? logoImage;

  // @override
  // Future<void> initState()  {
  //   super.initState();

  //   // companyNameController.text =
  // }

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
    if (logoImage == null) return;

    final Uint8List bytes = await logoImage!.readAsBytes();

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
        "Company Settings",
        const Color.fromARGB(255, 116, 2, 122),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  SizedBox(
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
                            decoration: const InputDecoration(
                                labelText: 'Service Charges')),
                        TextField(
                            controller: gstCont,
                            decoration:
                                const InputDecoration(labelText: 'GST %')),
                        TextField(
                            controller: discountCont,
                            decoration:
                                const InputDecoration(labelText: 'Discount %')),
                      ],
                    ),
                  )
                ],
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
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[200], // Placeholder color
                      image: logoImage != null
                          ? DecorationImage(
                              image: FileImage(logoImage!),
                              fit: BoxFit
                                  .contain, // This will maintain the aspect ratio
                            )
                          : null,
                    ),
                    child: logoImage == null
                        ? Icon(Icons.image, size: 50, color: Colors.grey[600])
                        : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _getImage,
                    child: const Text('Select Logo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 116, 2, 112),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // SizedBox(
                  //   width: 300,
                  //   child: TextField(
                  //     controller: companyNameController,
                  //     decoration:
                  //         const InputDecoration(labelText: 'Company Name'),
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await _saveToDatabase();

                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const ProductsScreen()));
                      myCustomSnackBar(
                          message: 'Company settings Saved',
                          warning: false,
                          context: context);
                    },
                    child: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 116, 2, 112),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
