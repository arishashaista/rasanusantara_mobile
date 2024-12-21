import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rasanusantara_mobile/menu_management/menu_item_model.dart';

class MenuService {
  static const String baseUrl = 'http://127.0.0.1:8000/adminview/admin_menu';

  // Fungsi untuk mengambil daftar menu dari server
  static Future<List<MenuItem>> fetchMenuItems(String restaurantId) async {
    final response = await http.get(Uri.parse('$baseUrl/$restaurantId/'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => MenuItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch menu items: ${response.body}');
    }
  }

  // Fungsi untuk menambah menu baru
  static Future<void> addMenuItem(String restaurantId, String name, List<String> categories) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add/$restaurantId/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'categories': categories,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add menu item: ${response.body}');
    }
  }

  // Fungsi untuk mengedit menu yang sudah ada
  static Future<void> editMenuItem(String restaurantId, String menuItemId, String name, List<String> categories) async {
    final response = await http.put(
      Uri.parse('$baseUrl/edit/$restaurantId/$menuItemId/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'categories': categories,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit menu item: ${response.body}');
    }
  }

  // Fungsi untuk menghapus menu item
  static Future<void> deleteMenuItem(String restaurantId, String menuItemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete/$restaurantId/$menuItemId/'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete menu item: ${response.body}');
    }
  }
}
