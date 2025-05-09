import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lost_and_found_flutter/constants.dart';
import 'package:photo_view/photo_view_gallery.dart';

class SelectedItemPage extends StatelessWidget {
  final Map<String, dynamic> item;
  final String? phoneNumber;

  const SelectedItemPage({
    super.key,
    required this.item,
    required this.phoneNumber,
  });

  Future<void> _confirmAndDelete(BuildContext context) async {
    final bool? confirmed = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final id = item['id'];
      final url = Uri.parse('$apiURL/delete_item');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id': id}),
        );

        if (response.statusCode == 200 && response.body == '62') {
          Navigator.of(context).pop(); // Go back
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item deleted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete item')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting item: $e')),
        );
      }
    }
  }

  void openImageViewer(BuildContext context, List images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: PhotoViewGallery.builder(
            itemCount: images.length,
            pageController: PageController(initialPage: initialIndex),
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(images[index]),
                errorBuilder: (context, error, stackTrace) =>
                    Image.asset('assets/images/placeholder.gif'),
              );
            },
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            loadingBuilder: (context, _) => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List imagesRaw = item['image_urls'] ?? [];
    final List<String> images = imagesRaw.cast<String>();

    return Scaffold(
      appBar: AppBar(
        title: Text(item['title'] ?? 'Item Details'),
        backgroundColor: const Color(0xFF242A3E),
      ),
      backgroundColor: const Color(0xFF081830),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images.isNotEmpty)
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => openImageViewer(context, images, index),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/loading.gif',
                        image: images[index],
                        fit: BoxFit.cover,
                        imageErrorBuilder: (context, error, stackTrace) =>
                            Image.asset('assets/images/placeholder.png'),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 300,
                color: Colors.grey,
                child: const Center(child: Icon(Icons.image, size: 100)),
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['description'] ?? '',
                    style:
                    const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  InfoRow(label: 'Location', value: item['location']),
                  const SizedBox(height: 8),
                  InfoRow(label: 'Contact', value: item['phone_number']),
                  const SizedBox(height: 8),
                  InfoRow(label: 'Date Posted', value: item['date_posted']),
                  const SizedBox(height: 16),
                  if (phoneNumber != null &&
                      phoneNumber == item['phone_number'])
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _confirmAndDelete(context),
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete Item'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const InfoRow({Key? key, required this.label, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return value == null
        ? const SizedBox()
        : Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
              color: Colors.white70, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
