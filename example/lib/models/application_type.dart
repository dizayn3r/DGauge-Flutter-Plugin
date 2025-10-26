class ApplicationType {
  String? id;
  String? name;

  ApplicationType({
    this.id,
    this.name,
  });

  factory ApplicationType.fromJson(Map<String, dynamic> json) => ApplicationType(
    id: json["_id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
  };
}