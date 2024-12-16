import 'dart:convert';

List<ProductEntry> productEntryFromJson(String str) => List<ProductEntry>.from(
    json.decode(str).map((x) => ProductEntry.fromJson(x)));

String productEntryToJson(List<ProductEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductEntry {
  String model;
  String pk; // UUID tetap sebagai String
  Fields fields;

  ProductEntry({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory ProductEntry.fromJson(Map<String, dynamic> json) => ProductEntry(
        model: json["model"] ?? '',
        pk: json["pk"] ?? '', // Pastikan UUID ditangani sebagai String
        fields: Fields.fromJson(json["fields"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class Fields {
  String name;
  String location;
  int averagePrice;
  double rating;
  String image;

  Fields({
    required this.name,
    required this.location,
    required this.averagePrice,
    required this.rating,
    required this.image,
  });

  factory Fields.fromJson(Map<String, dynamic> json) {
    // Parsing harga sebagai integer
    int parsedPrice = 0;
    if (json["average_price"] != null) {
      if (json["average_price"] is int) {
        parsedPrice = json["average_price"];
      } else {
        parsedPrice = int.tryParse(json["average_price"].toString()) ?? 0;
      }
    }

    // Parsing rating sebagai double
    double parsedRating = 0.0;
    if (json["rating"] != null) {
      if (json["rating"] is num) {
        parsedRating = (json["rating"] as num).toDouble();
      } else {
        parsedRating = double.tryParse(json["rating"].toString()) ?? 0.0;
      }
    }

    return Fields(
      name: json["name"] ?? '',
      location: json["location"] ?? '',
      averagePrice: parsedPrice,
      rating: parsedRating,
      image: json["image"] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "location": location,
        "averagePrice": averagePrice,
        "rating": rating,
        "image": image,
      };
}
