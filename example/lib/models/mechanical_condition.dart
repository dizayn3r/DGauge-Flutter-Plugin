class MechanicalCondition {
  String? id;
  String? name;
  String? code;

  MechanicalCondition({
    this.id,
    this.name,
    this.code,
  });

  factory MechanicalCondition.fromJson(Map<String, dynamic> json) => MechanicalCondition(
    id: json["_id"],
    name: json["name"],
    code: json["code"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "code": code,
  };
}