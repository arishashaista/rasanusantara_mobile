class ProductEntry {
  String id;
  String name;
  String location;
  int averagePrice; // Diubah ke int
  double rating;
  String image;

  ProductEntry({
    required this.id,
    required this.name,
    required this.location,
    required this.averagePrice,
    required this.rating,
    required this.image,
  });

  factory ProductEntry.fromJson(Map<String, dynamic> json) => ProductEntry(
        id: json["id"] ?? '',
        name: json["name"] ?? "Nama Tidak Tersedia",
        location: json["location"] ?? "Lokasi Tidak Tersedia",
        averagePrice: json["average_price"] != null
            ? int.tryParse(json["average_price"].toString()) ?? 0
            : 0,
        rating: json["rating"] != null
            ? double.tryParse(json["rating"].toString()) ?? 0.0
            : 0.0,
        image: json["image"] ?? "https://via.placeholder.com/150",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "location": location,
        "average_price": averagePrice,
        "rating": rating,
        "image": image,
      };
}
