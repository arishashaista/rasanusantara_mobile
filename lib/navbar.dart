import 'package:flutter/material.dart';
import 'package:rasanusantara_mobile/menu.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.brown[900], // Pastikan ini tidak menggunakan `const`
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home_rounded, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        MenuPage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                  (route) => false,
                );
              },
            ),
            const Icon(Icons.restaurant_menu_rounded, color: Colors.white),
            const Icon(Icons.calendar_month_rounded, color: Colors.white),
            const Icon(Icons.person_2_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
