import 'package:flutter/material.dart';
import 'package:rasanusantara_mobile/menu_management/menu_item_model.dart';
import 'package:rasanusantara_mobile/menu_management/menu_service.dart';

class MenuItemForm extends StatefulWidget {
  final String restaurantId;
  final MenuItem? menuItem; // Null jika menambah menu baru
  final VoidCallback onMenuUpdated;

  const MenuItemForm({
    super.key,
    required this.restaurantId,
    this.menuItem,
    required this.onMenuUpdated,
  });

  @override
  _MenuItemFormState createState() => _MenuItemFormState();
}

class _MenuItemFormState extends State<MenuItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  List<String> _selectedCategories = [];

  // Daftar kategori yang diizinkan
  final List<String> _allowedCategories = [
    "gudeg", "oseng", "bakpia", "sate", "sego gurih",
    "wedang", "lontong", "rujak cingur", "mangut lele", "ayam", "lainnya"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.menuItem != null) {
      _nameController.text = widget.menuItem!.name;
      _selectedCategories = List.from(widget.menuItem!.categories);
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final categories = _selectedCategories;

      try {
        if (widget.menuItem == null) {
          // Menambah menu baru
          await MenuService.addMenuItem(
            widget.restaurantId,
            name,
            categories,
          );
        } else {
          // Mengedit menu yang sudah ada
          await MenuService.editMenuItem(
            widget.restaurantId,
            widget.menuItem!.id,
            name,
            categories,
          );
        }

        widget.onMenuUpdated();
        Navigator.pop(context);
      } catch (e) {
        _showErrorDialog('Failed to save menu item: $e');
      }
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
        title: Text(widget.menuItem == null ? 'Tambah Menu' : 'Edit Menu'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Menu'),
                  validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pilih Kategori',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children: _allowedCategories.map((category) {
                    final isSelected = _selectedCategories.contains(category);
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategories.add(category);
                          } else {
                            _selectedCategories.remove(category);
                          }
                        });
                      },
                      selectedColor: Colors.orange.shade200,
                      checkmarkColor: Colors.white,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Text(widget.menuItem == null ? 'Tambah Menu' : 'Simpan Perubahan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
