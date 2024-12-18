import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:rasanusantara_mobile/home.dart';
import 'package:rasanusantara_mobile/favorite/profileandfavorite.dart';
import 'package:rasanusantara_mobile/authentication/screens/login.dart';
import 'package:rasanusantara_mobile/Katalog/screens/restaurant_list_page.dart'; // Import halaman Menu

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    final List<Widget> pages = [
      const MenuPage(), // Home Page
      const RestaurantListPage(), // Menu Page
      Container(), // Placeholder untuk Kalender
      request.loggedIn ? const ProfileFavorite() : const LoginPage(), // Profile
    ];

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.brown[900], // Warna background navbar coklat
        type: BottomNavigationBarType.fixed, // Hindari efek shifting
        showSelectedLabels: false, // Hilangkan label saat item dipilih
        showUnselectedLabels: false, // Hilangkan label saat item tidak dipilih
        iconSize: 30, // Ukuran ikon diperbesar, sesuaikan dengan kebutuhan
        items: const [
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
