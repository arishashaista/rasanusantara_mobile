import 'package:flutter/material.dart';
import 'package:rasanusantara_mobile/home.dart';
import 'package:rasanusantara_mobile/navbar.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:rasanusantara_mobile/authentication/screens/login.dart';

void main() {
  runApp(
    Provider(
      create: (context) => CookieRequest(),
      child: const MyApp(),
    ),
  );
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
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Rute awal
      routes: {
        '/': (context) => const Navbar(), // Rute homepage utama
        '/login': (context) => const LoginPage(), // Rute ke halaman login
      },
    );
  }
}
