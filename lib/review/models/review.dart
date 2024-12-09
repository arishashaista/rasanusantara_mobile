// To parse this JSON data, do
//
//     final review = reviewFromJson(jsonString);

import 'dart:convert';

List<Review> reviewFromJson(String str) => List<Review>.from(json.decode(str).map((x) => Review.fromJson(x)));

String reviewToJson(List<Review> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Review {
    String model;
    int pk;
    Fields fields;

    Review({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Review.fromJson(Map<String, dynamic> json) => Review(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String user;
    String comment;
    int rating;
    DateTime createdAt;
    String restaurantName;

    Fields({
        required this.user,
        required this.comment,
        required this.rating,
        required this.createdAt,
        required this.restaurantName,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"].toString(),
        comment: json["comment"],
        rating: json["rating"],
        createdAt: DateTime.parse(json["created_at"]),
        restaurantName: json["restaurant_name"],
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "comment": comment,
        "rating": rating,
        "created_at": createdAt.toIso8601String(),
        "restaurant_name": restaurantName,
    };
}
