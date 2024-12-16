import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import '../models/pdf_config.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class PDFConfigScreen extends StatefulWidget {
  const PDFConfigScreen({super.key});

  @override
  _PDFConfigScreenState createState() => _PDFConfigScreenState();
}

class _PDFConfigScreenState extends State<PDFConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _companyName;
  String? _companyLogo;
  String? _headerText;
  String? _footerText;
  PdfPageFormat _pageFormat = PdfPageFormat.a4;
  bool _includeCompanyInfo = true;
  bool _includePageNumbers = true;
  bool _includeDateRange = true;

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _companyLogo = base64Encode(bytes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Export Settings'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Company Name'),
              onSaved: (value) => _companyName = value,
            ),
            ElevatedButton(
              onPressed: _pickLogo,
              child: const Text('Select Company Logo'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Header Text'),
              onSaved: (value) => _headerText = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Footer Text'),
              onSaved: (value) => _footerText = value,
            ),
            DropdownButtonFormField<PdfPageFormat>(
              value: _pageFormat,
              items: const [
                DropdownMenuItem(
                  value: PdfPageFormat.a4,
                  child: Text('A4'),
                ),
                DropdownMenuItem(
                  value: PdfPageFormat.letter,
                  child: Text('Letter'),
                ),
                // Add more page formats as needed
              ],
              onChanged: (value) {
                setState(() {
                  _pageFormat = value!;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Include Company Info'),
              value: _includeCompanyInfo,
              onChanged: (value) {
                setState(() {
                  _includeCompanyInfo = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Include Page Numbers'),
              value: _includePageNumbers,
              onChanged: (value) {
                setState(() {
                  _includePageNumbers = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Include Date Range'),
              value: _includeDateRange,
              onChanged: (value) {
                setState(() {
                  _includeDateRange = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Navigator.pop(
                    context,
                    PDFConfig(
                      companyName: _companyName,
                      companyLogo: _companyLogo,
                      headerText: _headerText,
                      footerText: _footerText,
                      pageFormat: _pageFormat,
                      includeCompanyInfo: _includeCompanyInfo,
                      includePageNumbers: _includePageNumbers,
                      includeDateRange: _includeDateRange,
                    ),
                  );
                }
              },
              child: const Text('Save Configuration'),
            ),
          ],
        ),
      ),
    );
  }
} 