import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:rasanusantara_mobile/reservasi/screens/reservation_user.dart';
import 'dart:convert';

class ReservationForm extends StatefulWidget {
  final String restaurantid;
  final String restaurantName;
  final String restaurantImage;

  const ReservationForm({
    Key? key,
    required this.restaurantid,
    required this.restaurantName,
    required this.restaurantImage,
  }) : super(key: key);

  @override
  _ReservationFormState createState() => _ReservationFormState();
}

class _ReservationFormState extends State<ReservationForm> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  int numberOfPeople = 2;
  String specialRequest = '';

  Future<void> createReservation() async {
    final request = context.read<CookieRequest>();
    final String url =
        'http://127.0.0.1:8000/reservasi/create_reservation_flutter/${widget.restaurantid}/';

    try {
      final response = await request.postJson(
        url,
        jsonEncode({
          'reservation_date': '${selectedDate.toLocal()}'.split(' ')[0],
          'reservation_time': '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
          'number_of_people': numberOfPeople.toString(),
          'special_request': specialRequest,
        }),
      );

      if (response['status'] == 'success') {
        if (!context.mounted) return;
        // Redirect ke ReservationUserPage setelah reservasi berhasil
      }
    } catch (e) {
      // Tidak melakukan apa-apa jika terjadi error
    }
    Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const ReservationUserPage()),
    (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Image
            Container(
              height: 200,
              width: double.infinity,
              child: Image.network(
                widget.restaurantImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        Icons.restaurant,
                        color: Colors.grey[400],
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

            // Restaurant Details
            Center(
              child: Column(
                children: [
                  Text(
                    'Reservasi',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.restaurantName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),

            // Date Picker
            _buildInputField(
              label: 'Tanggal Reservasi',
              value: "${selectedDate.toLocal()}".split(' ')[0],
              icon: Icons.calendar_today,
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null && picked != selectedDate) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
            ),
            SizedBox(height: 16),

            // Time Picker
            _buildInputField(
              label: 'Waktu Reservasi',
              value: selectedTime.format(context),
              icon: Icons.access_time,
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (picked != null && picked != selectedTime) {
                  setState(() {
                    selectedTime = picked;
                  });
                }
              },
            ),
            SizedBox(height: 16),

            // Number of People
            TextField(
              decoration: InputDecoration(
                labelText: 'Jumlah Orang',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.person, color: Colors.orange),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  numberOfPeople = int.tryParse(value) ?? 2;
                });
              },
            ),
            SizedBox(height: 16),

            // Special Request
            TextField(
              decoration: InputDecoration(
                labelText: 'Special Request',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              onChanged: (value) {
                setState(() {
                  specialRequest = value;
                });
              },
            ),
            SizedBox(height: 20),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: createReservation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Reservasi',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon: Icon(icon, color: Colors.orange),
        ),
        child: Text(value),
      ),
    );
  }
}
