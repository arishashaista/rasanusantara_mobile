import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:rasanusantara_mobile/favorite/favorite_provider.dart';
import 'package:rasanusantara_mobile/restaurant.dart';
import 'package:rasanusantara_mobile/favorite/favoritecard.dart';

class ProfileFavorite extends StatefulWidget {
  const ProfileFavorite({Key? key}) : super(key: key);

  @override
  State<ProfileFavorite> createState() => _ProfileFavoriteState();
}

class _ProfileFavoriteState extends State<ProfileFavorite> {
  bool isLoading = true;
  String username = 'Pengguna';
  String searchQuery = '';
  List<Restaurant> filteredRestaurants = [];

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: false);

    setState(() {
      isLoading = true;
    });

    try {
      // Load user data and favorites simultaneously
      await Future.wait([
        fetchUserData(request),
        favoriteProvider.initializeFavorites(request),
      ]);

      // Initialize filtered restaurants
      final favorites = favoriteProvider.favoriteRestaurants;
      filteredRestaurants =
          favorites.map((data) => Restaurant.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error initializing data: $e');
      if (mounted) {
        _showErrorDialog('Gagal memuat data. Periksa koneksi Anda.');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchUserData(CookieRequest request) async {
    try {
      final response = await request.get('http://127.0.0.1:8000/auth/user/');
      if (mounted) {
        setState(() {
          username = response['username'] ?? 'Pengguna';
        });
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      if (mounted) {
        setState(() {
          username = 'Pengguna';
        });
      }
    }
  }

  void searchFavorites(String query) {
    final favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: false);
    final allFavorites = favoriteProvider.favoriteRestaurants
        .map((data) => Restaurant.fromJson(data))
        .toList();

    setState(() {
      searchQuery = query;
      filteredRestaurants = allFavorites
          .where((restaurant) =>
              restaurant.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void logout() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: false);

    try {
      final response = await request.get('http://127.0.0.1:8000/auth/logout/');

      if (response['status'] == true) {
        request.loggedIn = false;
        favoriteProvider.resetFavorites();

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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Logout gagal.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kesalahan'),
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
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        final favorites = favoriteProvider.favoriteRestaurants;
        final displayRestaurants = searchQuery.isEmpty
            ? favorites.map((data) => Restaurant.fromJson(data)).toList()
            : filteredRestaurants;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.deepOrange,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
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
                              child: Icon(Icons.person,
                                  size: 60, color: Colors.grey),
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
                              'Restoran favoritmu ada ${favorites.length}',
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
                                hintText: 'Cari restoran favoritmu',
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'Montserrat',
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Colors.orange,
                                ),
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
                        ],
                      ),
                    ),
                    Expanded(
                      child: favorites.isEmpty
                          ? const Center(
                              child: Text(
                                'Kamu belum memiliki restoran favorit.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : displayRestaurants.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Tidak ada restoran yang dicari.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: displayRestaurants.length,
                                  itemBuilder: (context, index) {
                                    return FavoriteProductCard(
                                      restaurant: displayRestaurants[index],
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
