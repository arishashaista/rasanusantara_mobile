import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:rasanusantara_mobile/favorite/favorite_provider.dart';
import 'package:rasanusantara_mobile/image.dart';
import 'package:rasanusantara_mobile/restaurant.dart';
import 'package:rasanusantara_mobile/Katalog/screens/restaurant_detail_page.dart';

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
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: AdaptiveImage(
                    imageUrl: widget.restaurant.image.isNotEmpty
                        ? widget.restaurant.image
                        : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRhdkA-pOR1l5lRdCAtAAA2XSt2qg-WxQcg5A&s',
                    width: 110,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            color: Colors.grey,
                            fontFamily: 'Montserrat',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.restaurant.menuItems.isNotEmpty &&
                            widget.restaurant.menuItems.first.categories
                                .isNotEmpty)
                          SizedBox(
                            height: 24, // Fixed height for single line
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 6),
                              itemCount: widget.restaurant.menuItems
                                  .expand((menuItem) => menuItem.categories)
                                  .toSet()
                                  .length,
                              itemBuilder: (context, index) {
                                final categories = widget.restaurant.menuItems
                                    .expand((menuItem) => menuItem.categories)
                                    .toSet()
                                    .toList();

                                if (index >= categories.length)
                                  return const SizedBox();

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange.shade200,
                                        Colors.orange,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    categories[index],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              },
                            ),
                          ),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.orange, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.restaurant.rating}/5',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    final request =
                        Provider.of<CookieRequest>(context, listen: false);
                    favoriteProvider.toggleFavorite(
                      widget.restaurant.id,
                      request,
                      context,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
