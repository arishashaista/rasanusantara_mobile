import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class FavoriteProvider extends ChangeNotifier {
  final Set<String> _favoriteIds = {};
  List<dynamic> _favoriteRestaurants = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  List<dynamic> get favoriteRestaurants => _favoriteRestaurants;

  bool isFavorite(String? restaurantId) {
    if (restaurantId == null) return false;
    return _favoriteIds.contains(restaurantId);
  }

  Future<void> initializeFavorites(CookieRequest request) async {
    try {
      if (request.loggedIn) {
        final response =
            await request.get('http://127.0.0.1:8000/favorite/json/');
        debugPrint('Favorite response: $response');
        if (response != null && response is List) {
          _favoriteIds.clear();
          _favoriteRestaurants = response;
          for (var fav in response) {
            if (fav['id'] != null) {
              _favoriteIds.add(fav['id'].toString());
              debugPrint('Added favorite ID: ${fav['id']}');
            } else {
              debugPrint('Favorite item with null ID encountered.');
            }
          }
          _isInitialized = true;
          notifyListeners();
        }
      } else {
        resetFavorites();
      }
    } catch (e) {
      debugPrint('Error initializing favorites: $e');
    }
  }

  Future<void> toggleFavorite(
    String? restaurantId,
    CookieRequest request,
    BuildContext context,
  ) async {
    if (restaurantId == null) {
      _showErrorDialog(context, 'Invalid restaurant ID.');
      return;
    }

    if (!request.loggedIn) {
      _showLoginAlert(context);
      return;
    }

    try {
      final response = await request.postJson(
        'http://127.0.0.1:8000/favorite/toggle-favorite/',
        jsonEncode({'restaurant_id': restaurantId}),
      );
      debugPrint('Toggle favorite response: $response');

      if (response is Map<String, dynamic> && response['success'] == true) {
        if (_favoriteIds.contains(restaurantId)) {
          _favoriteIds.remove(restaurantId);
          _favoriteRestaurants.removeWhere(
              (restaurant) => restaurant['id'].toString() == restaurantId);
        } else {
          _favoriteIds.add(restaurantId);
        }
        notifyListeners();
      } else {
        throw Exception(
            response['message'] ?? 'Failed to update favorite status');
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to connect to the server: $e');
      }
    }
  }

  void resetFavorites() {
    _favoriteIds.clear();
    _favoriteRestaurants.clear();
    _isInitialized = false;
    notifyListeners();
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
