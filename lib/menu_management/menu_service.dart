import 'dart:convert';
import 'package:http/http.dart' as http;
import 'menu_item_model.dart';

class MenuService {
  static const String baseUrl = 'http://127.0.0.1:8000/adminview/admin_menu';

  // Fetch menu items
static Future<List<MenuItem>> fetchMenuItems(String restaurantId) async {
  final url = Uri.parse('$baseUrl/$restaurantId/');
  print('Fetching menu items from: $url'); // Debugging

  final response = await http.get(url);

  print('Response status: ${response.statusCode}'); // Debugging
  print('Response body: ${response.body}'); // Debugging

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => MenuItem.fromJson(item)).toList();
  } else {
    throw Exception('Failed to fetch menu items: ${response.body}');
  }
}


  // Add a new menu item
  static Future<void> addMenuItem(String restaurantId, String name, List<String> categories) async {
    final url = Uri.parse('$baseUrl/add/$restaurantId/');
    print('Adding menu item to: $url'); // Debugging
    print('Request body: ${jsonEncode({'name': name, 'categories': categories})}'); // Debugging

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'categories': categories,
        }),
      );
      print('Response status: ${response.statusCode}'); // Debugging
      print('Response body: ${response.body}'); // Debugging

      if (response.statusCode != 201) {
        print('Error adding menu item: ${response.body}'); // Debugging
        throw Exception('Failed to add menu item: ${response.body}');
      }
    } catch (e) {
      print('Exception in addMenuItem: $e'); // Debugging
      rethrow;
    }
  }

  // Edit an existing menu item
  static Future<void> editMenuItem(String restaurantId, String menuItemId, String name, List<String> categories) async {
    final url = Uri.parse('$baseUrl/edit/$restaurantId/$menuItemId/');
    print('Editing menu item at: $url'); // Debugging
    print('Request body: ${jsonEncode({'name': name, 'categories': categories})}'); // Debugging

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'categories': categories,
        }),
      );
      print('Response status: ${response.statusCode}'); // Debugging
      print('Response body: ${response.body}'); // Debugging

      if (response.statusCode != 200) {
        print('Error editing menu item: ${response.body}'); // Debugging
        throw Exception('Failed to edit menu item: ${response.body}');
      }
    } catch (e) {
      print('Exception in editMenuItem: $e'); // Debugging
      rethrow;
    }
  }

  // Delete a menu item
  static Future<void> deleteMenuItem(String restaurantId, String menuItemId) async {
    final url = Uri.parse('$baseUrl/delete/$restaurantId/$menuItemId/');
    print('Deleting menu item at: $url'); // Debugging

    try {
      final response = await http.delete(url);
      print('Response status: ${response.statusCode}'); // Debugging
      print('Response body: ${response.body}'); // Debugging

      if (response.statusCode != 200) {
        print('Error deleting menu item: ${response.body}'); // Debugging
        throw Exception('Failed to delete menu item: ${response.body}');
      }
    } catch (e) {
      print('Exception in deleteMenuItem: $e'); // Debugging
      rethrow;
    }
  }
}
