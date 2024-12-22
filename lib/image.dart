import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdaptiveImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit fit;

  const AdaptiveImage({
    Key? key,
    required this.imageUrl,
    this.height = 200,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  String _getProxiedUrl(String url) {
    return "https://cors-proxy.fringe.zone/$url";
  }

  bool _isBase64(String data) {
    final base64RegExp = RegExp(r'^data:image\/[a-zA-Z]+;base64,');
    return base64RegExp.hasMatch(data);
  }

  Uint8List _decodeBase64(String base64String) {
    // Hapus prefix base64 jika ada
    final cleanedBase64 = base64String.split(',').last;
    return base64Decode(cleanedBase64);
  }

  @override
  Widget build(BuildContext context) {
    if (_isBase64(imageUrl)) {
      // Jika gambar dalam format base64
      final Uint8List imageBytes = _decodeBase64(imageUrl);
      return Image.memory(
        imageBytes,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading base64 image: $error');
          return Container(
            color: Colors.grey[200],
            child: const Icon(Icons.error),
          );
        },
      );
    } else {
      // Jika gambar berupa URL
      return CachedNetworkImage(
        imageUrl: _getProxiedUrl(imageUrl),
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) {
          print('Error loading image: $error');
          return Container(
            color: Colors.grey[200],
            child: const Icon(Icons.error),
          );
        },
      );
    }
  }
}
