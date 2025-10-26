import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../enum/dgauge_status.dart';
import '../local_storage_helpers.dart';
import '../models/device_model.dart';
import '../bloc/dgauge_state.dart';
import '../models/tread_reading.dart';
import '../models/vehicle_configuration.dart';
import '../services/logger_service.dart';
import 'package:dgauge_flutter/dgauge_flutter.dart';

/// DGaugeCubit: coordinates UI, local storage and DGauge plugin events/commands.
class DGaugeCubit extends Cubit<DGaugeState> {
  final DGaugeFlutter _sdk;
  StreamSubscription<Map<String, dynamic>>? _eventSubscription;

  // Create a tagged logger for this class
  final _log = LoggerService.tagged('DGaugeCubit');

  // Pending config for deferred sync
  VehicleConfiguration? _pendingVehicleConfig;
  String? _pendingMacForConfig;

  DGaugeCubit(this._sdk) : super(const DGaugeState());

  // --- utils ---
  String _sanitizeMac(String mac) =>
      mac.replaceAll(RegExp(r'[^A-Fa-f0-9]'), '').toUpperCase();

  /// Subscribe to plugin events. Call this once when the app starts (or on demand).
  void listenToPluginEvents() {
    // Avoid multiple subscriptions
    if (_eventSubscription != null) return;

    _eventSubscription = _sdk.events.listen((event) {
      try {
        // Expecting event shape: { "event": "<name>", "data": { ... } }
        final String eventName = event['event']?.toString() ?? 'unknown';
        final dynamic data = event['data'];

        _log.info('DGauge event: $eventName -> $data');

        switch (eventName) {
          case 'handleBleException':
            _handleBleException(data);
            break;

          case 'handleDGaugeConnectivity':
            _handleConnectivity(data);
            break;

          case 'onSyncConfigurationResponse':
            _handleSyncResponse(data);
            break;

          case 'onDGuageTreadReadingStatus':
            _handleReadingStatus(data);
            break;

        // Back-compat (existing)
          case 'onDGaugeScanningData':
            _handleSingleTreadData(data);
            break;
          case 'onDGuageAllTreadReadingData':
            _handleAllTreadData(data);
            break;

        // NEW: clearer event names from the updated plugin
          case 'inspectionLiveData':
            _handleSingleTreadData(data);
            break;
          case 'inspectionAllData':
          // data = { items: List<Map>, count: int }
            final map = (data is Map) ? Map<String, dynamic>.from(data) : <String, dynamic>{};
            _handleAllTreadData({'items': map['items'] ?? const []});
            break;

          default:
            _log.warning('Unhandled DGauge event: $eventName -> $data');
        }
      } catch (e, s) {
        _log.error('Error processing DGauge event', error: e, stackTrace: s);
      }
    }, onError: (err, stack) {
      _log.error('DGauge events stream error', error: err, stackTrace: stack);
    });
  }

  // -----------------------
  // Event handlers
  // -----------------------

  void _handleBleException(dynamic data) {
    try {
      final msg = (data is Map) ? (data['message']?.toString() ?? '') : '';
      final code = (data is Map) ? data['errorCode'] : null;

      _log.error('BLE exception: code=$code, msg=$msg');

      if (code == 2147483646) {
        Fluttertoast.showToast(
          msg: 'Connection limit reached. Try again after 30 seconds.',
        );
      } else {
        Fluttertoast.showToast(msg: msg.isNotEmpty ? msg : 'BLE error: ${code ?? 'unknown'}');
      }
    } catch (e, s) {
      _log.error('Error in _handleBleException', error: e, stackTrace: s);
    }
  }

