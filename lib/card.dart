import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:rasanusantara_mobile/restaurant.dart';
import 'package:rasanusantara_mobile/Katalog/screens/restaurant_detail_page.dart';
import 'package:rasanusantara_mobile/favorite/favorite_provider.dart';
import 'package:rasanusantara_mobile/image.dart';

class FavoriteProductCard extends StatefulWidget {
  final Restaurant restaurant;

  const FavoriteProductCard({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  State<FavoriteProductCard> createState() => _FavoriteProductCardState();
}

class _FavoriteProductCardState extends State<FavoriteProductCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = Provider.of<CookieRequest>(context, listen: false);
      final favoriteProvider =
          Provider.of<FavoriteProvider>(context, listen: false);
      favoriteProvider.initializeFavorites(request);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        final isFavorite = favoriteProvider.isFavorite(widget.restaurant.id);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RestaurantDetailPage(
                  restaurant: widget.restaurant,
                ),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
                              child: AdaptiveImage(
                                imageUrl: widget.restaurant.image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : Container(
                              alignment: Alignment.center,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.restaurant.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            widget.restaurant.location,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.orange,
                                size: 14,
                              ),
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
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () {
                      final request =
                          Provider.of<CookieRequest>(context, listen: false);
                      favoriteProvider.toggleFavorite(
                        widget.restaurant.id,
                        request,
                        context,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
