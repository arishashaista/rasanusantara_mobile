import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:rasanusantara_mobile/navbar.dart';
import 'package:rasanusantara_mobile/reservasi/screens/reservation_user.dart';

class ReservationDeletePage extends StatelessWidget {
  final int reservationId;
  final String restaurantName;

  const ReservationDeletePage({
    Key? key,
    required this.reservationId,
    required this.restaurantName,
  }) : super(key: key);

  Future<void> deleteReservation(BuildContext context) async {
    final request = context.read<CookieRequest>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await request.post(
        'http://127.0.0.1:8000/reservasi/cancel/$reservationId/',
        {},
      );

      Navigator.pop(context); // Close the loading dialog

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reservasi berhasil dibatalkan!')),
        );
      }
    } finally {
      // Ensure redirection happens regardless of success or error
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const Navbar(
                  selectedIndex: 2,
                )),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Batalkan Reservasi'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Apakah Anda yakin ingin membatalkan reservasi di $restaurantName?',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => deleteReservation(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Batalkan Reservasi',
                  style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
          ],
        ),
      ),
    );
  }
}
