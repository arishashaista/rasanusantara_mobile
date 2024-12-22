import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:rasanusantara_mobile/favorite/favorite_provider.dart';
import 'package:rasanusantara_mobile/image.dart';
import 'package:rasanusantara_mobile/reservasi/screens/reservation_form.dart';
import 'package:rasanusantara_mobile/restaurant.dart';
import 'package:rasanusantara_mobile/review/screens/review_page.dart';

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailPage({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = Provider.of<CookieRequest>(context, listen: false);
      final favoriteProvider =
          Provider.of<FavoriteProvider>(context, listen: false);
      favoriteProvider
          .initializeFavorites(request); // Sinkronisasi data favorit
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        final isFavorite = favoriteProvider.isFavorite(widget.restaurant.id);

        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      child: AdaptiveImage(
                        imageUrl: widget.restaurant.image.isNotEmpty
                            ? widget.restaurant.image
                            : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRhdkA-pOR1l5lRdCAtAAA2XSt2qg-WxQcg5A&s',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 10,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: Colors.orange,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 10,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            final request = Provider.of<CookieRequest>(context,
                                listen: false);
                            favoriteProvider.toggleFavorite(
                              widget.restaurant.id,
                              request,
                              context,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.restaurant.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.restaurant.location.isNotEmpty
                            ? widget.restaurant.location
                            : "Lokasi tidak tersedia",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 20),
                          Text(
                            ' ${widget.restaurant.rating}',
                            style: const TextStyle(fontFamily: 'Montserrat'),
                          ),
                          Text(
                            ' • Rp${widget.restaurant.averagePrice}',
                            style: const TextStyle(fontFamily: 'Montserrat'),
                          ),
                        ],
                      ),
                      if (widget.restaurant.menuItems.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: widget.restaurant.menuItems
                              .expand((menuItem) => menuItem
                                  .categories) // Gabungkan semua kategori
                              .toSet() // Hapus kategori duplikat
                              .map((category) {
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
                                category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 20),
                      const Text(
                        'Daftar Menu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.restaurant.menuItems.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              '• ${item.name}',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          )),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReservationForm(
                                      restaurantName: widget.restaurant.name,
                                      restaurantImage: widget.restaurant.image,
                                      restaurantid: widget.restaurant.id,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                'Reservasi',
                                style: TextStyle(fontFamily: 'Montserrat'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final request = Provider.of<CookieRequest>(
                                    context,
                                    listen: false);

                                // Cek status login
                                if (!request.loggedIn) {
                                  // Jika belum login, tampilkan dialog dan redirect ke login page
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Login Required'),
                                      content: const Text(
                                          'Login untuk menambahkan review'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.pushNamed(
                                                context, '/login');
                                          },
                                          child: const Text('Login'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                      ],
                                    ),
                                  );
                                  return;
                                }

                                // Jika sudah login, lanjutkan ke halaman review
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReviewPage(
                                      restaurantName: widget.restaurant.name,
                                      restaurantImage: widget.restaurant.image,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                'Review',
                                style: TextStyle(fontFamily: 'Montserrat'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
