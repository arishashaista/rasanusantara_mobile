import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class FavoriteProvider extends ChangeNotifier {
  final Set<String> _favoriteIds = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  bool isFavorite(String restaurantId) => _favoriteIds.contains(restaurantId);

  Future<void> initializeFavorites(CookieRequest request) async {
    try {
      if (request.loggedIn) {
        final response =
            await request.get('http://127.0.0.1:8000/favorite/json/');
        if (response != null) {
          _favoriteIds.clear();
          for (var fav in response) {
            _favoriteIds.add(fav['id'].toString());
          }
          _isInitialized = true;
          notifyListeners(); // Beri tahu listener bahwa data telah diperbarui
        }
      } else {
        resetFavorites(); // Jika tidak login, reset data favorit
      }
    } catch (e) {
      debugPrint('Error initializing favorites: $e');
    }
  }

  Future<void> toggleFavorite(
    String restaurantId,
    CookieRequest request,
    BuildContext context,
  ) async {
    if (!request.loggedIn) {
      _showLoginAlert(context);
      return;
    }

    try {
      final response = await request.postJson(
        'http://127.0.0.1:8000/favorite/toggle-favorite/',
        jsonEncode({'restaurant_id': restaurantId}),
      );

      if (response is Map<String, dynamic> && response['success'] == true) {
        await initializeFavorites(
            request); // Sinkronisasi ulang data setelah toggle
      } else {
        throw Exception(
            response['message'] ?? 'Failed to update favorite status');
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to connect to the server: $e');
      }
    }
  }

  void resetFavorites() {
    _favoriteIds.clear();
    _isInitialized = false;
    notifyListeners(); // Beri tahu listener bahwa data telah dihapus
  }

  void _showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Not Logged In'),
        content: const Text('Please log in to mark favorites.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
