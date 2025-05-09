import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lost_and_found_flutter/constants.dart';
import 'dart:convert';
import 'package:lost_and_found_flutter/home_pages/profile.dart';
import 'package:lost_and_found_flutter/home_pages/selected_item.dart';

class LostPage extends StatefulWidget {
  final String? phoneNumber;
  const LostPage({super.key, required this.phoneNumber});

  @override
  State<LostPage> createState() => _LostPageState();
}

class _LostPageState extends State<LostPage> {
  List<Map<String, dynamic>> lostItems = [];
  List<Map<String, dynamic>> filteredItems = [];
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
        if (decoded is List) {
          final items = decoded
              .where((item) => item['status'] == 'lost')
              .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
              .toList();
          setState(() {
            lostItems = items;
            filteredItems = items;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching items: $e');
    }
  }

  Future<void> searchItems(String query) async {
    const url = '$apiURL/search_items';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'search': query, 'status': 'lost'}),
      );
      if (response.statusCode == 200) {
        final results = json.decode(response.body);
        if (results is List) {
          setState(() {
            filteredItems = results
                .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
                .toList();
          });
        }
      } else {
        print("Search failed with status ${response.statusCode}");
      }
    } catch (e) {
      print("Error searching items: $e");
    }
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (query) {
                      if (query.isEmpty) {
                        setState(() {
                          filteredItems = lostItems;
                        });
                      }
                    },
                    onSubmitted: (query) {
                      searchItems(query);
                    },
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
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    searchItems(searchController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                    backgroundColor: Colors.white,
                  ),
                  child: const Icon(Icons.search, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Lost item cards or no items found
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchLostItems,
                child: filteredItems.isEmpty
                    ? const Center(
                  child: Text(
                    'No items found',
                    style: TextStyle(
                        color: Colors.white, fontSize: 18),
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final imagesRaw = item['image_urls'];
                    final List<String> images = imagesRaw is List
                        ? imagesRaw.map<String>((img) => img.toString()).toList()
                        : [];

                    final firstImage = images.isNotEmpty ? images[0] : null;

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectedItemPage(
                              item: item,
                              phoneNumber: widget.phoneNumber,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                              ),
                              child: firstImage != null
                                  ? FadeInImage.assetNetwork(
                                placeholder:
                                'assets/images/loading.gif',
                                image: firstImage,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                imageErrorBuilder: (context,
                                    error, stackTrace) =>
                                const Icon(
                                    Icons.broken_image,
                                    size: 100),
                              )
                                  : Container(
                                height: 100,
                                width: 100,
                                color: Colors.grey,
                                child: const Icon(Icons.image,
                                    size: 50),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] ?? '',
                                      style: const TextStyle(
                                          fontWeight:
                                          FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      "Lost item",
                                      style:
                                      TextStyle(fontSize: 12),
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
            ),
          ],
        ),
      ),
    );
  }
}
