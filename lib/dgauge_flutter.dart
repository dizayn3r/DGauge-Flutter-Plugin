import 'dart:async';
import 'package:flutter/services.dart';
import 'services/logger_service.dart';

class DGaugeFlutter {
  final MethodChannel _methodChannel = const MethodChannel('dgauge_flutter');
  final EventChannel _eventChannel = const EventChannel('dgauge_flutter_events');

  Stream<Map<String, dynamic>>? _eventStream;
  final _log = LoggerService.tagged('DGaugeFlutter');

  /// Get Android platform version
  Future<String?> getPlatformVersion() async {
    try {
      final version = await _methodChannel.invokeMethod<String>('getPlatformVersion');
      _log.info('Platform version: $version');
      return version;
    } catch (e, s) {
      _log.error('Error fetching platform version', error: e, stackTrace: s);
      return 'Unknown Platform Version: $e';
    }
  }

  /// Initialize DGauge SDK
  Future<void> initialize() async {
    _log.info('Initializing DGauge SDK');
    await _methodChannel.invokeMethod('initialize');
    _log.info('DGauge SDK initialized');
  }

  /// Connect to DGauge device (by MAC address)
  Future<bool> connectDGauge({required String macAddress}) async {
    _log.debug('Connecting to DGauge with MAC: $macAddress');
    final result = await _methodChannel.invokeMethod('connectDGauge', {'macAddress': macAddress});
    return result == true;
  }

  /// Disconnect from DGauge device
  Future<bool> disconnectDGauge({required String macAddress}) async {
    _log.debug('Disconnecting from DGauge with MAC: $macAddress');
    final result = await _methodChannel.invokeMethod('disconnectDGauge', {'macAddress': macAddress});
    return result == true;
  }

  /// Send vehicle and tyre configuration
  Future<bool> sendVehicleConfiguration({
    required String macAddress,
    required Map<String, dynamic> vehicleConfig,
  }) async {
    _log.info('Sending vehicle configuration to MAC: $macAddress');
    final result = await _methodChannel.invokeMethod('sendVehicleConfiguration', {
      'macAddress': macAddress,
      'vehicleConfig': vehicleConfig,
    });
    return result == true;
  }

  /// Start tread scan for a tyre (live stream via events)
  Future<void> startTireInspection({required String macAddress}) async {
    _log.debug('Starting tire inspection for MAC: $macAddress');
    await _methodChannel.invokeMethod('startTireInspection', {'macAddress': macAddress});
  }

  /// Fetch all tread readings for all tyres (batch via events)
  Future<void> fetchAllTireData({required String macAddress}) async {
    _log.debug('Fetching all tire data for MAC: $macAddress');
    await _methodChannel.invokeMethod('fetchAllTireData', {'macAddress': macAddress});
  }

  // =========================
  // NEW: Awaitable read APIs
  // =========================

  /// One-shot read: resolves with the FIRST live packet that arrives after the call.
  /// Returns:
  /// {
  ///   tireNumber, noOfTreadDepth, pressureValue, temperatureValue,
  ///   treadDepth1..4, treadDepths[], treadReadingStatus, identifier
  /// }
  Future<Map<String, dynamic>?> readTreadDepthOnce({
    required String macAddress,
    int timeoutMs = 12000,
  }) async {
    _log.debug('One-shot read for MAC: $macAddress (timeoutMs=$timeoutMs)');
    try {
      final res = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'readTreadDepthOnce',
        {'macAddress': macAddress, 'timeoutMs': timeoutMs},
      );
      return res == null ? null : Map<String, dynamic>.from(res);
    } on PlatformException catch (e, s) {
      _log.error('readTreadDepthOnce failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Batch read: resolves when the SDK returns the full list of tyres.
  /// Returns: List<Map<String, dynamic>>
  Future<List<Map<String, dynamic>>> readAllTreadDepths({
    required String macAddress,
    int timeoutMs = 20000,
  }) async {
    _log.debug('All-tyres read for MAC: $macAddress (timeoutMs=$timeoutMs)');
    try {
      final res = await _methodChannel.invokeMethod<List<dynamic>>(
        'readAllTreadDepths',
        {'macAddress': macAddress, 'timeoutMs': timeoutMs},
      );
      if (res == null) return const [];
      return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on PlatformException catch (e, s) {
      _log.error('readAllTreadDepths failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  // =========================
  // Events
  // =========================

  /// Raw event stream from native side (normalized to {event, data}).
  Stream<Map<String, dynamic>> get events {
    _eventStream ??= _eventChannel.receiveBroadcastStream().map<Map<String, dynamic>>((event) {
      if (event is Map) {
        if (event.containsKey('event') && event.containsKey('data')) {
          _log.debug('Received event: ${event['event']}');
          return Map<String, dynamic>.from(event);
        }
        final Map<String, dynamic> m = Map<String, dynamic>.from(event);
        final String eventName = (m['event'] ?? m['type'] ?? m['action'] ?? 'unknown').toString();
        final Map<String, dynamic> data = Map<String, dynamic>.from(m)
          ..remove('event')
          ..remove('type')
          ..remove('action');
        return {'event': eventName, 'data': data};
      }
      return {'event': 'raw', 'data': {'payload': event}};
    });
    return _eventStream!;
  }

  // =========================
  // NEW: Convenience streams
  // =========================

  /// Real-time per-tyre packets during inspection (from native "inspectionLiveData").
  Stream<Map<String, dynamic>> get inspectionLiveData =>
      events.where((e) => e['event'] == 'inspectionLiveData').map((e) {
        return Map<String, dynamic>.from(e['data'] ?? <String, dynamic>{});
      });

  /// Batch of all tyres at once (from native "inspectionAllData").
  /// Emits: { items: List<Map>, count: int }
  Stream<List<Map<String, dynamic>>> get inspectionAllData =>
      events.where((e) => e['event'] == 'inspectionAllData').map((e) {
        final data = Map<String, dynamic>.from(e['data'] ?? <String, dynamic>{});
        final items = (data['items'] as List? ?? const [])
            .map((x) => Map<String, dynamic>.from(x as Map))
            .toList();
        return items;
      });

  /// Back-compat: original per-tyre event name.
  Stream<Map<String, dynamic>> get onDGaugeScanningData =>
      events.where((e) => e['event'] == 'onDGaugeScanningData').map((e) {
        return Map<String, dynamic>.from(e['data'] ?? <String, dynamic>{});
      });

  /// Back-compat: original all-tyres event name.
  Stream<List<Map<String, dynamic>>> get onDGuageAllTreadReadingData =>
      events.where((e) => e['event'] == 'onDGuageAllTreadReadingData').map((e) {
        final data = Map<String, dynamic>.from(e['data'] ?? <String, dynamic>{});
        final items = (data['items'] as List? ?? const [])
            .map((x) => Map<String, dynamic>.from(x as Map))
            .toList();
        return items;
      });

  /// BLE error events (message + errorCode)
  Stream<Map<String, dynamic>> get bleErrors =>
      events.where((e) => e['event'] == 'handleBleException').map((e) {
        return Map<String, dynamic>.from(e['data'] ?? <String, dynamic>{});
      });

  /// Connectivity state/status events
  Stream<Map<String, dynamic>> get connectivityEvents =>
      events.where((e) => e['event'] == 'handleDGaugeConnectivity').map((e) {
        return Map<String, dynamic>.from(e['data'] ?? <String, dynamic>{});
      });
}
