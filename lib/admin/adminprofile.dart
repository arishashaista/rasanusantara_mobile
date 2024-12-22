import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({Key? key}) : super(key: key);

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  String username = 'Admin';
  int restaurantCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = Provider.of<CookieRequest>(context, listen: false);
      fetchUserData(request);
      fetchRestaurantCount(request);
    });
  }

  Future<void> fetchUserData(CookieRequest request) async {
    try {
      final response = await request.get(
          'https://arisha-shaista-rasanusantara.pbp.cs.ui.ac.id/auth/user/');
      if (mounted) {
        setState(() {
          username = response['username'] ?? 'Admin';
        });
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      if (mounted) {
        setState(() {
          username = 'Admin';
        });
      }
    }
  }

  Future<void> fetchRestaurantCount(CookieRequest request) async {
    try {
      final response = await request.get(
          'https://arisha-shaista-rasanusantara.pbp.cs.ui.ac.id/adminview/restaurant-count/');
      if (mounted) {
        setState(() {
          restaurantCount = response['count'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error fetching restaurant count: $e');
      if (mounted) {
        setState(() {
          restaurantCount = 0;
        });
      }
    }
  }

  void logout() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    try {
      final response = await request.get(
          'https://arisha-shaista-rasanusantara.pbp.cs.ui.ac.id/auth/logout/');

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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Logout gagal.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Halo, $username!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rekomendasi Restoranmu ada $restaurantCount',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Keluar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
