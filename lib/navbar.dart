import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:rasanusantara_mobile/admin/add_restaurant.dart';
import 'package:rasanusantara_mobile/admin/admin_list.dart';
import 'package:rasanusantara_mobile/admin/adminprofile.dart';
import 'package:rasanusantara_mobile/home.dart';
import 'package:rasanusantara_mobile/favorite/profileandfavorite.dart';
import 'package:rasanusantara_mobile/authentication/screens/login.dart';
import 'package:rasanusantara_mobile/Katalog/screens/restaurant_list_page.dart';
import 'package:rasanusantara_mobile/reservasi/screens/reservation_user.dart';
import 'package:rasanusantara_mobile/image.dart';

class Navbar extends StatefulWidget {
  final int selectedIndex;

  const Navbar({Key? key, this.selectedIndex = 0}) : super(key: key);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  late int _selectedIndex;
  bool isSuperuser = false; // Inisialisasi default ke non-superuser

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    fetchUserInfo(); // Asynchronous operation untuk cek status superuser
  }

  Future<void> fetchUserInfo() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    try {
      final response = await request.get(
          'https://arisha-shaista-rasanusantara.pbp.cs.ui.ac.id/auth/is-superuser/');
      if (response != null) {
        // Perbarui hanya jika respons valid diterima
        setState(() {
          isSuperuser = response['is_superuser'] ?? false;
        });
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  void navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getPage(int index) {
    final request = context.watch<CookieRequest>();
    if (!isSuperuser) {
      // Tampilan default untuk non-superuser
      switch (index) {
        case 0:
          return const MenuPage(); // Home Page
        case 1:
          return const RestaurantListPage(); // Menu Page
        case 2:
          return request.loggedIn
              ? const ReservationUserPage()
              : const LoginPage(); //// Placeholder Kalender
        case 3:
          return request.loggedIn
              ? const ProfileFavorite()
              : const LoginPage(); // Profile
        default:
          return const MenuPage(); // Default Page
      }
    } else {
      switch (index) {
        case 0:
          return const AdminListPage(); // Halaman Dashboard Admin
        case 1:
          return const AddRestaurantPage(); // Halaman Manage Users
        case 2:
          return const AdminProfile(); // Halaman Dashboard Admin
        default:
          return const AdminListPage(); // Default Page untuk Admin
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: navigateToPage,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.brown[900],
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 30,
        items: isSuperuser
            ? const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_2_rounded),
                  label: '',
                ),
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_menu_rounded),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_rounded),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_2_rounded),
                  label: '',
                ),
              ],
      ),
    );
  }
}
