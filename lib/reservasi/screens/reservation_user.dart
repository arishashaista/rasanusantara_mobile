import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'reservation_delete.dart';
import 'reservation_edit.dart';
import 'package:intl/intl.dart';

class ReservationUserPage extends StatefulWidget {
  const ReservationUserPage({super.key});

  @override
  _ReservationUserPageState createState() => _ReservationUserPageState();
}

class _ReservationUserPageState extends State<ReservationUserPage> {
  List<dynamic> reservations = [];
  List<dynamic> filteredReservations = [];
  bool isLoading = true;
  String filter = 'Semua';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchReservations();
  }

  Future<void> fetchReservations() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'https://arisha-shaista-rasanusantara.pbp.cs.ui.ac.id/reservasi/json/',
      );

      setState(() {
        reservations = response;
        filteredReservations = reservations;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching reservations: $e')),
      );
    }
  }

  void filterReservations() {
    DateTime today = DateTime.now();

    setState(() {
      filteredReservations = reservations.where((reservation) {
        final restaurantName =
            reservation['fields']['restaurant'].toLowerCase();
        final reservationDate =
            DateTime.parse(reservation['fields']['reservation_date']);

        bool matchesSearch = restaurantName.contains(searchQuery.toLowerCase());

        if (filter == 'Semua') return matchesSearch;
        if (filter == 'Hari Ini')
          return matchesSearch && isSameDay(reservationDate, today);
        if (filter == 'Akan Datang')
          return matchesSearch && reservationDate.isAfter(today);
        if (filter == 'Terlewat')
          return matchesSearch && reservationDate.isBefore(today);

        return matchesSearch;
      }).toList();
    });
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void navigateToEditPage(int reservationId, Map<String, dynamic> reservation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationEditPage(
          reservationId: reservationId,
          restaurantName: reservation['restaurant'],
          reservationDate: reservation['reservation_date'],
          reservationTime: reservation['reservation_time'],
          numberOfPeople: reservation['number_of_people'],
          specialRequest: reservation['special_request'],
          restaurantImage: reservation['restaurant_image'],
        ),
      ),
    ).then((_) => fetchReservations());
  }

  void navigateToDeletePage(int reservationId, String restaurantName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationDeletePage(
          reservationId: reservationId,
          restaurantName: restaurantName,
        ),
      ),
    ).then((_) => fetchReservations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
                filterReservations();
              });
            },
            decoration: InputDecoration(
              hintText: 'Ingin makan apa hari ini?',
              prefixIcon: Icon(Icons.search, color: Colors.orange),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 0.0),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Dropdown
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButton<String>(
              value: filter,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              isExpanded: true,
              dropdownColor: Colors.orange,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              underline: SizedBox(),
              items: ['Semua', 'Hari Ini', 'Akan Datang', 'Terlewat']
                  .map((filterOption) => DropdownMenuItem(
                        value: filterOption,
                        child: Text(filterOption),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  filter = value!;
                  filterReservations();
                });
              },
            ),
          ),

          // Reservation List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredReservations.isEmpty
                    ? const Center(child: Text('Tidak ada reservasi.'))
                    : ListView.builder(
                        itemCount: filteredReservations.length,
                        itemBuilder: (context, index) {
                          final reservation =
                              filteredReservations[index]['fields'];
                          final reservationId =
                              filteredReservations[index]['pk'];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  reservation['restaurant_image'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.restaurant,
                                          color: Colors.grey),
                                    );
                                  },
                                ),
                              ),
                              title: Text(reservation['restaurant'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () => navigateToEditPage(
                                            reservationId, reservation),
                                        child: const Text('Edit',
                                            style:
                                                TextStyle(color: Colors.blue)),
                                      ),
                                      TextButton(
                                        onPressed: () => navigateToDeletePage(
                                            reservationId,
                                            reservation['restaurant']),
                                        child: const Text('Cancel',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
