class Restaurant {
  String id; // UUID dari "pk"
  String name; // Diambil dari fields["name"]
  String location; // Diambil dari fields["location"]
  double averagePrice; // Diambil dari fields["average_price"]
  double rating; // Diambil dari fields["rating"]
  String image; // Diambil dari fields["image"]
  List<MenuItem> menuItems; // Bisa kosong

  Restaurant({
    required this.id,
    required this.name,
    required this.location,
    required this.averagePrice,
    required this.rating,
    required this.image,
    required this.menuItems,
  });

  // Factory memperhatikan properti "fields"
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json["id"] ?? "", // Ambil "id" dari root JSON
      name: json["name"] ?? "Nama Tidak Tersedia",
      location: json["location"] ?? "Lokasi Tidak Tersedia",
      averagePrice: json["average_price"] != null
          ? double.tryParse(json["average_price"].toString()) ?? 0.0
          : 0.0,

      rating: json["rating"] != null
          ? double.tryParse(json["rating"].toString()) ?? 0.0
          : 0.0, // Pastikan ke double
      image: json["image"] ??
          "data:image/png;base64,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",
      menuItems: json["menu_items"] != null
          ? List<MenuItem>.from(
              json["menu_items"].map((x) => MenuItem.fromJson(x)))
          : [], // Ambil menu_items dari root JSON
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "location": location,
        "average_price": averagePrice,
        "rating": rating,
        "image": image,
        "menu_items": List<dynamic>.from(menuItems.map((x) => x.toJson())),
      };
}

class MenuItem {
  String id; // UUID atau identifier
  String name; // Nama menu item
  List<String> categories; // Daftar kategori menu

  MenuItem({
    required this.id,
    required this.name,
    required this.categories,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json["id"] ?? "",
        name: json["name"] ?? "Menu Tidak Tersedia",
        categories: json["categories"] != null
            ? List<String>.from(json["categories"])
            : [], // Ambil daftar kategori
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "categories": categories,
      };
}
