class ContractType {
  String? id;
  String? name;

  ContractType({
    this.id,
    this.name,
  });

  factory ContractType.fromJson(Map<String, dynamic> json) => ContractType(
    id: json["_id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
  };
}