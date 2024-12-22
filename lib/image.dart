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

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Gunakan WebImage di platform web
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
    } else {
      // Gunakan Image.network di platform mobile
      return Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          height: height,
          width: width,
          child: const Icon(Icons.image, size: 50, color: Colors.grey),
        ),
      );
    }
  }
}
