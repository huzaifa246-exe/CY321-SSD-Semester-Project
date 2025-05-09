import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lost_and_found_flutter/constants.dart';
import 'dart:convert';
import 'package:lost_and_found_flutter/home_pages/profile.dart';
import 'package:lost_and_found_flutter/home_pages/selected_item.dart';

class FoundPage extends StatefulWidget {
  final String? phoneNumber;
  const FoundPage({super.key, required this.phoneNumber});

  @override
  State<FoundPage> createState() => _FoundPageState();
}

class _FoundPageState extends State<FoundPage> {
  List<dynamic> foundItems = [];
  List<dynamic> filteredItems = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFoundItems();
  }

  Future<void> fetchFoundItems() async {
    const url = '$apiURL/get_items';
    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final items = List<Map<String, dynamic>>.from(decoded);
        setState(() {
          foundItems =
              items.where((item) => item['status'] == 'found').toList();
          filteredItems = foundItems;
          isLoading = false;
        });
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
        body: json.encode({'search': query, 'status': 'found'}),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final results = List<Map<String, dynamic>>.from(decoded);
        setState(() {
          filteredItems = results;
        });
      } else {
        print("Search failed with status ${response.statusCode}");
      }
    } catch (e) {
      print("Error searching items: $e");
    }
  }

  List<String> parseImageUrls(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    } else if (value is String) {
      try {
        final parsed = json.decode(value);
        if (parsed is List) {
          return parsed.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }
    return [];
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
                          filteredItems = foundItems;
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

            // Found item cards or no items found
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchFoundItems,
                child: filteredItems.isEmpty
                    ? const Center(
                  child: Text(
                    'No items found',
                    style:
                    TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];

                    final imageUrls =
                    parseImageUrls(item['image_urls']);
                    final firstImage =
                    imageUrls.isNotEmpty ? imageUrls[0] : null;

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
                                imageErrorBuilder:
                                    (context, error,
                                    stackTrace) =>
                                    Image.asset(
                                      'assets/images/placeholder.png',
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
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
                                      "Found item",
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
