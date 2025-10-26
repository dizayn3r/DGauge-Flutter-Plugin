class Tyre {
  String? id;
  String? stencilNo;
  int? totalKilometerTravelled;
  String? averageNsd;
  String? position;
  DateTime? lastInspectionDate;
  bool? replacementWithoutInspection;

  Tyre({
    this.id,
    this.stencilNo,
    this.totalKilometerTravelled,
    this.averageNsd,
    this.position,
    this.lastInspectionDate,
    this.replacementWithoutInspection,
  });

  factory Tyre.fromJson(Map<String, dynamic> json) => Tyre(
    id: json["_id"],
    stencilNo: json["stencilNo"],
    totalKilometerTravelled: json["totalKillometerTravelled"],
    averageNsd: json["averageNSD"],
    position: json["position"],
    lastInspectionDate: json["lastInspectionDate"] == null ? null : DateTime.parse(json["lastInspectionDate"]),
    replacementWithoutInspection: json["replacementWithoutInspection"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "stencilNo": stencilNo,
    "totalKillometerTravelled": totalKilometerTravelled,
    "averageNSD": averageNsd,
    "position": position,
    "lastInspectionDate": lastInspectionDate?.toIso8601String(),
    "replacementWithoutInspection": replacementWithoutInspection,
  };
}