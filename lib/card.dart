import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:rasanusantara_mobile/model.dart';

class FavoriteProductCard extends StatefulWidget {
  final Fields fields;
  final String id; // Ubah tipe id ke String

  const FavoriteProductCard({
    Key? key,
    required this.fields,
    required this.id,
  }) : super(key: key);

  @override
  State<FavoriteProductCard> createState() => _FavoriteProductCardState();
}

class _FavoriteProductCardState extends State<FavoriteProductCard> {
  bool isFavorite = false;

  Future<void> toggleFavorite(CookieRequest request) async {
    final url = 'http://127.0.0.1:8000/favorite/toggle-favorite/';
    final response = await request.postJson(
      url,
      {'restaurant_id': widget.id}, // JSON payload
    );

    if (response['success'] == true) {
      setState(() {
        isFavorite = response['status'] == 'favorited';
      });
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Gagal Mengubah Favorit'),
            content: Text(response['message'] ?? 'Terjadi kesalahan'),
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
    final request = Provider.of<CookieRequest>(context, listen: false);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: widget.fields.image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        child: Image.network(
                          widget.fields.image,
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
                  widget.fields.name,
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
                  widget.fields.location,
                  style: TextStyle(
                      color: Colors.grey.shade700,
                      fontFamily: 'Montserrat',
                      fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.fields.rating.toString()}/5',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: () async {
                if (request.loggedIn) {
                  await toggleFavorite(request);
                } else {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Tidak Dapat Menyukai'),
                        content: const Text(
                            'Anda harus login terlebih dahulu untuk menandai favorit.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
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
