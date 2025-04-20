import 'package:flutter/material.dart';
import 'lost_page.dart';
import 'found_page.dart';
import 'upload_page.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    LostPage(),
    UploadPage(),
    FoundPage(),
  ];

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
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 0.0,
        color: const Color(0xFF1F2A40).withOpacity(0.95),
        elevation: 8,
        child: SizedBox(
          height: 25, // Reduced height for a tighter layout
          child: Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _onItemTapped(0),
                  child: Center(
                    child: _buildNavItem(
                      label: 'Lost',
                      isActive: _selectedIndex == 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 50), // Extra space for FAB
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _onItemTapped(2),
                  child: Center(
                    child: _buildNavItem(
                      label: 'Found',
                      isActive: _selectedIndex == 2,
                    ),
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
