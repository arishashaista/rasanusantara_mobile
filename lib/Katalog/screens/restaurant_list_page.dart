import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:rasanusantara_mobile/restaurant.dart';
import '../screens/restaurant_card.dart';
import '../screens/restaurant_detail_page.dart';

class RestaurantListPage extends StatefulWidget {
  const RestaurantListPage({super.key});

  @override
  State<RestaurantListPage> createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> _allRestaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  bool _isLoading = true;

  final List<String> _categories = [
    "Semua Kategori",
    "Gudeg",
    "Oseng",
    "Bakpia",
    "Sate",
    "Sego Gurih",
    "Wedang",
    "Lontong",
    "Rujak Cingur",
    "Mangut Lele",
    "Ayam",
    "Lainnya"
  ];

  final List<String> _sortOptions = [
    "Harga Tertinggi",
    "Harga Terendah",
    "Rating Tertinggi",
    "Rating Terendah",
  ];

  String _selectedCategory = "Semua Kategori";
  String _selectedSortOption = "Rating Tertinggi";

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

  void _applyFilters() {
    setState(() {
      final query = _searchController.text.toLowerCase();

      // Filter berdasarkan pencarian dan kategori
      _filteredRestaurants = _allRestaurants.where((restaurant) {
        final matchesSearch = restaurant.name.toLowerCase().contains(query);
        final matchesCategory = _selectedCategory == "Semua Kategori" ||
            restaurant.menuItems.any(
                (menuItem) => menuItem.categories.contains(_selectedCategory));

        return matchesSearch && matchesCategory;
      }).toList();

      // Urutkan berdasarkan opsi yang dipilih
      if (_selectedSortOption == "Harga Tertinggi") {
        _filteredRestaurants
            .sort((a, b) => b.averagePrice.compareTo(a.averagePrice));
      } else if (_selectedSortOption == "Harga Terendah") {
        _filteredRestaurants
            .sort((a, b) => a.averagePrice.compareTo(b.averagePrice));
      } else if (_selectedSortOption == "Rating Tertinggi") {
        _filteredRestaurants.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (_selectedSortOption == "Rating Terendah") {
        _filteredRestaurants.sort((a, b) => a.rating.compareTo(b.rating));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Container(
                  margin: const EdgeInsets.only(
                      top: 20, left: 16, right: 16, bottom: 8),
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
                    onChanged: (value) => _applyFilters(),
                    decoration: const InputDecoration(
                      hintText: 'Ingin makan apa hari ini?',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.orange),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),

                // Dropdown Kategori dan Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // Dropdown Kategori dengan Tampilan Oranye dan Scroll
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orange, // Warna oranye
                            borderRadius:
                                BorderRadius.circular(24), // Rounded corners
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.white),
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Colors.white, // Teks putih
                              ),
                              dropdownColor: Colors.orange.shade100,
                              items: _categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedCategory = value;
                                    _applyFilters();
                                  });
                                }
                              },
                              menuMaxHeight:
                                  200, // Maksimum 4 item dengan scroll
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Dropdown Filter dengan Tampilan Oranye
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orange, // Warna oranye
                            borderRadius:
                                BorderRadius.circular(24), // Rounded corners
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSortOption,
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.white),
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Colors.white, // Teks putih
                              ),
                              dropdownColor: Colors.orange.shade100,
                              items: _sortOptions.map((option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedSortOption = value;
                                    _applyFilters();
                                  });
                                }
                              },
                            ),
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
