import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:rasanusantara_mobile/restaurant.dart';

class FavoriteProductCard extends StatefulWidget {
  final Restaurant restaurant; // Model Restaurant

  const FavoriteProductCard({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  State<FavoriteProductCard> createState() => _FavoriteProductCardState();
}

class _FavoriteProductCardState extends State<FavoriteProductCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();
  }

  // Fungsi untuk mengecek apakah restoran sudah difavoritkan
  Future<void> checkFavoriteStatus() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final url = 'http://127.0.0.1:8000/favorite/json/';

    try {
      final response = await request.get(url);
      if (response != null) {
        setState(() {
          // Periksa apakah restoran ini ada dalam daftar favorit
          isFavorite = response.any(
            (fav) => fav['id'] == widget.restaurant.id,
          );
        });
      }
    } catch (e) {
      // Tangani error saat memeriksa status favorit
      debugPrint('Error checking favorite status: $e');
    }
  }

  // Fungsi untuk toggle favorit
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

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: widget.restaurant.image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        child: Image.network(
                          widget.restaurant.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Container(
                        alignment: Alignment.center,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image,
                            size: 50, color: Colors.grey),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.restaurant.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                child: Text(
                  widget.restaurant.location,
                  style: TextStyle(
                      color: Colors.grey.shade700,
                      fontFamily: 'Montserrat',
                      fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.restaurant.rating.toString()}/5',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: () async {
                await toggleFavorite();
              },
              child: Icon(
                Icons.favorite,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
