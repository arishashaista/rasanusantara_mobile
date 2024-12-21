import 'dart:convert';
import 'package:http/http.dart' as http;
import 'menu_item_model.dart';

class MenuService {
  static const String baseUrl = 'http://127.0.0.1:8000/ubahmenu/api/menu_items';

  // Fetch menu items
  static Future<List<MenuItem>> fetchMenuItems(String restaurantId) async {
    final url = Uri.parse('$baseUrl/$restaurantId/');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => MenuItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch menu items: ${response.body}');
    }
  }

  // Add a new menu item
  static Future<void> addMenuItem(
      String restaurantId, String name, List<String> categories) async {
    final url = Uri.parse('$baseUrl/add/$restaurantId/');
    print('Adding menu item to: $url');

    try {
      print('Request Body: ${jsonEncode({
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

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add menu item: ${response.body}');
      }
    } catch (e) {
      print('Error in addMenuItem: $e');
      rethrow;
    }
  }

  // Edit an existing menu item
  static Future<void> editMenuItem(String restaurantId, String menuItemId,
      String name, List<String> categories) async {
    final url = Uri.parse('$baseUrl/edit/$restaurantId/$menuItemId/');
    print('Editing menu item at: $url');

    try {
      final response = await http.post(
        url, // Gunakan POST karena di server Anda menggunakan POST
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'categories': categories,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to edit menu item: ${response.body}');
      }
    } catch (e) {
      print('Error in editMenuItem: $e');
      rethrow;
    }
  }

  // Delete a menu item
  static Future<void> deleteMenuItem(
      String restaurantId, String menuItemId) async {
    final url = Uri.parse('$baseUrl/delete/$restaurantId/$menuItemId/');
    print('Deleting menu item at: $url');

    try {
      final response = await http.delete(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete menu item: ${response.body}');
      }
    } catch (e) {
      print('Error in deleteMenuItem: $e');
      rethrow;
    }
  }
}
