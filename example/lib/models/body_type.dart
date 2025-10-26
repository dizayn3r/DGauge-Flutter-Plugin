class BodyType {
  String? id;
  String? name;

  BodyType({
    this.id,
    this.name,
  });

  factory BodyType.fromJson(Map<String, dynamic> json) => BodyType(
    id: json["_id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
  };
}