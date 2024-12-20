import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:rasanusantara_mobile/home.dart';
import 'package:rasanusantara_mobile/favorite/profileandfavorite.dart';
import 'package:rasanusantara_mobile/authentication/screens/login.dart';
import 'package:rasanusantara_mobile/Katalog/screens/restaurant_list_page.dart';

class Navbar extends StatefulWidget {
  final int selectedIndex;

  const Navbar({Key? key, this.selectedIndex = 0}) : super(key: key);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getPage(int index) {
    final request = context.watch<CookieRequest>();
    switch (index) {
      case 0:
        return const MenuPage(); // Home Page
      case 1:
        return const RestaurantListPage(); // Menu Page
      case 2:
        return Container(); // Placeholder Kalender
      case 3:
        return request.loggedIn
            ? const ProfileFavorite()
            : const LoginPage(); // Profile
      default:
        return const MenuPage(); // Default Page
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
