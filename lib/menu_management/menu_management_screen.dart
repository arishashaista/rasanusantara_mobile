import 'package:flutter/material.dart';
import 'package:rasanusantara_mobile/menu_management/menu_item_model.dart';
import 'package:rasanusantara_mobile/menu_management/menu_service.dart';
import 'menu_item_form.dart';

class MenuManagementScreen extends StatefulWidget {
  final String restaurantId;

  const MenuManagementScreen({super.key, required this.restaurantId});

  @override
  _MenuManagementScreenState createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  List<MenuItem> menuItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
  }

  Future<void> _fetchMenuItems() async {
    try {
      List<MenuItem> items = await MenuService.fetchMenuItems(widget.restaurantId);
      setState(() {
        menuItems = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to load menu items: $e');
    }
  }

  void _deleteMenuItem(String menuItemId) async {
    try {
      await MenuService.deleteMenuItem(widget.restaurantId, menuItemId);
      _fetchMenuItems(); // Refresh the list after deletion
    } catch (e) {
      _showErrorDialog('Failed to delete menu item: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Menu'),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Categories: ${item.categories.join(", ")}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () => _navigateToEditMenu(item),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              child: const Text('Edit'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _deleteMenuItem(item.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _navigateToAddMenu,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Tambah Menu',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  void _navigateToAddMenu() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuItemForm(
          restaurantId: widget.restaurantId,
          onMenuUpdated: _fetchMenuItems,
        ),
      ),
    );
  }

 void _navigateToEditMenu(MenuItem menuItem) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MenuItemForm(
        restaurantId: widget.restaurantId,
        menuItemId: menuItem.id, // Ganti menuItem ke menuItemId
        onMenuUpdated: _fetchMenuItems,
      ),
    ),
  );
}
}
