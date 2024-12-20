import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rasanusantara_mobile/restaurant.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AdminRestaurantScreen extends StatefulWidget {
  const AdminRestaurantScreen({super.key});

  @override
  State<AdminRestaurantScreen> createState() => _AdminRestaurantScreenState();
}

class _AdminRestaurantScreenState extends State<AdminRestaurantScreen> {
  List<Restaurant> restaurants = [];
  List<String> categories = [];
  String? selectedCategory;
  String? selectedSort;
  bool isLoading = false;
  final _baseUrl = 'http://127.0.0.1:8000';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      await Future.wait([
        _loadRestaurants(),
        _loadCategories(),
      ]);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadRestaurants() async {
    final request = context.read<CookieRequest>();
    var queryParameters = <String, String>{};
    if (selectedCategory != null) queryParameters['category'] = selectedCategory!;
    if (selectedSort != null) queryParameters['sorting'] = selectedSort!;

    final response = await request.get(
      '$_baseUrl/adminview/admin_restaurant/',
    );

    if (response != null) {
      setState(() {
        restaurants = (response as List).map((json) => Restaurant.fromJson(json)).toList();
      });
    }
  }

  Future<void> _loadCategories() async {
    final request = context.read<CookieRequest>();
    final response = await request.get('$_baseUrl/adminview/categories/');
    
    if (response != null) {
      setState(() {
        categories = (response as List).map((json) => json['name'] as String).toList();
      });
    }
  }

  Future<void> _showAddEditDialog([Restaurant? restaurant]) async {
    final nameController = TextEditingController(text: restaurant?.name);
    final locationController = TextEditingController(text: restaurant?.location);
    final priceController = TextEditingController(
      text: restaurant?.averagePrice.toString(),
    );
    final ratingController = TextEditingController(
      text: restaurant?.rating.toString(),
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(restaurant == null ? 'Add Restaurant' : 'Edit Restaurant'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Average Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ratingController,
                decoration: const InputDecoration(
                  labelText: 'Rating (0-5)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final request = context.read<CookieRequest>();
              final data = {
                'name': nameController.text,
                'location': locationController.text,
                'average_price': priceController.text,
                'rating': ratingController.text,
              };

              try {
                if (restaurant == null) {
                  final response = await request.post(
                    '$_baseUrl/adminview/add_restaurant/',
                    data,
                  );
                  if (response['success'] == true) {
                    _showSnackBar('Restaurant added successfully');
                  }
                } else {
                  final response = await request.post(
                    '$_baseUrl/adminview/edit_restaurant/${restaurant.id}/',
                    data,
                  );
                  if (response['success'] == true) {
                    _showSnackBar('Restaurant updated successfully');
                  }
                }
                Navigator.pop(context, true);
              } catch (e) {
                _showSnackBar('Error: $e');
              }
            },
            child: Text(restaurant == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      _loadRestaurants();
    }
  }

  Future<void> _deleteRestaurant(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Restaurant'),
        content: const Text('Are you sure you want to delete this restaurant?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final request = context.read<CookieRequest>();
      try {
        await request.post(
          '$_baseUrl/adminview/delete_restaurant/$id/',
          {},
        );
        _showSnackBar('Restaurant deleted successfully');
        _loadRestaurants();
      } catch (e) {
        _showSnackBar('Error deleting restaurant: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF453229),
      appBar: AppBar(
        title: const Text('Restaurant Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...categories.map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                        _loadRestaurants();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedSort,
                    decoration: const InputDecoration(
                      labelText: 'Sort by Price',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: null,
                        child: Text('Default'),
                      ),
                      DropdownMenuItem(
                        value: 'low_to_high',
                        child: Text('Lowest Price'),
                      ),
                      DropdownMenuItem(
                        value: 'high_to_low',
                        child: Text('Highest Price'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedSort = value;
                        _loadRestaurants();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Restaurant Grid
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];
                      return Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                restaurant.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.network(
                                    'https://www.creativefabrica.com/wp-content/uploads/2020/03/09/Simple-Fork-Plate-Icon-Restaurant-Logo-Graphics-3446203-1-1-580x348.jpg',
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    restaurant.name,
                                    style: Theme.of(context).textTheme.titleMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    restaurant.location,
                                    style: Theme.of(context).textTheme.bodySmall,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    'Rp${restaurant.averagePrice.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          size: 16, color: Colors.amber),
                                      Text('${restaurant.rating}/5'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () =>
                                            _showAddEditDialog(restaurant),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () =>
                                            _deleteRestaurant(restaurant.id),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.menu_book),
                                        onPressed: () {
                                          // Navigate to menu management
                                          // Implement menu navigation here
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}