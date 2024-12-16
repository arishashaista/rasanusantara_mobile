import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import '../screens/restaurant_card.dart';
import '../screens/restaurant_detail_page.dart';

class RestaurantListPage extends StatefulWidget {
  const RestaurantListPage({super.key});

  @override
  State<RestaurantListPage> createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> _allRestaurants = []; // Semua restoran
  List<Restaurant> _filteredRestaurants = []; // Hasil pencarian
  bool _isLoading = true;

  String _selectedFilter = "Semua Restoran"; // Filter aktif

  // Fetch data restoran
  Future<void> fetchRestaurants(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/json/');
    List<Restaurant> listRestaurant = [];
    for (var d in response) {
      if (d != null) {
        listRestaurant.add(Restaurant.fromJson(d));
      }
    }
    setState(() {
      _allRestaurants = listRestaurant;
      _filteredRestaurants = listRestaurant;
      _isLoading = false;
    });
  }

  // Fungsi untuk filter hasil pencarian
  void _searchRestaurants(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRestaurants = _allRestaurants; // Tampilkan semua jika kosong
      } else {
        _filteredRestaurants = _allRestaurants.where((restaurant) {
          final name = restaurant.name.toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  // Fungsi untuk mengurutkan data
  void _sortRestaurants(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == "Rating Tertinggi") {
        _filteredRestaurants.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (filter == "Rating Terendah") {
        _filteredRestaurants.sort((a, b) => a.rating.compareTo(b.rating));
      } else if (filter == "Harga Tertinggi") {
        _filteredRestaurants
            .sort((a, b) => b.averagePrice.compareTo(a.averagePrice));
      } else if (filter == "Harga Terendah") {
        _filteredRestaurants
            .sort((a, b) => a.averagePrice.compareTo(b.averagePrice));
      } else {
        _filteredRestaurants = _allRestaurants;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          "Daftar Restoran",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Container(
                  margin: const EdgeInsets.only(
                      top: 16, left: 16, right: 16, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchRestaurants, // Fungsi filter
                    decoration: const InputDecoration(
                      hintText: 'Ingin makan apa hari ini?',
                      hintStyle:
                          TextStyle(fontSize: 14, fontFamily: 'Montserrat'),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.orange),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),

                // Dropdown Filter dan Tombol Semua Restoran
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedFilter,
                          items: const [
                            DropdownMenuItem(
                              value: "Semua Restoran",
                              child: Text("Semua Restoran"),
                            ),
                            DropdownMenuItem(
                              value: "Rating Tertinggi",
                              child: Text("Rating Tertinggi"),
                            ),
                            DropdownMenuItem(
                              value: "Rating Terendah",
                              child: Text("Rating Terendah"),
                            ),
                            DropdownMenuItem(
                              value: "Harga Tertinggi",
                              child: Text("Harga Tertinggi"),
                            ),
                            DropdownMenuItem(
                              value: "Harga Terendah",
                              child: Text("Harga Terendah"),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              _sortRestaurants(value);
                            }
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:
                                Colors.orange.shade100, // Warna background
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          dropdownColor:
                              Colors.orange.shade100, // Dropdown menu
                          style: const TextStyle(
                            color: Colors.black87,
                            fontFamily: 'Montserrat',
                          ),
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.orange),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Tampilkan semua restoran
                            setState(() {
                              _filteredRestaurants = _allRestaurants;
                              _searchController.clear();
                              _selectedFilter = "Semua Restoran";
                            });
                          },
                          icon: const Icon(Icons.restaurant),
                          label: const Text('Semua Restoran'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // List Hasil Pencarian
                Expanded(
                  child: _filteredRestaurants.isEmpty
                      ? const Center(
                          child: Text(
                            "Belum ada restoran yang tersedia.",
                            style: TextStyle(
                              color: Color(0xff59A5D8),
                              fontSize: 20,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredRestaurants.length,
                          itemBuilder: (_, index) => RestaurantCard(
                            restaurant: _filteredRestaurants[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RestaurantDetailPage(
                                    restaurant: _filteredRestaurants[index],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    fetchRestaurants(request);
  }
}
