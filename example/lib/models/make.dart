// To parse this JSON data, do
//
//     final make = makeFromJson(jsonString);

import 'dart:convert';

Make makeFromJson(String str) => Make.fromJson(json.decode(str));

String makeToJson(Make data) => json.encode(data.toJson());

class Make {
  String? id;
  String? make;
  String? makeName;
  String? makeImg;
  bool? active;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Make({
    this.id,
    this.make,
    this.makeName,
    this.makeImg,
    this.active,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Make.fromJson(Map<String, dynamic> json) => Make(
    id: json["_id"],
    make: json["make"],
    makeName: json["makeName"],
    makeImg: json["makeImg"],
    active: json["active"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "make": make,
    "makeName": makeName,
    "makeImg": makeImg,
    "active": active,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}