  void _handleConnectivity(dynamic data) {
    _log.debug('DGauge Connectivity raw data: $data');

    try {
      if (data is! Map) {
        _log.warning('Invalid connectivity data format: $data');
        return;
      }

      final response = data['response'];
      final status = (data['status']?.toString().trim().toUpperCase() ?? '');
      final message = (data['userMessage']?.toString() ?? '').trim();

      _log.info('Connectivity event - response: $response, status: $status, message: $message');

      // --- Text-based status handling ---
      if (status.contains("CONNECTING")) {
        _log.debug('Status: CONNECTING_TO_DGAUGE');
        Fluttertoast.showToast(msg: "Connecting to DGauge...");
        return;
      }

      if (status.contains("CONNECTED")) {
        _log.info('Status: CONNECTED_DGAUGE');
        Fluttertoast.showToast(msg: "✅ Connected to DGauge");
        emit(state.copyWith(status: DGaugeStatus.connected));
        return;
      }

      if (status.contains("DISCONNECTED") || status.contains("DISCONNECT")) {
        _log.warning('Status: DISCONNECTED_DGAUGE');
        Fluttertoast.showToast(msg: "⚠️ Disconnected from DGauge");
        emit(state.copyWith(status: DGaugeStatus.disconnected));
        return;
      }

      if (status.contains("FAILED")) {
        _log.error('Status: CONNECTION_FAILED');
        emit(state.copyWith(status: DGaugeStatus.failed));
        Fluttertoast.showToast(msg: "❌ Connection failed. Please retry.");
        return;
      }

      if (status.contains("TIMEOUT") || status.contains("TIMED")) {
        _log.warning('Status: CONNECTION_TIMEOUT');
        Fluttertoast.showToast(msg: "⏳ Connection timed out.");
        return;
      }

      if (status.contains("INVALID") && status.contains("MAC")) {
        _log.warning('Status: INVALID_MAC_ADDRESS');
        Fluttertoast.showToast(msg: "❌ Invalid MAC address");
        return;
      }

      if (status.contains("SCANNING")) {
        _log.debug('Status: SCANNING_IN_PROGRESS');
        Fluttertoast.showToast(msg: "🔍 Scanning for DGauge...");
        return;
      }

      if (status.contains("STOP")) {
        _log.debug('Status: SCANNING_STOP');
        Fluttertoast.showToast(msg: "Scan stopped.");
        return;
      }

      if (status.contains("CONFIG") || status.contains("SYNC")) {
        _log.info('Status: CUSTOM_MESSAGE');
        Fluttertoast.showToast(msg: message.isNotEmpty ? message : "DGauge status updated.");
        return;
      }

      // --- Numeric response fallback ---
      if (response is num) {
        switch (response.toInt()) {
          case 0:
            _log.debug('Status: IDLE / NO CONNECTION');
            Fluttertoast.showToast(msg: "DGauge idle or disconnected.");
            break;
          case 1:
            _log.info('Status: CONNECTED');
            Fluttertoast.showToast(msg: "✅ Connected to DGauge");
            break;
          case 2:
            _log.debug('Status: CONNECTING');
            Fluttertoast.showToast(msg: "Connecting to DGauge...");
            break;
          case 3:
            _log.error('Status: FAILED');
            Fluttertoast.showToast(msg: "❌ Connection failed");
            break;
          case 4:
            _log.info('Status: CONNECTED');
            Fluttertoast.showToast(msg: "✅ Connected (code 4)");
            break;
          case 6:
            _log.info('Status: SAVED_CONFIG');
            Fluttertoast.showToast(msg: "✅ Configuration saved");
            break;
          case 8:
            _log.info('Status: FACTORY_SETTINGS_READ');
            Fluttertoast.showToast(msg: "✅ Read factory settings");
            break;
          case 9:
            _log.error('Status: INVALID_MAC_ADDRESS');
            Fluttertoast.showToast(msg: "❌ Enter valid MAC address");
            break;
          default:
            _log.warning('Status: UNKNOWN_CODE_$response');
            Fluttertoast.showToast(msg: "DGauge status code: $response");
        }
        return;
      }

      _log.warning('Unhandled connectivity data format: $data');
    } catch (e, s) {
      _log.error('Error in _handleConnectivity', error: e, stackTrace: s);
    }
  }

