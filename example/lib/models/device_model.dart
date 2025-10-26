class DGaugeDeviceModel {
  final String? name;
  final String? macAddress;

  DGaugeDeviceModel({this.name, this.macAddress});

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'macAddress': macAddress,
    };
  }

  // Create model from JSON
  factory DGaugeDeviceModel.fromJson(Map<String, dynamic> json) {
    return DGaugeDeviceModel(
      name: json['name'],
      macAddress: json['macAddress'],
    );
  }
}
