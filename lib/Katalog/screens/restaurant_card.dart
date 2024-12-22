import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:rasanusantara_mobile/restaurant.dart';
import 'package:rasanusantara_mobile/favorite/favorite_provider.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    Key? key,
    required this.restaurant,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        final isFavorite = favoriteProvider.isFavorite(restaurant.id);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 100,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Image.network(
                      restaurant.image.isNotEmpty
                          ? restaurant.image
                          : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRhdkA-pOR1l5lRdCAtAAA2XSt2qg-WxQcg5A&s',
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            restaurant.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            restaurant.location,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (restaurant.menuItems.isNotEmpty &&
                              restaurant.menuItems.first.categories.isNotEmpty)
                            SizedBox(
                              height: 24, // Fixed height for single line
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 6),
                                itemCount: restaurant.menuItems
                                    .expand((menuItem) => menuItem.categories)
                                    .toSet()
                                    .length,
                                itemBuilder: (context, index) {
                                  final categories = restaurant.menuItems
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
                              const Icon(Icons.star_rounded,
                                  color: Colors.orange, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${restaurant.rating}/5',
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
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      final request =
                          Provider.of<CookieRequest>(context, listen: false);
                      favoriteProvider.toggleFavorite(
                        restaurant.id,
                        request,
                        context,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
