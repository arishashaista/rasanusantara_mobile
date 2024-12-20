import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rasanusantara_mobile/Katalog/screens/restaurant_list_page.dart';
import 'dart:convert';
import 'package:rasanusantara_mobile/card.dart';
import 'package:rasanusantara_mobile/navbar.dart';
import 'package:rasanusantara_mobile/restaurant.dart';
import 'package:rasanusantara_mobile/Katalog/screens/restaurant_detail_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Restaurant> _allRestaurants = [];
  List<Restaurant> _searchResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    final url = Uri.parse('http://127.0.0.1:8000/json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      setState(() {
        _allRestaurants = data.map((e) => Restaurant.fromJson(e)).toList();
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  void _searchRestaurants(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
    } else {
      final results = _allRestaurants.where((restaurant) {
        final name = restaurant.name.toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
      setState(() {
        _searchResults = results.take(2).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topRatedRestaurants = List<Restaurant>.from(_allRestaurants)
      ..sort((a, b) => b.rating.compareTo(a.rating));

    final gudegRestaurants = _allRestaurants
        .where((restaurant) =>
            restaurant.menuItems.isNotEmpty &&
            restaurant.menuItems.first.categories.contains('Gudeg'))
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));

    return Scaffold(
      body: Stack(
        children: [
          // Background and main content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Background image
                Container(
                  height: 250,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('lib/assets/Homepage.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Spacing for search bar and results
                SizedBox(height: 10),
                // Content below search bar
                _buildSectionHeader('Restoran Populer'),
                _buildRestaurantList(topRatedRestaurants.take(8).toList()),
                _buildSectionHeader('Restoran Gudeg'),
                _buildRestaurantList(gudegRestaurants.take(8).toList()),
              ],
            ),
          ),

          // Search bar and results overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            left: 14,
            right: 14,
            child: Column(
              children: [
                // Search bar
                _buildSearchBar(),
                const SizedBox(height: 10),
                // Search results
                if (_searchResults.isNotEmpty) _buildSearchResultsOverlay(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Align(
      alignment: Alignment.center, // Menempatkan di tengah horizontal
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85, // Lebar 85% dari layar
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: _searchRestaurants,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: 'Ingin makan apa hari ini?',
            hintStyle: const TextStyle(
              fontSize: 14,
              fontFamily: 'Montserrat',
              color: Colors.grey,
            ),
            border: InputBorder.none,
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.orange,
              size: 24,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Navbar(selectedIndex: 1),
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Lainnya',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantList(List<Restaurant> restaurants) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            child: FavoriteProductCard(
              restaurant: restaurant,
            ),
          );
        },
      ),
    );
  }

  // Widget _buildSearchResults() {
  //   return Container(
  //     padding: const EdgeInsets.all(8),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: const [
  //         BoxShadow(
  //           color: Colors.black12,
  //           blurRadius: 5,
  //           offset: Offset(0, 3),
  //         ),
  //       ],
  //     ),
  //     child: ListView.builder(
  //       shrinkWrap: true,
  //       physics: const NeverScrollableScrollPhysics(),
  //       itemCount: _searchResults.length,
  //       itemBuilder: (context, index) {
  //         final restaurant = _searchResults[index];
  //         return ListTile(
  //           leading: ClipRRect(
  //             borderRadius: BorderRadius.circular(8),
  //             child: Image.network(
  //               restaurant.image,
  //               width: 50,
  //               height: 50,
  //               fit: BoxFit.cover,
  //             ),
  //           ),
  //           title: Text(
  //             restaurant.name,
  //             style: const TextStyle(
  //               fontWeight: FontWeight.bold,
  //               fontSize: 14,
  //               fontFamily: 'Montserrat',
  //             ),
  //             maxLines: 1,
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //           subtitle: Text(
  //             restaurant.location,
  //             style: const TextStyle(
  //               fontSize: 12,
  //               color: Colors.grey,
  //               fontFamily: 'Montserrat',
  //             ),
  //             maxLines: 1,
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //           onTap: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => RestaurantDetailPage(
  //                   restaurant: restaurant,
  //                 ),
  //               ),
  //             );
  //           },
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _buildSearchResultsOverlay() {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final restaurant = _searchResults[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                restaurant.image,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              restaurant.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              restaurant.location,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontFamily: 'Montserrat',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantDetailPage(
                    restaurant: restaurant,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
