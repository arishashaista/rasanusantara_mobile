import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Model Restaurant
import 'package:rasanusantara_mobile/restaurant.dart';
// Halaman Review (jika dibutuhkan)
import 'package:rasanusantara_mobile/review/screens/review_page.dart';
// Halaman Menu Management
import 'package:rasanusantara_mobile/menu_management/menu_management_screen.dart';

class AdminDetail extends StatefulWidget {
  final Restaurant restaurant;

  const AdminDetail({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  State<AdminDetail> createState() => _AdminDetailState();
}

class _AdminDetailState extends State<AdminDetail> {
  /// Kita simpan data restoran terkini di _currentRestaurant
  late Restaurant _currentRestaurant;

  /// Untuk menandai proses loading
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Copy data awal
    _currentRestaurant = widget.restaurant;

    // Contoh jika Anda ingin mengambil data login dsb
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = Provider.of<CookieRequest>(context, listen: false);
      // misalnya: request.loggedIn => dsb
    });

    // Panggil jika Anda punya endpoint detail untuk memuat data yang paling update
    _fetchRestaurantDetail();
  }

  /// Method untuk GET detail restoran dari server
  /// Pastikan Anda punya endpoint (misalnya):
  /// GET http://127.0.0.1:8000/adminview/api/restaurant/detail/<restaurantId>/
  /// yang mengembalikan JSON detail berikut daftar menu ter-update
  Future<void> _fetchRestaurantDetail() async {
    setState(() => _isLoading = true);

    try {
      // Contoh URL detail - ganti sesuai route di Django Anda
      final detailUrl = Uri.parse(
        'http://127.0.0.1:8000/adminview/api/restaurant/detail/${_currentRestaurant.id}/',
      );
      final response = await http.get(detailUrl);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Asumsikan Restaurant.fromJson sudah bisa parse data detail
        setState(() {
          _currentRestaurant = Restaurant.fromJson(data);
        });
      } else {
        debugPrint('Gagal fetch detail: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception fetch detail: $e');
    }

    setState(() => _isLoading = false);
  }

  /// Navigasi ke MenuManagementScreen
  /// Setelah user menutup (pop) halaman menu, panggil _fetchRestaurantDetail()
  /// agar data di AdminDetail langsung diperbarui (misal setelah delete).
  Future<void> _goToMenuManagement() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuManagementScreen(
          restaurantId: _currentRestaurant.id,
        ),
      ),
    );
    // Begitu user kembali (pop) dari MenuManagementScreen:
    _fetchRestaurantDetail();
  }

  @override
  Widget build(BuildContext context) {
    // Jika sedang memuat data, tampilkan spinner
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Restoran'),
          backgroundColor: Colors.orange,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Jika data sudah ada, tampilkan seperti biasa:
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Gambar Header
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    _currentRestaurant.image.isNotEmpty
                        ? _currentRestaurant.image
                        : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRhdkA-pOR1l5lRdCAtAAA2XSt2qg-WxQcg5A&s',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.restaurant,
                            color: Colors.grey,
                            size: 50,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Tombol Back
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
              ],
            ),

            // Isi Detail
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama
                  Text(
                    _currentRestaurant.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Lokasi
                  Text(
                    _currentRestaurant.location.isNotEmpty
                        ? _currentRestaurant.location
                        : "Lokasi tidak tersedia",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  // Rating & Harga
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 20),
                      Text(
                        ' ${_currentRestaurant.rating}',
                        style: const TextStyle(fontFamily: 'Montserrat'),
                      ),
                      Text(
                        ' • Rp${_currentRestaurant.averagePrice}',
                        style: const TextStyle(fontFamily: 'Montserrat'),
                      ),
                    ],
                  ),
                  // Jika ada kategori di item pertama (opsional)
                  if (_currentRestaurant.menuItems.isNotEmpty &&
                      _currentRestaurant.menuItems.first.categories.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: _currentRestaurant
                          .menuItems.first.categories
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
                  // Tampilkan menu
                  ..._currentRestaurant.menuItems.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '• ${item.name}',
                          style: const TextStyle(fontFamily: 'Montserrat'),
                        ),
                      )),
                  const SizedBox(height: 20),

                  // Tombol2
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Aksi reservasi (jika ada)
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
                          onPressed: _goToMenuManagement,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade900,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Edit Menu',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                            ),
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
  }
}
