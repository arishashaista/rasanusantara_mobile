import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:rasanusantara_mobile/admin/delete_restaurant.dart';
import 'package:rasanusantara_mobile/admin/edit_restaurant.dart';
import 'package:rasanusantara_mobile/image.dart';
import 'package:rasanusantara_mobile/restaurant.dart';
import 'package:rasanusantara_mobile/review/screens/review_page.dart';
import 'package:rasanusantara_mobile/menu_management/menu_management_screen.dart';

class AdminDetail extends StatefulWidget {
  final Restaurant restaurant;
  final Function() onMenuUpdated; // Add callback function

  const AdminDetail({
    Key? key,
    required this.restaurant,
    required this.onMenuUpdated, // Add this parameter
  }) : super(key: key);

  @override
  State<AdminDetail> createState() => _AdminDetailState();
}

class _AdminDetailState extends State<AdminDetail> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final request = Provider.of<CookieRequest>(context, listen: false);
      final response = await request.get(
        'https://arisha-shaista-rasanusantara.pbp.cs.ui.ac.id/ubahmenu/api/menu_items/${widget.restaurant.id}/',
      );

      if (!mounted) return;

      final updatedMenuItems = (response as List)
          .map((menuItem) => MenuItem.fromJson(menuItem))
          .toList();

      setState(() {
        widget.restaurant.menuItems = updatedMenuItems;
        _isLoading = false;
      });

      // Call the callback to update the parent
      widget.onMenuUpdated();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui data restaurant.'),
        ),
      );
    }
  }

  // In the build method, update the MenuManagementScreen navigation:
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                                onPressed: () async {
                                  final shouldRefresh = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditRestaurantPage(
                                        restaurantId: widget.restaurant.id,
                                        name: widget.restaurant.name,
                                        location: widget.restaurant.location,
                                        averagePrice:
                                            widget.restaurant.averagePrice,
                                        rating: widget.restaurant.rating,
                                      ),
                                    ),
                                  );

                                  if (shouldRefresh == true) {
                                    await _loadData();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text(
                                  'Edit Restoran',
                                  style: TextStyle(fontFamily: 'Montserrat'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final shouldRefresh = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MenuManagementScreen(
                                        restaurantId: widget.restaurant.id,
                                      ),
                                    ),
                                  );

                                  if (shouldRefresh == true) {
                                    await _loadData();
                                  }
                                },
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
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Tambahkan agar tombol terpusat
                          children: [
                            SizedBox(
                              width: 200, // Tentukan panjang tombol
                              child: ElevatedButton(
                                onPressed: () async {
                                  final shouldRefresh = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DeleteRestaurantPage(
                                        restaurantId: widget.restaurant.id,
                                      ),
                                    ),
                                  );

                                  if (shouldRefresh == true) {
                                    await _loadData();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text(
                                  'Hapus Restoran',
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
  }
}
