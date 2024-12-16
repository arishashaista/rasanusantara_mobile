import 'package:flutter/material.dart';
import 'package:rasanusantara_mobile/Katalog/screens/restaurant_list_page.dart';
import 'package:rasanusantara_mobile/home.dart';
import 'package:rasanusantara_mobile/profileandfavorite.dart';
import 'package:rasanusantara_mobile/authentication/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    // Tentukan halaman profile berdasarkan status login
    final profilePage = request.loggedIn
        ? const ProfileFavorite() // Sudah login
        : const LoginPage(); // Belum login, arahkan ke halaman login

    // Daftar halaman yang akan ditampilkan
    final pages = [
      const MenuPage(), // index 0: Home (MenuPage)
      const RestaurantListPage(), // index 1: Restaurant (placeholder)
      Container(), // index 2: Calendar (placeholder)
      profilePage, // index 3: Profile Page
    ];

    void _onItemTapped(int index) {
      setState(() {
        selectedIndex = index;
      });
    }

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.brown[900],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                iconSize: 30,
                icon: Icon(
                  Icons.home_rounded,
                  color: selectedIndex == 0 ? Colors.orange : Colors.white,
                ),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                iconSize: 30,
                icon: Icon(
                  Icons.restaurant_menu_rounded,
                  color: selectedIndex == 1 ? Colors.orange : Colors.white,
                ),
                onPressed: () => _onItemTapped(1),
              ),
              IconButton(
                iconSize: 30,
                icon: Icon(
                  Icons.calendar_month_rounded,
                  color: selectedIndex == 2 ? Colors.orange : Colors.white,
                ),
                onPressed: () => _onItemTapped(2),
              ),
              IconButton(
                iconSize: 30,
                icon: Icon(
                  Icons.person_2_rounded,
                  color: selectedIndex == 3 ? Colors.orange : Colors.white,
                ),
                onPressed: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
