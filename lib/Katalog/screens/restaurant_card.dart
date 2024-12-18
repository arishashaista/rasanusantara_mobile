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

  // Fungsi mengecek status favorit
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

  // Fungsi toggle favorit
  Future<void> toggleFavorite() async {
    final request = Provider.of<CookieRequest>(context, listen: false);

    if (!request.loggedIn) {
      // Jika belum login, tampilkan peringatan
      _showLoginAlert();
      return;
    }

    final url = 'http://127.0.0.1:8000/favorite/toggle-favorite/';

    try {
      final response = await request.postJson(
        url,
        jsonEncode({'restaurant_id': widget.restaurant.id}),
      );

      if (response is Map<String, dynamic> && response['success'] == true) {
        setState(() {
          isFavorite = response['status'] == 'favorited';
        });
      } else {
        throw Exception(response['message'] ?? 'Gagal mengubah status favorit');
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog('Gagal terhubung ke server: $e');
      }
    }
  }

  // Fungsi menampilkan alert jika belum login
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

  // Fungsi menampilkan error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kesalahan'),
        content: Text(message),
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
                  width: 110,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 110,
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant,
                          color: Colors.grey, size: 50),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Detail Restoran
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.restaurant.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        widget.restaurant.location,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.restaurant.menuItems.isNotEmpty &&
                          widget
                              .restaurant.menuItems.first.categories.isNotEmpty)
                        Wrap(
                          spacing: 6, // Spasi antar kategori
                          runSpacing:
                              4, // Spasi antar baris kategori jika lebih dari satu baris
                          children: widget.restaurant.menuItems.first.categories
                              .map((category) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.shade200,
                                    Colors.orange
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.orange, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.restaurant.rating}/5',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Tombol Favorit
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: toggleFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
