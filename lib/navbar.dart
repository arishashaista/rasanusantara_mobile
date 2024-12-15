import 'package:flutter/material.dart';
import 'package:rasanusantara_mobile/menu.dart';
import 'package:rasanusantara_mobile/profileandfavorite.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan pada body tergantung selectedIndex
  final pages = [
    const MenuPage(), // index 0: Home (MenuPage)
    Container(), // index 1: Restaurant (placeholder)
    Container(), // index 2: Calendar (placeholder)
    const ProfileFavorite(), // index 3: Profile Page
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.brown[900],
        ),
        child: SafeArea(
          child: Row(
            // Coba spaceAround atau spaceBetween untuk jarak yang lebih lebar
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                iconSize: 30, // atur ukuran icon, misal 30
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
