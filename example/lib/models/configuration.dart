class Configuration {
  String? id;
  String? name;
  int? wheelCount;
  List<String>? tyrePositions;

  Configuration({
    this.id,
    this.name,
    this.wheelCount,
    this.tyrePositions,
  });

  factory Configuration.fromJson(Map<String, dynamic> json) => Configuration(
    id: json["_id"],
    name: json["name"],
    wheelCount: json["wheelCount"],
    tyrePositions: json["tyrePositions"] == null ? [] : List<String>.from(json["tyrePositions"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "wheelCount": wheelCount,
    "tyrePositions": tyrePositions == null ? [] : List<dynamic>.from(tyrePositions!.map((x) => x)),
  };
}