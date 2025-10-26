class TreadDepthData {
  int currentActiveTreadDepth;
  int pressureValue;
  int temperatureValue;
  double treadDepth1;
  double treadDepth2;
  double treadDepth3;
  double treadDepth4;

  TreadDepthData({
    required this.currentActiveTreadDepth,
    required this.pressureValue,
    required this.temperatureValue,
    required this.treadDepth1,
    required this.treadDepth2,
    required this.treadDepth3,
    required this.treadDepth4,
  });

  // Factory constructor for creating an instance from JSON
  factory TreadDepthData.fromJson(Map<String, dynamic> json) {
    return TreadDepthData(
      currentActiveTreadDepth: json['currentActiveTreadDepth'] as int,
      pressureValue: json['pressureValue'] as int,
      temperatureValue: json['temperatureValue'] as int,
      treadDepth1: (json['treadDepth1'] as num).toDouble(),
      treadDepth2: (json['treadDepth2'] as num).toDouble(),
      treadDepth3: (json['treadDepth3'] as num).toDouble(),
      treadDepth4: (json['treadDepth4'] as num).toDouble(),
    );
  }

  // Method for serializing an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'currentActiveTreadDepth': currentActiveTreadDepth,
      'pressureValue': pressureValue,
      'temperatureValue': temperatureValue,
      'treadDepth1': treadDepth1,
      'treadDepth2': treadDepth2,
      'treadDepth3': treadDepth3,
      'treadDepth4': treadDepth4,
    };
  }
}
