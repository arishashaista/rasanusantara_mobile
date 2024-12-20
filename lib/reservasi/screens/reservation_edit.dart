import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:rasanusantara_mobile/navbar.dart';
import 'package:rasanusantara_mobile/reservasi/screens/reservation_user.dart';
import 'dart:convert';

class ReservationEditPage extends StatefulWidget {
  final int reservationId;
  final String restaurantName;
  final String reservationDate;
  final String reservationTime;
  final int numberOfPeople;
  final String specialRequest;
  final String restaurantImage; // Added for restaurant image

  const ReservationEditPage({
    Key? key,
    required this.reservationId,
    required this.restaurantName,
    required this.reservationDate,
    required this.reservationTime,
    required this.numberOfPeople,
    required this.specialRequest,
    required this.restaurantImage, // Added for restaurant image
  }) : super(key: key);

  @override
  _ReservationEditPageState createState() => _ReservationEditPageState();
}

class _ReservationEditPageState extends State<ReservationEditPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _numberOfPeople;
  late String _specialRequest;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.reservationDate);
    final timeParts = widget.reservationTime.split(':');
    _selectedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1].substring(0, 2)),
    );
    _numberOfPeople = widget.numberOfPeople;
    _specialRequest = widget.specialRequest;
  }

  Future<void> updateReservation() async {
    final request = context.read<CookieRequest>();
    final String url =
        'http://127.0.0.1:8000/reservasi/edit_flutter/${widget.reservationId}/';

    try {
      final response = await request.postJson(
        url,
        jsonEncode({
          'reservation_date': '${_selectedDate.toLocal()}'.split(' ')[0],
          'reservation_time': '${_selectedTime.hour}:${_selectedTime.minute}',
          'number_of_people': _numberOfPeople.toString(),
          'special_request': _specialRequest,
        }),
      );

      if (response['status'] == 'success') {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
              SnackBar(content: Text('Reservasi berhasil diperbarui!')));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => const Navbar(selectedIndex: 2)),
          (Route<dynamic> route) => false,
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content:
                Text('Gagal memperbarui reservasi: ${response['message']}'),
            backgroundColor: Colors.red,
          ));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image
            Image.network(
              widget.restaurantImage,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(Icons.restaurant, size: 50, color: Colors.grey),
                  ),
                );
              },
            ),
            SizedBox(height: 16),

            // Header Text
            Text(
              'Reservasi',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.restaurantName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Jl. Pingit dan multiple branches in Yogyakarta',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 24),

            // Form Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(
                      label: 'Tanggal Reservasi',
                      value: DateFormat('yyyy-MM-dd').format(_selectedDate),
                      icon: Icons.calendar_today,
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),

                    _buildInputField(
                      label: 'Waktu Reservasi',
                      value: _selectedTime.format(context),
                      icon: Icons.access_time,
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedTime = picked;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),

                    // Jumlah Orang Field
                    TextFormField(
                      initialValue: _numberOfPeople.toString(),
                      decoration: InputDecoration(
                        labelText: 'Jumlah Orang',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.person, color: Colors.orange),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _numberOfPeople = int.tryParse(value) ?? 1;
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      initialValue: _specialRequest,
                      decoration: InputDecoration(
                        labelText: 'Special Request',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        setState(() {
                          _specialRequest = value;
                        });
                      },
                    ),
                    SizedBox(height: 24),

                    Center(
                      child: ElevatedButton(
                        onPressed: updateReservation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Reservasi',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                    ),
                  ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              suffixIcon: Icon(icon, color: Colors.orange),
            ),
            child: Text(value),
          ),
        ),
      ],
    );
  }
}
