import 'dart:async';
import 'package:flutter/services.dart';

class DGaugeFlutter {
  /// Private constructor for singleton
  DGaugeFlutter._internal();

  /// Single instance of the class
  static final DGaugeFlutter _instance = DGaugeFlutter._internal();

  /// Factory constructor to return the single instance
  factory DGaugeFlutter() => _instance;

  static const MethodChannel _channel = MethodChannel('dgauge_flutter');
  static const EventChannel _eventChannel = EventChannel('dgauge_flutter_events');


  static Future<String?> getPlatformVersion() async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  // Initialize the DGuage SDK
  static Future<void> initialize() async {
    await _channel.invokeMethod('initialize');
  }

  // Send vehicle configuration
  static Future<bool> sendVehicleConfiguration({
    required String macAddress,
    required Map<String, dynamic> vehicleConfig,
  }) async {
    return await _channel.invokeMethod('sendVehicleConfiguration', {
      'macAddress': macAddress,
      'vehicleConfig': vehicleConfig,
    });
  }

  // Start tire inspection
  static Future<void> startTireInspection(String macAddress) async {
    await _channel.invokeMethod('startTireInspection', {
      'macAddress': macAddress,
    });
  }

  // Get all tire data
  static Future<void> fetchAllTireData(String macAddress) async {
    await _channel.invokeMethod('fetchAllTireData', {
      'macAddress': macAddress,
    });
  }

  // Listen to events from native side
  static Stream<Map<String, dynamic>> get eventStream {
    return _eventChannel.receiveBroadcastStream().cast<Map<String, dynamic>>();
  }
}

// Data classes for type safety
class TireConfiguration {
  final int tireNumber;
  final int tireStatus;
  final String treadCount;
  final String tireSerialNumber;
  final int identifier;
  final String pressureValue;
  final String temperatureValue;

  TireConfiguration({
    required this.tireNumber,
    required this.tireStatus,
    required this.treadCount,
    required this.tireSerialNumber,
    required this.identifier,
    required this.pressureValue,
    required this.temperatureValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'tireNumber': tireNumber,
      'tireStatus': tireStatus,
      'treadCount': treadCount,
      'tireSerialNumber': tireSerialNumber,
      'identifier': identifier,
      'pressureValue': pressureValue,
      'temperatureValue': temperatureValue,
    };
  }
}

class VehicleConfiguration {
  final String vehicleNumber;
  final String axleConfiguration;
  final int numberOfTires;
  final List<TireConfiguration> tireConfigurations;

  VehicleConfiguration({
    required this.vehicleNumber,
    required this.axleConfiguration,
    required this.numberOfTires,
    required this.tireConfigurations,
  });

  Map<String, dynamic> toMap() {
    return {
      'vehicleNumber': vehicleNumber,
      'axleConfiguration': axleConfiguration,
      'numberOfTires': numberOfTires,
      'tireConfigurations': tireConfigurations.map((e) => e.toMap()).toList(),
    };
  }
}
