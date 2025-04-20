import 'package:flutter/material.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _formKey = GlobalKey<FormState>();
  String _itemStatus = 'Lost';
  String? _name, _contact, _itemName, _description, _location;

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
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Name
                _buildTextField(label: 'Your Name', onSaved: (val) => _name = val),

                const SizedBox(height: 12),
                // Contact
                _buildTextField(label: 'Contact Info (Phone or Email)', onSaved: (val) => _contact = val),

                const SizedBox(height: 22),
                // Lost/Found
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('Item Status'),
                  value: _itemStatus,
                  dropdownColor: const Color(0xFF242A3E),
                  items: ['Lost', 'Found'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _itemStatus = value!;
                    });
                  },
                ),

                const SizedBox(height: 12),
                // Item Name
                _buildTextField(label: 'Item Name', onSaved: (val) => _itemName = val),

                const SizedBox(height: 12),
                // Description
                _buildTextField(
                  label: 'Description',
                  onSaved: (val) => _description = val,
                  maxLines: 4,
                ),

                const SizedBox(height: 12),
                // Location
                _buildTextField(label: 'Last Seen Location', onSaved: (val) => _location = val),

                const SizedBox(height: 16),

                // Upload Image Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF242A3E),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // Placeholder logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Image upload coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Upload Image'),
                ),

                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Handle submission logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Item uploaded successfully!')),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
}
