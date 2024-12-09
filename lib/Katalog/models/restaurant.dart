// To parse this JSON data, do
//
//     final restaurant = restaurantFromJson(jsonString);

import 'dart:convert';

List<Restaurant> restaurantFromJson(String str) => List<Restaurant>.from(json.decode(str).map((x) => Restaurant.fromJson(x)));

String restaurantToJson(List<Restaurant> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Restaurant {
    String id;
    String name;
    String location;
    String averagePrice;
    double rating;
    String image;
    List<MenuItem> menuItems;

    Restaurant({
        required this.id,
        required this.name,
        required this.location,
        required this.averagePrice,
        required this.rating,
        required this.image,
        required this.menuItems,
    });

    factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json["id"],
        name: json["name"],
        location: json["location"],
        averagePrice: json["average_price"],
        rating: json["rating"]?.toDouble(),
        image: json["image"],
        menuItems: List<MenuItem>.from(json["menu_items"].map((x) => MenuItem.fromJson(x))),
    );

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
    String id;
    String name;

    MenuItem({
        required this.id,
        required this.name,
    });

    factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}
