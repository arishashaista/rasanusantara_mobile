import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:rasanusantara_mobile/restaurant.dart';
import 'package:rasanusantara_mobile/favorite/favoritecard.dart';

class ProfileFavorite extends StatefulWidget {
  const ProfileFavorite({Key? key}) : super(key: key);

  @override
  State<ProfileFavorite> createState() => _ProfileFavoriteState();
}

class _ProfileFavoriteState extends State<ProfileFavorite> {
  List<Restaurant> favoriteRestaurants = [];
  List<Restaurant> filteredRestaurants = [];
  bool isLoading = true;
  String username = 'Pengguna';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchFavorites();
  }

  Future<void> fetchUserData() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    const url = 'http://127.0.0.1:8000/auth/user/';

    try {
      final response = await request.get(url);
      setState(() {
        username = response['username'] ?? 'Pengguna';
      });
    } catch (e) {
      setState(() {
        username = 'Pengguna';
      });
    }
  }

  Future<void> fetchFavorites() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    const url = 'http://127.0.0.1:8000/favorite/json/';

    try {
      final response = await request.get(url);
      if (response != null) {
        final restaurants = (response as List)
            .map((data) => Restaurant.fromJson(data))
            .toList();
        setState(() {
          favoriteRestaurants = restaurants;
          filteredRestaurants = restaurants; // Awalnya semua data tampil
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        favoriteRestaurants = [];
        filteredRestaurants = [];
        isLoading = false;
      });
    }
  }

  void searchFavorites(String query) {
    setState(() {
      searchQuery = query;
      filteredRestaurants = favoriteRestaurants
          .where((restaurant) =>
              restaurant.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void logout() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    const url = 'http://127.0.0.1:8000/auth/logout/';

    try {
      final response = await request.get(url);

      if (response['status'] == true) {
        request.loggedIn = false;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['message'] ?? 'Logout berhasil!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.pushReplacementNamed(context, '/');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Logout gagal.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange, Colors.orange],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Halo, $username!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Makanan favoritmu ada ${filteredRestaurants.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Keluar',
                      style: TextStyle(fontFamily: 'Montserrat'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari makanan favoritmu',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Montserrat',
                      ),
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: searchFavorites,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Placeholder implementasi filter
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter'),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRestaurants.isEmpty
                    ? Center(
                        child: Text(
                          favoriteRestaurants.isEmpty
                              ? 'Kamu belum memiliki restoran favorit.'
                              : 'Tidak ada restoran yang dicari.',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredRestaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = filteredRestaurants[index];
                          return FavoriteProductCard(
                            restaurant: restaurant,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
