import 'package:equatable/equatable.dart';
import '../enum/dgauge_status.dart';
import '../models/device_model.dart';
import '../models/tread_reading.dart'; // <-- add

class DGaugeState extends Equatable {
  final bool isLoading;
  final List<DGaugeDeviceModel> dgaugeDevices;
  final DGaugeDeviceModel? selectedDevice;
  final String? errorMessage;
  final DGaugeStatus status;

  // NEW:
  final TreadReading? lastReading;           // most recent per-tyre packet
  final List<TreadReading> allReadings;      // last batch result

  const DGaugeState({
    this.isLoading = false,
    this.dgaugeDevices = const [],
    this.selectedDevice,
    this.errorMessage,
    this.status = DGaugeStatus.idle,
    this.lastReading,
    this.allReadings = const [],
  });

  DGaugeState copyWith({
    bool? isLoading,
    List<DGaugeDeviceModel>? dgaugeDevices,
    DGaugeDeviceModel? selectedDevice,
    String? errorMessage,
    DGaugeStatus? status,
    TreadReading? lastReading,
    List<TreadReading>? allReadings,
  }) {
    return DGaugeState(
      isLoading: isLoading ?? this.isLoading,
      dgaugeDevices: dgaugeDevices ?? this.dgaugeDevices,
      selectedDevice: selectedDevice ?? (selectedDevice ?? this.selectedDevice),
      errorMessage: errorMessage,
      status: status ?? this.status,
      lastReading: lastReading ?? this.lastReading,
      allReadings: allReadings ?? this.allReadings,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    dgaugeDevices,
    selectedDevice,
    errorMessage,
    status,
    lastReading,
    allReadings,
  ];
}
