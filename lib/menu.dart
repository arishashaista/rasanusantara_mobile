import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rasanusantara_mobile/model.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  // Fungsi untuk fetch data dari endpoint /json
  Future<List<ProductEntry>> fetchProducts() async {
    final url =
        Uri.parse('http://127.0.0.1:8000/json'); // Ganti dengan endpoint Anda
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      List<ProductEntry> listProducts = [];
      for (var d in data) {
        if (d != null) {
          listProducts.add(ProductEntry.fromJson(d));
        }
      }
      return listProducts;
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<ProductEntry>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          // Jika masih loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Jika ada error
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Jika data kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data produk.',
                style: TextStyle(fontSize: 20, color: Colors.blueGrey),
                textAlign: TextAlign.center,
              ),
            );
          }

          // Data berhasil di-load
          final products = snapshot.data!;

          // Menampilkan dalam grid
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(product.fields);
              },
            ),
          );
        },
      ),
    );
  }

  // Widget untuk menampilkan masing-masing produk
  Widget _buildProductCard(Fields fields) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Jika image adalah asset lokal, gunakan Image.asset
          // Jika image adalah URL, gunakan Image.network
          // Contoh di sini diasumsikan adalah asset lokal:
          Expanded(
            child: fields.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8)),
                    child: Image.network(
                      fields.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Container(
                    alignment: Alignment.center,
                    color: Colors.grey.shade200,
                    child:
                        const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              fields.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              fields.location,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              'Price: \$${fields.averagePrice}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${fields.rating.toString()}/5',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
