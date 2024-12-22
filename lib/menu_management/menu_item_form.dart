import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MenuItemForm extends StatefulWidget {
  final String restaurantId;
  final String? menuItemId; // Null jika menambah menu baru
  final VoidCallback onMenuUpdated;

  const MenuItemForm({
    Key? key,
    required this.restaurantId,
    this.menuItemId,
    required this.onMenuUpdated,
  }) : super(key: key);

  @override
  _MenuItemFormState createState() => _MenuItemFormState();
}

class _MenuItemFormState extends State<MenuItemForm> {
  final _nameController = TextEditingController();
  List<String> _selectedCategories = [];
  final List<String> _allowedCategories = [
    "gudeg",
    "oseng",
    "bakpia",
    "sate",
    "sego gurih",
    "wedang",
    "lontong",
    "rujak cingur",
    "mangut lele",
    "ayam",
    "lainnya"
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _submitForm() async {
    if (_nameController.text.isEmpty || _selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan kategori tidak boleh kosong.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Inilah hal utama: endpoint API JSON
    final url = widget.menuItemId == null
        ? Uri.parse(
            'https://arisha-shaista-rasanusantara.pbp.cs.ui.ac.id/ubahmenu/api/menu_items/add/${widget.restaurantId}/')
        : Uri.parse(
            'https://arisha-shaista-rasanusantara.pbp.cs.ui.ac.id/ubahmenu/api/menu_items/edit/${widget.restaurantId}/${widget.menuItemId}/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'categories': _selectedCategories,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.menuItemId == null
                ? 'Menu berhasil ditambahkan!'
                : 'Menu berhasil diperbarui!'),
          ),
        );
        widget.onMenuUpdated();
        Navigator.pop(context, true);
      } else {
        throw Exception(
            'Gagal menyimpan data menu. Code: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Gagal menyimpan data menu: $e');
    }

    setState(() => _isLoading = false);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menuItemId == null ? 'Tambah Menu' : 'Edit Menu'),
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama Menu'),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Pilih Kategori',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      children: _allowedCategories.map((category) {
                        final isSelected =
                            _selectedCategories.contains(category);
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: Text(widget.menuItemId == null
                            ? 'Tambah Menu'
                            : 'Simpan Perubahan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
