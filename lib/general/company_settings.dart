import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({Key? key}) : super(key: key);

  @override
  _CompanySettingsScreenState createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  TextEditingController companyNameController = TextEditingController();
  File? logoImage;

  Future<void> _getImage() async {
    final pickedFile =
        // await ImagePicker().getImage(source: ImageSource.gallery);
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        logoImage = File(pickedFile.path);
      }
    });
  }

  Future<void> _saveToAssets() async {
    if (logoImage == null) return;

    final ByteData data = await rootBundle.load('assets/logo/company_logo.png');
    final List<int> bytes = data.buffer.asUint8List();

    await File('assets/logo/company_logo.png').writeAsBytes(bytes);
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
                height: 100,
                width: 100,
                fit: BoxFit.cover,
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
                await _saveToAssets();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logo saved to assets')),
                );
              },
              child: const Text('Save to Assets'),
            ),
          ],
        ),
      ),
    );
  }
}