  void _handleSyncResponse(dynamic data) {
    try {
      if (data is! Map) {
        _log.warning('Invalid sync response format: $data');
        return;
      }

      final success = data['success'] == true;
      final message = data['message']?.toString() ?? '';
      final errorCode = data['errorCode'];

      _log.info('Sync response - success: $success, message: $message, errorCode: $errorCode');

      if (!success) {
        // Handle "in progress" specifically
        if (message.toLowerCase().contains("inprogress")) {
          _log.warning('Sync already in progress on device');
          Fluttertoast.showToast(msg: "🔄 Device is still syncing, please wait...");
          emit(state.copyWith(status: DGaugeStatus.syncInProgress));
          return;
        }

        // Handle general sync failure
        _log.error('Sync failed: $message');
        Fluttertoast.showToast(msg: "❌ Sync failed: $message");
        emit(state.copyWith(status: DGaugeStatus.syncFailed));
        return;
      }

      // Success case
      _log.info('✅ Vehicle configuration synced successfully');
      Fluttertoast.showToast(msg: "✅ Vehicle configuration synced");
      emit(state.copyWith(status: DGaugeStatus.synced));
    } catch (e, s) {
      _log.error('Error in _handleSyncResponse', error: e, stackTrace: s);
      Fluttertoast.showToast(msg: "❌ Unexpected error during sync");
      emit(state.copyWith(status: DGaugeStatus.syncFailed));
    }
  }

  void _handleReadingStatus(dynamic data) {
    try {
      final status = (data is Map) ? data['status'] : data;
      _log.debug('Reading status: $status');
    } catch (e, s) {
      _log.error('Error in _handleReadingStatus', error: e, stackTrace: s);
    }
  }

  void _handleSingleTreadData(dynamic data) {
    try {
      _log.debug('Single tread data received: $data');
      final reading = TreadReading.fromMap(Map<String, dynamic>.from(data));
      emit(state.copyWith(lastReading: reading));
    } catch (e, s) {
      _log.error('Error in _handleSingleTreadData', error: e, stackTrace: s);
    }
  }

  void _handleAllTreadData(dynamic data) {
    try {
      _log.debug('All tread data received: $data');
      final list = (Map<String, dynamic>.from(data)['items'] as List)
          .map((e) => TreadReading.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      emit(state.copyWith(allReadings: list));
    } catch (e, s) {
      _log.error('Error in _handleAllTreadData', error: e, stackTrace: s);
    }
  }

  // -----------------------
  // Public API
  // -----------------------

  /// Initialize the Dgauge SDK
  Future<void> initialize() async {
    _log.info('Initializing DGauge SDK...');
    await _sdk.initialize();
    // Start listening to events (de-duplicated in listenToPluginEvents)
    listenToPluginEvents();
    _log.info('DGauge SDK initialized successfully');
  }

  /// Save a new DGauge device to local storage (stringified JSON list)
  Future<String?> saveDgaugeDevice(DGaugeDeviceModel device) async {
    _log.debug('Attempting to save device: ${device.name} (${device.macAddress})');
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      DGaugeDeviceModel? existingDevice;
      try {
        existingDevice = state.dgaugeDevices.firstWhere(
              (e) =>
          (e.name?.toLowerCase() == device.name?.toLowerCase()) ||
              (e.macAddress == device.macAddress),
        );
      } on StateError {
        existingDevice = null;
      }

      if (existingDevice != null) {
        _log.warning('Device already exists: ${device.name}');
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: "Device already exists",
          ),
        );
        return "Device already exists";
      }

      final allDevices = List<DGaugeDeviceModel>.from(state.dgaugeDevices)
        ..add(device);

      final jsonList = allDevices.map((d) => d.toJson()).toList(growable: false);

      await UserSimplePreferences.saveDgaugeDevice(jsonEncode(jsonList));

      _log.info('Device saved successfully: ${device.name}');

