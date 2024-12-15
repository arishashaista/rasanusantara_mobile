import 'package:flutter/material.dart';
import 'package:rasanusantara_mobile/menu.dart';
import 'package:rasanusantara_mobile/navbar.dart';
import 'package:rasanusantara_mobile/profileandfavorite.dart'; // Import the main menu screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rasa Nusantara',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.brown,
        ).copyWith(secondary: Colors.brown[900]),
        useMaterial3: true,
      ),
      home: const Navbar(), // Homepage as the main screen
      debugShowCheckedModeBanner: false,
    );
  }
}
