import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../constants.dart'; // contains apiURL

class UploadPage extends StatefulWidget {
  final String? phoneNumber;
  const UploadPage({super.key, required this.phoneNumber});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _formKey = GlobalKey<FormState>();
  String _itemStatus = 'Lost';
  String? _name, _contact, _itemName, _description, _location;

  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  final supabase = Supabase.instance.client;

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 4) {
      _showMessage('Maximum 4 images allowed.');
      return;
    }

    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _selectedImages.add(picked));
    }
  }

  Future<File> _compressImage(File file) async {
    final Uint8List? compressed = await FlutterImageCompress.compressWithFile(
      file.path,
      quality: 70,
    );
    if (compressed == null) throw Exception('Compression failed');
    return File(file.path)..writeAsBytesSync(compressed);
  }

  Future<List<String>> _uploadImagesToSupabase() async {
    List<String> urls = [];

    for (final image in _selectedImages) {
      try {
        final file = await _compressImage(File(image.path));
        final filename = 'item_${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';

        final storageResponse = await supabase.storage.from('images').upload(filename, file);
        if (storageResponse.isEmpty) throw Exception("Upload failed");

        final publicUrl = supabase.storage.from('images').getPublicUrl(filename);
        urls.add(publicUrl);
      } catch (e) {
        _showMessage("Image upload failed: $e");
        rethrow; // Let the main handler catch and stop form submission
      }
    }

    return urls;
  }


  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImages.isEmpty) {
      _showMessage('Please upload at least one image.');
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isUploading = true);

    try {
      final imageUrls = await _uploadImagesToSupabase();

      final res = await http.post(
        Uri.parse('$apiURL/post_item'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "phone_number": widget.phoneNumber,
          "title": _itemName,
          "description": _description,
          "status": _itemStatus.toLowerCase(), // "lost" or "found"
          "location": _location,
          "image_url": imageUrls, // important: keep as list
          "date_posted": DateTime.now().toIso8601String(),
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        _showMessage("Item uploaded successfully!");
      } else {
        _showMessage("Upload failed: ${res.body}");
      }
    } catch (e) {
      _showMessage("Error: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }


  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildTextField({required String label, void Function(String?)? onSaved, int maxLines = 1}) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: _inputDecoration(label),
      validator: (value) => value!.isEmpty ? 'Required' : null,
      onSaved: onSaved,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: const Color(0xFF242A3E),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081830),
      appBar: AppBar(
        backgroundColor: const Color(0xFF242A3E),
        title: Image.asset('assets/images/khoj_logo.png', height: 40),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(label: 'Your Name', onSaved: (val) => _name = val),
                const SizedBox(height: 12),
                _buildTextField(label: 'Contact Info (Phone or Email)', onSaved: (val) => _contact = val),
                const SizedBox(height: 22),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('Item Status'),
                  value: _itemStatus,
                  dropdownColor: const Color(0xFF242A3E),
                  items: ['Lost', 'Found'].map((val) {
                    return DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(color: Colors.white)));
                  }).toList(),
                  onChanged: (val) => setState(() => _itemStatus = val!),
                ),
                const SizedBox(height: 12),
                _buildTextField(label: 'Item Name', onSaved: (val) => _itemName = val),
                const SizedBox(height: 12),
                _buildTextField(label: 'Description', onSaved: (val) => _description = val, maxLines: 4),
                const SizedBox(height: 12),
                _buildTextField(label: 'Last Seen Location', onSaved: (val) => _location = val),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final image = entry.value;
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(image.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedImages.removeAt(index)),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF242A3E),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Add Image'),
                ),

                const SizedBox(height: 24),

                _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
