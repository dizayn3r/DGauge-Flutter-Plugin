class Fleet {
  String? id;
  String? fleetName;
  int? averageRunKmPerDay;
  bool? enableReplacementWithoutInspection;

  Fleet({
    this.id,
    this.fleetName,
    this.averageRunKmPerDay,
    this.enableReplacementWithoutInspection,
  });

  factory Fleet.fromJson(Map<String, dynamic> json) => Fleet(
    id: json["_id"],
    fleetName: json["fleetName"],
    averageRunKmPerDay: json["averageRunKmPerDay"],
    enableReplacementWithoutInspection: json["enableReplacementWithoutInspection"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "fleetName": fleetName,
    "averageRunKmPerDay": averageRunKmPerDay,
    "enableReplacementWithoutInspection": enableReplacementWithoutInspection,
  };
}