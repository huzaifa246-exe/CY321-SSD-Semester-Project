import 'package:flutter/material.dart';
import 'package:lost_and_found_flutter/constants.dart';
import 'lost_page.dart';
import 'found_page.dart';
import 'upload_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _selectedIndex = 0;
  String? phoneNumber;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    fetchPhoneNumber();
  }

  Future<void> fetchPhoneNumber() async {
    final email = _auth.currentUser?.email;

    if (email == null) return;

    final response = await http.post(
      Uri.parse('$apiURL/get_phone_number'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        phoneNumber = data['phone_number'];
      });
    } else {
      // handle error
      print('Failed to fetch phone number');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavItem({required String label, required bool isActive}) {
    return Text(
      label,
      style: TextStyle(
        color: isActive ? Colors.amber[800] : Colors.grey[500],
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (phoneNumber == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> _pages = [
      LostPage(phoneNumber: phoneNumber!),
      UploadPage(phoneNumber: phoneNumber!),
      FoundPage(phoneNumber: phoneNumber!),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 0.0,
        color: const Color(0xFF1F2A40).withOpacity(0.95),
        elevation: 8,
        child: SizedBox(
          height: 25,
          child: Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () => _onItemTapped(0),
                  child: Center(
                    child: _buildNavItem(label: 'Lost', isActive: _selectedIndex == 0),
                  ),
                ),
              ),
              const SizedBox(width: 50),
              Expanded(
                child: GestureDetector(
                  onTap: () => _onItemTapped(2),
                  child: Center(
                    child: _buildNavItem(label: 'Found', isActive: _selectedIndex == 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 68,
        width: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.amber[800]!, Colors.amberAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.4),
              blurRadius: 12,
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () => _onItemTapped(1),
          child: const Icon(Icons.add, size: 28, color: Colors.black),
        ),
      ),
    );
  }
}
