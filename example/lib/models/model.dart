// To parse this JSON data, do
//
//     final model = modelFromJson(jsonString);

import 'dart:convert';

Model modelFromJson(String str) => Model.fromJson(json.decode(str));

String modelToJson(Model data) => json.encode(data.toJson());

class Model {
  String? id;
  String? name;
  String? make;
  bool? active;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Model({
    this.id,
    this.name,
    this.make,
    this.active,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Model.fromJson(Map<String, dynamic> json) => Model(
    id: json["_id"],
    name: json["name"],
    make: json["make"],
    active: json["active"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "make": make,
    "active": active,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}
