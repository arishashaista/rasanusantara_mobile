import 'dart:convert';

List<ProductEntry> productEntryFromJson(String str) => List<ProductEntry>.from(
    json.decode(str).map((x) => ProductEntry.fromJson(x)));

String productEntryToJson(List<ProductEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductEntry {
  String model;
  String pk;
  Fields fields;

  ProductEntry({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory ProductEntry.fromJson(Map<String, dynamic> json) => ProductEntry(
        model: json["model"] ?? '',
        pk: json["pk"] ?? '',
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
    // Coba konversi price_usd ke int
    int parsedPrice = 0;
    if (json["price_usd"] != null) {
      if (json["price_usd"] is int) {
        // Jika memang sudah int, langsung assign
        parsedPrice = json["price_usd"];
      } else {
        // Jika berupa string, coba parse
        parsedPrice = int.tryParse(json["price_usd"].toString()) ?? 0;
      }
    }

    // Coba konversi rating ke double
    double parsedRating = 0.0;
    if (json["rating"] != null) {
      if (json["rating"] is num) {
        // Jika langsung numerik, mudah
        parsedRating = (json["rating"] as num).toDouble();
      } else {
        // Jika string, parse ke double
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
