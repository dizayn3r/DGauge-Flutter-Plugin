class Hub {
  String? id;
  String? hubName;

  Hub({
    this.id,
    this.hubName,
  });

  factory Hub.fromJson(Map<String, dynamic> json) => Hub(
    id: json["_id"],
    hubName: json["hubName"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "hubName": hubName,
  };
}