      emit(
        state.copyWith(
          isLoading: false,
          dgaugeDevices: allDevices,
          errorMessage: null,
        ),
      );

      return "Device added successfully";
    } catch (e, s) {
      _log.error('Error saving device', error: e, stackTrace: s);
      emit(
        state.copyWith(isLoading: false, errorMessage: "Failed to save device: $e"),
      );
      return "Failed to save device";
    }
  }

  /// Delete a device
  Future<void> deleteDevice(DGaugeDeviceModel device) async {
    _log.debug('Attempting to delete device: ${device.name} (${device.macAddress})');
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final devices = List<DGaugeDeviceModel>.from(state.dgaugeDevices);
      devices.removeWhere(
              (d) => d.macAddress == device.macAddress && d.name == device.name);

      final jsonList = devices.map((d) => d.toJson()).toList(growable: false);
      await UserSimplePreferences.saveDgaugeDevice(jsonEncode(jsonList));

      _log.info('Device deleted successfully: ${device.name}');

      emit(state.copyWith(
        isLoading: false,
        dgaugeDevices: devices,
        errorMessage: null,
      ));
    } catch (e, s) {
      _log.error('Failed to delete device', error: e, stackTrace: s);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: "Failed to delete device: $e",
      ));
    } finally {
      getDgaugeDevices();
    }
  }

  /// Load devices from local storage
  Future<void> getDgaugeDevices() async {
    _log.info('🔵 Loading DGauge devices from storage...');
    emit(state.copyWith(isLoading: true, errorMessage: null));

    // short delay to allow UI to show loading spinner properly
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final stored = await UserSimplePreferences.getDgaugeDevices();
      if (stored == null) {
        _log.debug('No stored devices found');
        emit(state.copyWith(isLoading: false, dgaugeDevices: [], errorMessage: null));
        return;
      }

      // stored expected to be List<dynamic> representing JSON-decoded objects
      final List<DGaugeDeviceModel> loadedDevices = (stored as List)
          .map<DGaugeDeviceModel>((d) => DGaugeDeviceModel.fromJson(d))
          .toList();

      _log.info('Loaded ${loadedDevices.length} devices from storage');

      emit(state.copyWith(isLoading: false, dgaugeDevices: loadedDevices, errorMessage: null));
    } catch (e, s) {
      _log.error('Error loading devices', error: e, stackTrace: s);
      emit(state.copyWith(isLoading: false, errorMessage: "Failed to load DGauge devices: $e"));
    }
  }

  Future<void> connectDGauge(String macAddress) async {
    final mac = _sanitizeMac(macAddress);
    _log.info('Connecting to DGauge: $mac');
    try {
      await _sdk.connectDGauge(macAddress: mac);
      _log.info('Connect command sent for: $mac');
    } catch (e, s) {
      _log.error('Error connecting DGauge', error: e, stackTrace: s);
    }
  }

  Future<void> disconnectDGauge(String macAddress) async {
    final mac = _sanitizeMac(macAddress);
    _log.info('Disconnecting from DGauge: $mac');
    try {
      await _sdk.disconnectDGauge(macAddress: mac);
      _log.info('Disconnect command sent for: $mac');
    } catch (e, s) {
      _log.error('Error disconnecting DGauge', error: e, stackTrace: s);
    }
  }

  /// Set the currently selected device
  void setSelectedDevice(DGaugeDeviceModel? device) {
    _log.debug('Selected device: ${device?.name ?? "None"}');
    emit(state.copyWith(selectedDevice: device));
  }

  /// Sync Vehicle Configuration with the selected DGauge device
  Future<void> syncVehicleConfiguration(
      String macAddress,
      VehicleConfiguration vehicleConfiguration,
      ) async {
    if (state.status == DGaugeStatus.syncInProgress) {
      _log.warning('Sync already in progress, skipping duplicate request');
      Fluttertoast.showToast(msg: "🔄 Sync already in progress...");
      return;
    }

    final sanitizedMac = _sanitizeMac(macAddress);
    _log.info('Syncing vehicle configuration to: $sanitizedMac');

    if (vehicleConfiguration.tyreConfigurations.isEmpty) {
      _log.warning('No tyre configurations provided');
      Fluttertoast.showToast(msg: "Tyre configuration is empty");
      return;
    }

    emit(state.copyWith(status: DGaugeStatus.syncInProgress));

    try {
      await _sdk.sendVehicleConfiguration(
        macAddress: sanitizedMac,
        vehicleConfig: vehicleConfiguration.toMap(),
      );

      _log.info('Vehicle configuration sent successfully');
      Fluttertoast.showToast(msg: "✅ Vehicle configuration sent");
      emit(state.copyWith(status: DGaugeStatus.synced));
    } catch (e, s) {
      _log.error('Error in syncVehicleConfiguration', error: e, stackTrace: s);
      Fluttertoast.showToast(msg: "❌ Failed to sync configuration");
      emit(state.copyWith(status: DGaugeStatus.syncFailed));
    }
  }

  /// Request single tyre inspection (streaming updates via events)
  Future<void> startTireInspection(String macAddress) async {
    final mac = _sanitizeMac(macAddress);
    _log.info('Starting tire inspection for: $mac');
    try {
      await _sdk.startTireInspection(macAddress: mac);
      Fluttertoast.showToast(msg: "Requested tire inspection");
      _log.info('Tire inspection request sent');
    } catch (e, s) {
      _log.error('Error in startTireInspection', error: e, stackTrace: s);
      Fluttertoast.showToast(msg: "Failed to start inspection");
    }
  }

  /// Request all tyre data (batch via events)
  Future<void> fetchAllTireData(String macAddress) async {
    final mac = _sanitizeMac(macAddress);
    _log.info('Fetching all tire data for: $mac');
    try {
      await _sdk.fetchAllTireData(macAddress: mac);
      Fluttertoast.showToast(msg: "Requested fetch all tyre data");
      _log.info('Fetch all tire data request sent');
    } catch (e, s) {
      _log.error('Error in fetchAllTireData', error: e, stackTrace: s);
      Fluttertoast.showToast(msg: "Failed to fetch all tyre data");
    }
  }

  // =========================
  // NEW: Awaitable reads
  // =========================

  /// Await the first live packet that arrives after the call.
  Future<Map<String, dynamic>?> readTreadDepthOnce(
      String macAddress, {
        int timeoutMs = 12000,
      }) async {
    final mac = _sanitizeMac(macAddress);
    _log.info('One-shot read request for: $mac');
    try {
      final res = await _sdk.readTreadDepthOnce(macAddress: mac, timeoutMs: timeoutMs);
      _log.info('One-shot read result: $res');
      return res;
    } catch (e, s) {
      _log.error('readTreadDepthOnce failed', error: e, stackTrace: s);
      Fluttertoast.showToast(msg: "Failed to read tread depth");
      rethrow;
    }
  }

  /// Await the full list of tyres (batch).
  Future<List<Map<String, dynamic>>> readAllTreadDepths(
      String macAddress, {
        int timeoutMs = 20000,
      }) async {
    final mac = _sanitizeMac(macAddress);
    _log.info('All-tyres read request for: $mac');
    try {
      final res = await _sdk.readAllTreadDepths(macAddress: mac, timeoutMs: timeoutMs);
      _log.info('All-tyres read result: ${res.length} items');
      return res;
    } catch (e, s) {
      _log.error('readAllTreadDepths failed', error: e, stackTrace: s);
      Fluttertoast.showToast(msg: "Failed to read all tyres");
      rethrow;
    }
  }

  // -----------------------
  // Cleanup
  // -----------------------

  @override
  Future<void> close() {
    _log.info('Closing DGaugeCubit and cancelling subscriptions');
    _eventSubscription?.cancel();
    _eventSubscription = null;
    return super.close();
  }
}
