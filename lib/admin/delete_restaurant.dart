import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

    try {
      final url = Uri.parse('http://127.0.0.1:8000/adminview/delete-json/${widget.restaurantId}/');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (!mounted) return;

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to delete restaurant');
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
                  const Text('Are you sure you want to delete this restaurant?'),
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