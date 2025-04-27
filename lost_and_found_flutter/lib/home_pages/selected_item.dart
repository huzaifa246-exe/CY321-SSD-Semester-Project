import 'package:flutter/material.dart';

class SelectedItemPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const SelectedItemPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<dynamic> images = item['image_url'] ?? [];

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
            // Swipable Images
            if (images.isNotEmpty)
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
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

            // Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['description'] ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  InfoRow(label: 'Location', value: item['location']),
                  const SizedBox(height: 8),
                  InfoRow(label: 'Contact', value: item['phone_number']),
                  const SizedBox(height: 8),
                  InfoRow(label: 'Date Posted', value: item['date_posted']),
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
          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
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
