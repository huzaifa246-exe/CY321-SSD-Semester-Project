import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lost_and_found_flutter/constants.dart';
import 'dart:convert';
import 'package:lost_and_found_flutter/home_pages/profile.dart';
import 'package:lost_and_found_flutter/home_pages/selected_item.dart';

class LostPage extends StatefulWidget {
  const LostPage({super.key});

  @override
  State<LostPage> createState() => _LostPageState();
}

class _LostPageState extends State<LostPage> {
  List<dynamic> lostItems = [];
  List<dynamic> filteredItems = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchLostItems();
  }

  Future<void> fetchLostItems() async {
    const url = '$apiURL/get_items';
    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print(decoded);
        if (decoded is List) {
          setState(() {
            lostItems = decoded.where((item) => item['status'] == 'lost').toList();
            filteredItems = lostItems;
            isLoading = false;
          });
        } else {
          print('Unexpected response format: $decoded');
        }
      } else {
        print('Failed to load items: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching items: $e');
    }
  }

  void searchItems(String query) {
    final results = lostItems.where((item) {
      final title = (item['title'] ?? '').toLowerCase();
      return title.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredItems = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF242A3E),
        elevation: 0,
        title: Image.asset(
          'assets/images/khoj_logo.png',
          height: 40,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
          )
        ],
      ),
      backgroundColor: const Color(0xFF081830),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: searchController,
              onChanged: searchItems,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lost item cards or no items found
            Expanded(
              child: filteredItems.isEmpty
                  ? const Center(
                child: Text(
                  'No items found',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
                  : ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final images = item['image_url'] ?? [];
                  final firstImage = images.isNotEmpty ? images[0] : null;

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectedItemPage(item: item),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                            ),
                            child: firstImage != null
                                ? Image.network(
                              firstImage,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 100),
                            )
                                : Container(
                              height: 100,
                              width: 100,
                              color: Colors.grey,
                              child: const Icon(Icons.image, size: 50),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Lost item",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.expand_more),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
