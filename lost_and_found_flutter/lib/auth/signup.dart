import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants.dart'; // apiURL here

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypePasswordController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isLoading = false;

  final supabase = Supabase.instance.client;

  Future<void> _pickImage() async {
    if (_selectedImage != null) {
      _showMessage('Only one profile picture allowed.');
      return;
    }

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _captureImage() async {
    if (_selectedImage != null) {
      _showMessage('Only one profile picture allowed.');
      return;
    }

    final XFile? capturedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (capturedFile != null) {
      setState(() {
        _selectedImage = capturedFile;
      });
    }
  }

  Future<File> _compressImage(File file) async {
    final Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 70,
    );
    if (compressedBytes == null) {
      throw Exception('Image compression failed');
    }
    return File(file.path)..writeAsBytesSync(compressedBytes);
  }

  Future<String> _uploadImageToSupabase(File file) async {
    final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';

    final response = await supabase.storage
        .from('profile-pictures') // your bucket name
        .upload(fileName, file);

    if (response.isEmpty) {
      throw Exception('Failed to upload image to Supabase');
    }

    final String publicUrl = supabase.storage
        .from('profile-pictures')
        .getPublicUrl(fileName);

    return publicUrl;
  }


  Future<void> _signUp() async {
    if (_passwordController.text.trim() != _retypePasswordController.text.trim()) {
      _showMessage('Passwords do not match.');
      return;
    }

    if (_selectedImage == null) {
      _showMessage('Please select a profile picture.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      File file = File(_selectedImage!.path);
      String downloadUrl = await _uploadImageToSupabase(file);

      final response = await http.post(
        Uri.parse('$apiURL/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'username': _usernameController.text.trim(),
          'profile_pic': downloadUrl, // single URL
        }),
      );

      if (response.body == '62') {
        _showMessage('Signup successful!');
        Navigator.pop(context);
      } else {
        _showMessage('Signup failed. Please try again.');
      }
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000428), Color(0xFF004e92)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/khoj_logo.png', height: 100),
                const SizedBox(height: 30),
                _buildInput(_usernameController, "Username"),
                const SizedBox(height: 12),
                _buildInput(_emailController, "Email"),
                const SizedBox(height: 12),
                _buildInput(_phoneController, "Phone No. (whatsapp) +923001234123 format"),
                const SizedBox(height: 12),
                _buildInput(_passwordController, "Password", obscureText: true),
                const SizedBox(height: 12),
                _buildInput(_retypePasswordController, "Retype Password", obscureText: true),
                const SizedBox(height: 20),
                if (_selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_selectedImage!.path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: _captureImage,
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : _buildButton("Sign Up", onPressed: _signUp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54,fontSize: 12),
        filled: true,
        fillColor: Colors.white10,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildButton(String text, {required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
