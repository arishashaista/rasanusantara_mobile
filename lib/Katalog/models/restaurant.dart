import 'dart:convert';

List<Restaurant> restaurantFromJson(String str) =>
    List<Restaurant>.from(json.decode(str).map((x) => Restaurant.fromJson(x)));

String restaurantToJson(List<Restaurant> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Restaurant {
  String id; // UUID dari "pk"
  String name; // Diambil dari fields["name"]
  String location; // Diambil dari fields["location"]
  int averagePrice; // Diambil dari fields["average_price"]
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
    final fields = json["fields"] ?? {}; // Ambil "fields"

    return Restaurant(
      id: json["pk"] ?? "", // Ambil UUID dari "pk"
      name: fields["name"] ?? "Nama Tidak Tersedia",
      location: fields["location"] ?? "Lokasi Tidak Tersedia",
      averagePrice: fields["average_price"] != null
          ? int.tryParse(fields["average_price"].toString()) ?? 0
          : 0, // Pastikan ke int
      rating: fields["rating"] != null
          ? double.tryParse(fields["rating"].toString()) ?? 0.0
          : 0.0, // Pastikan ke double
      image: fields["image"] ?? "https://via.placeholder.com/150",
      menuItems: fields["menu_items"] != null
          ? List<MenuItem>.from(
              fields["menu_items"].map((x) => MenuItem.fromJson(x)))
          : [], // Handle null menu_items
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

  MenuItem({
    required this.id,
    required this.name,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json["id"] ?? "",
        name: json["name"] ?? "Menu Tidak Tersedia",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
