import 'package:rasanusantara_mobile/image.dart';

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
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRhdkA-pOR1l5lRdCAtAAA2XSt2qg-WxQcg5A&s",
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
