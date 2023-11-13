import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:point_of_sale_app/database/company_model.dart';
import 'package:point_of_sale_app/database/db_helper.dart';

// ignore: must_be_immutable
class CompanySettingsScreen extends StatefulWidget {
  CompanySettingsScreen({super.key});

  @override
  _CompanySettingsScreenState createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  final companyNameController = TextEditingController();
  File? logoImage;

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
    // print('BYTEss=$logoImage');
    // print('BYTEss=$bytes');

    final CompanyModel companyModel = CompanyModel(
      companyName: companyNameController.text,
      companyLogo: bytes,
    );

    // print('modd=${companyModel.toMap()}');
    await DatabaseHelper.instance
        .updateRecord('Company', companyModel.toMap(), 'companyId=?', 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (logoImage != null)
              Image.file(
                logoImage!,
                height: 300,
                width: 300,
              ),
            ElevatedButton(
              onPressed: _getImage,
              child: const Text('Select Logo'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: companyNameController,
              decoration: const InputDecoration(labelText: 'Company Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _saveToDatabase();
                // print(logoImage);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings saved to database')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
