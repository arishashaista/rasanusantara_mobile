import 'dart:convert';
import 'package:http/http.dart' as http;
import 'menu_item_model.dart';

class MenuService {
  // Ganti ini sesuai domain/port Anda. Di contoh, pakai 127.0.0.1:8000.
  // Jika pakai Android emulator, bisa jadi 10.0.2.2:8000.
  static const String baseUrl = 'http://127.0.0.1:8000/ubahmenu/api/menu_items';

  // Fetch menu items (GET)
  static Future<List<MenuItem>> fetchMenuItems(String restaurantId) async {
    final url = Uri.parse('$baseUrl/$restaurantId/');
    print('Fetching menu items from: $url'); // Debugging

    final response = await http.get(url);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MenuItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch menu items: ${response.body}');
    }
  }

  // Add a new menu item (POST => add_menu_api)
  static Future<void> addMenuItem(
      String restaurantId, String name, List<String> categories) async {
    final url = Uri.parse('$baseUrl/add/$restaurantId/');
    print('Adding menu item to: $url');
    print('Request body: ${jsonEncode({
          'name': name,
          'categories': categories
        })}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'categories': categories,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // add_menu_api biasanya balas status=201 jika sukses
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add menu item: ${response.body}');
    }
  }

  // Edit an existing menu item (POST => edit_menu_api)
  static Future<void> editMenuItem(String restaurantId, String menuItemId,
      String name, List<String> categories) async {
    final url = Uri.parse('$baseUrl/edit/$restaurantId/$menuItemId/');
    print('Editing menu item at: $url');
    print('Request body: ${jsonEncode({
          'name': name,
          'categories': categories
        })}');

    // Note: Django menunggu POST di edit_menu_api
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'categories': categories,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to edit menu item: ${response.body}');
    }
  }

  // Delete a menu item (DELETE => delete_menu_api)
  static Future<void> deleteMenuItem(
      String restaurantId, String menuItemId) async {
    final url = Uri.parse('$baseUrl/delete/$restaurantId/$menuItemId/');
    print('Deleting menu item at: $url');

    final response = await http.delete(url);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete menu item: ${response.body}');
    }
  }
}
