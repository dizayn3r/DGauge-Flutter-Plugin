
class TyreConfiguration {
  final int tyreNumber;
  final int tyreStatus;
  final String treadCount;
  final String tyreSerialNumber;
  final int identifier;
  final String pressureValue;
  final String temperatureValue;

  TyreConfiguration({
    required this.tyreNumber,
    required this.tyreStatus,
    required this.treadCount,
    required this.tyreSerialNumber,
    required this.identifier,
    required this.pressureValue,
    required this.temperatureValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'tyreNumber': tyreNumber,
      'identifier': identifier,
      'tyreStatus': tyreStatus,
      'treadCount': treadCount,
      'tyreSerialNumber': tyreSerialNumber,
      'pressureValue': pressureValue,
      'temperatureValue': temperatureValue,
    };
  }
}