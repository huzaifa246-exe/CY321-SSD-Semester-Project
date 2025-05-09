import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../auth/login.dart';
import '../constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? email;
  String? username;
  String? phoneNumber;
  String? profilePic;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final url = Uri.parse('$apiURL/profile');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': user.email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          email = data['email'];
          username = data['username'];
          phoneNumber = data['phone_number'];
          profilePic = data['profile_pic'];
          isLoading = false;
        });
      } else {
        print('Profile fetch failed: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching profile: $e');
      setState(() => isLoading = false);
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Log Out"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF242A3E),
        elevation: 0,
        title: Image.asset('assets/images/khoj_logo.png', height: 40),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF081830),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: profilePic != null && profilePic!.isNotEmpty
                  ? CircleAvatar(
                radius: 46,
                backgroundImage: NetworkImage(profilePic!),
                backgroundColor: Colors.grey.shade200,
              )
                  : const CircleAvatar(
                radius: 46,
                backgroundColor: Color(0xFF081830),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            // User Info Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: const Color(0xFF1C2A49),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.white),
                      title: const Text("Username", style: TextStyle(color: Colors.white)),
                      subtitle: Text(username ?? '-', style: const TextStyle(color: Colors.grey)),
                    ),
                    const Divider(color: Colors.white24),
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.white),
                      title: const Text("Email", style: TextStyle(color: Colors.white)),
                      subtitle: Text(email ?? '-', style: const TextStyle(color: Colors.grey)),
                    ),
                    const Divider(color: Colors.white24),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.white),
                      title: const Text("Phone Number", style: TextStyle(color: Colors.white)),
                      subtitle: Text(phoneNumber ?? '-', style: const TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout),
                label: const Text("Log Out"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
