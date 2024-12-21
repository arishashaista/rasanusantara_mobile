// To parse this JSON data, do
//
//     final reservation = reservationFromJson(jsonString);

import 'dart:convert';

List<Reservation> reservationFromJson(String str) => List<Reservation>.from(json.decode(str).map((x) => Reservation.fromJson(x)));

String reservationToJson(List<Reservation> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Reservation {
    String model;
    int pk;
    Fields fields;

    Reservation({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
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
    int user;
    String restaurant;
    DateTime reservationDate;
    String reservationTime;
    int numberOfPeople;
    String specialRequest;

    Fields({
        required this.user,
        required this.restaurant,
        required this.reservationDate,
        required this.reservationTime,
        required this.numberOfPeople,
        required this.specialRequest,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        restaurant: json["restaurant"],
        reservationDate: DateTime.parse(json["reservation_date"]),
        reservationTime: json["reservation_time"],
        numberOfPeople: json["number_of_people"],
        specialRequest: json["special_request"],
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "restaurant": restaurant,
        "reservation_date": "${reservationDate.year.toString().padLeft(4, '0')}-${reservationDate.month.toString().padLeft(2, '0')}-${reservationDate.day.toString().padLeft(2, '0')}",
        "reservation_time": reservationTime,
        "number_of_people": numberOfPeople,
        "special_request": specialRequest,
    };
}
