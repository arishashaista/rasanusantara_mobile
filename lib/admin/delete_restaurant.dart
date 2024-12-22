import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:rasanusantara_mobile/admin/navigation_provider.dart';
import 'package:rasanusantara_mobile/navbar.dart';

class DeleteRestaurantPage extends StatefulWidget {
  final String restaurantId;

  const DeleteRestaurantPage({
    Key? key,
    required this.restaurantId,
  }) : super(key: key);

  @override
  State<DeleteRestaurantPage> createState() => _DeleteRestaurantPageState();
}

class _DeleteRestaurantPageState extends State<DeleteRestaurantPage> {
  bool _isLoading = false;

  Future<void> _deleteRestaurant() async {
    setState(() => _isLoading = true);

    final url = Uri.parse(
        'https://arisha-shaista-rasanusantara.pbp.cs.ui.ac.id/adminview/delete-json/${widget.restaurantId}/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );

        // Update navigation and return to home with navbar
        context.read<NavigationProvider>().setIndex(0);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Navbar()),
        );
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Failed to delete');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Restaurant'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      'Are you sure you want to delete this restaurant?'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _deleteRestaurant,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Delete'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
      ),
    );
  }
}
