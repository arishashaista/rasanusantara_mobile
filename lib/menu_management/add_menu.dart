import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddMenuPage extends StatefulWidget {
  final String restaurantId;
  final String? menuItemId;

  const AddMenuPage({Key? key, required this.restaurantId, this.menuItemId}) : super(key: key);

  @override
  State<AddMenuPage> createState() => _AddMenuPageState();
}

class _AddMenuPageState extends State<AddMenuPage> {
  final TextEditingController _nameController = TextEditingController();
  List<String> _selectedCategories = [];
  bool _isLoading = false;

  final List<String> _categories = [
    "gudeg", "oseng", "bakpia", "sate", "sego gurih",
    "wedang", "lontong", "rujak cingur", "mangut lele", "ayam", "lainnya"
  ];

  Future<void> _addOrEditMenu() async {
    if (_nameController.text.isEmpty || _selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan kategori tidak boleh kosong")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = widget.menuItemId == null
        ? Uri.parse('http://127.0.0.1:8000/adminview/admin_menu/add/${widget.restaurantId}/')
        : Uri.parse('http://127.0.0.1:8000/adminview/admin_menu/edit/${widget.restaurantId}/${widget.menuItemId}/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'categories': _selectedCategories,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.menuItemId == null
                ? "Menu berhasil ditambahkan"
                : "Menu berhasil diperbarui"),
          ),
        );
        Navigator.pop(context, true);
      } else {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? "Gagal menambah menu")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menuItemId == null ? "Tambah Menu" : "Edit Menu"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nama Menu",
                filled: true,
                fillColor: Color.fromARGB(255, 94, 69, 69),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Pilih Kategori", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: _categories.map((category) {
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
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _addOrEditMenu,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: Text(widget.menuItemId == null ? "Tambah Menu" : "Simpan Perubahan"),
                  ),
          ],
        ),
      ),
    );
  }
}
