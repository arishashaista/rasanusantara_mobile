import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:rasanusantara_mobile/admin/admin_detail.dart';
import 'package:rasanusantara_mobile/restaurant.dart';
import 'package:rasanusantara_mobile/admin/admin_card.dart';

class AdminListPage extends StatefulWidget {
  const AdminListPage({super.key});

  @override
  State<AdminListPage> createState() => _AdminListPageState();
}

class _AdminListPageState extends State<AdminListPage> {
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
    "Filter",
    "Harga Tertinggi",
    "Harga Terendah",
    "Rating Tertinggi",
    "Rating Terendah",
  ];

  String _selectedCategory = "Semua Kategori";
  String _selectedSortOption = "Filter";

  Future<void> _refreshRestaurants() async {
    setState(() {
      _isLoading = true;
    });
    final request = Provider.of<CookieRequest>(context, listen: false);
    await fetchRestaurants(request);
  }

  Future<void> fetchRestaurants(CookieRequest request) async {
    try {
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
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Gagal memuat restoran. Periksa koneksi Anda.');
    }
  }

  void _applyFilters() {
    setState(() {
      final query = _searchController.text.toLowerCase();

      _filteredRestaurants = _allRestaurants.where((restaurant) {
        final matchesSearch = restaurant.name.toLowerCase().contains(query);
        final matchesCategory = _selectedCategory == "Semua Kategori" ||
            restaurant.menuItems.any(
                (menuItem) => menuItem.categories.contains(_selectedCategory));

        return matchesSearch && matchesCategory;
      }).toList();

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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final request = Provider.of<CookieRequest>(context, listen: false);
      await fetchRestaurants(request);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
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
                      hintStyle: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.orange),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            isDense:
                                true, // Menggunakan layout yang lebih compact
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            filled: true,
                            fillColor: Colors.orange,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          dropdownColor: Colors.orange[100],
                          items: _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Container(
                                constraints: const BoxConstraints(
                                    maxWidth: 120), // Batasi lebar item
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'Montserrat',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
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
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.white, size: 20),
                          menuMaxHeight: 200,
                          isExpanded:
                              true, // Memastikan dropdown mengisi ruang yang tersedia
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedSortOption,
                          decoration: InputDecoration(
                            isDense:
                                true, // Menggunakan layout yang lebih compact
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            filled: true,
                            fillColor: Colors.orange,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          dropdownColor: Colors.orange.shade100,
                          items: _sortOptions.map((option) {
                            return DropdownMenuItem(
                              value: option,
                              child: Container(
                                constraints: const BoxConstraints(
                                    maxWidth: 120), // Batasi lebar item
                                child: Text(
                                  option,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'Montserrat',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
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
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.white, size: 20),
                          menuMaxHeight: 200,
                          isExpanded:
                              true, // Memastikan dropdown mengisi ruang yang tersedia
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filteredRestaurants.isEmpty
                      ? const Center(
                          child: Text(
                            "Tidak ada restoran yang dicari.",
                            style: TextStyle(
                              color: Color(0xff59A5D8),
                              fontSize: 20,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredRestaurants.length,
                          itemBuilder: (_, index) => AdminCard(
                            restaurant: _filteredRestaurants[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminDetail(
                                    restaurant: _filteredRestaurants[index],
                                    onMenuUpdated: () async {
                                      // Refresh the entire restaurant list when menu is updated
                                      await _refreshRestaurants();
                                      // Reapply filters to update the filtered list
                                      _applyFilters();
                                    },
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
}
