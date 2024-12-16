import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:rasanusantara_mobile/restaurant.dart';

class RestaurantCard extends StatefulWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    Key? key,
    required this.restaurant,
    required this.onTap,
  }) : super(key: key);

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();
  }

  // **1. Cek Status Favorit dari Backend**
  Future<void> checkFavoriteStatus() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final url = 'http://127.0.0.1:8000/favorite/json/';

    try {
      final response = await request.get(url);
      if (response != null) {
        setState(() {
          isFavorite = response.any(
            (fav) => fav['id'] == widget.restaurant.id,
          );
        });
      }
    } catch (e) {
      debugPrint('Error fetching favorite status: $e');
    }
  }

  Future<void> toggleFavorite() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final url = 'http://127.0.0.1:8000/favorite/toggle-favorite/';

    try {
      final response = await request.postJson(
        url,
        jsonEncode({'restaurant_id': widget.restaurant.id}),
      );

      // Parse response as Map
      if (response is Map<String, dynamic> && response['success'] == true) {
        setState(() {
          isFavorite = response['status'] == 'favorited';
        });
      } else {
        throw Exception(response['message'] ?? 'Gagal mengubah status favorit');
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Kesalahan'),
            content: Text('Gagal terhubung ke server: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  // **3. Tampilkan Alert Jika Belum Login**
  void _showLoginAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Belum Login'),
        content:
            const Text('Silakan login terlebih dahulu untuk menandai favorit.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: double.infinity,
          height: 100,
          child: Row(
            children: [
              // Gambar Restoran
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.network(
                  widget.restaurant.image,
                  width: 120,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant,
                          color: Colors.grey, size: 50),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Detail Restoran
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Restoran
                      Text(
                        widget.restaurant.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Lokasi Restoran
                      Text(
                        widget.restaurant.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Rating Restoran
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.orange, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.restaurant.rating}/5',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Favorite Button
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () => toggleFavorite(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
