import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rasanusantara_mobile/card.dart';
import 'package:rasanusantara_mobile/model.dart';
import 'package:rasanusantara_mobile/Katalog/models/restaurant.dart';
import 'package:rasanusantara_mobile/Katalog/screens/restaurant_detail_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<ProductEntry> _allProducts = []; // Semua data restoran
  List<ProductEntry> _searchResults = []; // Hasil pencarian
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  // Fetch data dari backend
  Future<void> fetchProducts() async {
    final url = Uri.parse('http://127.0.0.1:8000/json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      setState(() {
        _allProducts = data.map((e) => ProductEntry.fromJson(e)).toList();
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Fungsi untuk filter hasil pencarian
  void _searchProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
    } else {
      final results = _allProducts.where((product) {
        final name = product.fields.name.toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
      setState(() {
        _searchResults = results.take(2).toList(); // Batasi ke 5 hasil
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 250,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('lib/assets/Homepage.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Search Bar dan Hasil Pencarian
                Positioned(
                  top: MediaQuery.of(context).padding.top + 22,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            const BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          onChanged: _searchProducts,
                          decoration: const InputDecoration(
                            hintText: 'Ingin makan apa hari ini?',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                            ),
                            border: InputBorder.none,
                            prefixIcon:
                                Icon(Icons.search, color: Colors.orange),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Hasil Pencarian
                      if (_searchResults.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              const BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final product = _searchResults[index];

                              // Navigasi ke halaman detail saat diklik
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.fields.image,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  product.fields.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                  ),
                                  maxLines:
                                      1, // Batasi nama restoran menjadi 1 baris
                                  overflow: TextOverflow
                                      .ellipsis, // Tambahkan "..." jika teks melebihi 1 baris
                                ),
                                subtitle: Text(
                                  product.fields.location,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontFamily: 'Montserrat',
                                  ),
                                  maxLines:
                                      1, // Batasi alamat restoran menjadi 1 baris
                                  overflow: TextOverflow
                                      .ellipsis, // Tambahkan "..." jika teks melebihi 1 baris
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RestaurantDetailPage(
                                        restaurant: Restaurant(
                                          id: product.pk,
                                          name: product.fields.name,
                                          location: product.fields.location,
                                          averagePrice:
                                              product.fields.averagePrice,
                                          rating: product.fields.rating,
                                          image: product.fields.image,
                                          menuItems: [],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                // Restoran Populer
                Positioned(
                  top: MediaQuery.of(context).padding.top + 260,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Restoran Populer',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
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
                      ),
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _allProducts.take(8).length,
                          itemBuilder: (context, index) {
                            final product = _allProducts[index];
                            return Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 16),
                              child: FavoriteProductCard(
                                fields: product.fields,
                                id: product.pk,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
