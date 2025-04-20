import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

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
                // Logo only (no text)
                Image.asset(
                  'assets/images/khoj_logo.png', // Replace with your actual image path
                  height: 100,
                ),
                const SizedBox(height: 30),

                // Fields
                _buildInput("Username"),
                const SizedBox(height: 12),
                _buildInput("Email"),
                const SizedBox(height: 12),
                _buildInput("Phone no."),
                const SizedBox(height: 12),
                _buildInput("Password", obscureText: true),
                const SizedBox(height: 12),
                _buildInput("Retype Password", obscureText: true),
                const SizedBox(height: 20),

                // Camera Icon Button (Profile Pic)
                IconButton(
                  onPressed: () {
                    // Implement image picker here
                  },
                  icon: const Icon(Icons.camera_alt, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Sign up Button
                _buildButton("Sign up", onPressed: () {
                  // Implement sign-up logic here
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String hint, {bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
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
