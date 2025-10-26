// vehicle_state.dart

import 'package:equatable/equatable.dart';

import '../models/vehicle_configuration.dart';

enum VehicleStatus { initial, loading, loaded, error, updating }

class VehicleState extends Equatable {
  final VehicleStatus status;
  final VehicleConfiguration? vehicleConfiguration;
  final String? errorMessage;
  final List<VehicleConfiguration> vehicleList;
  final VehicleConfiguration? selectedVehicle;

  const VehicleState({
    this.status = VehicleStatus.initial,
    this.vehicleConfiguration,
    this.errorMessage,
    this.vehicleList = const [],
    this.selectedVehicle,
  });

  VehicleState copyWith({
    VehicleStatus? status,
    VehicleConfiguration? vehicleConfiguration,
    String? errorMessage,
    List<VehicleConfiguration>? vehicleList,
    VehicleConfiguration? selectedVehicle,
  }) {
    return VehicleState(
      status: status ?? this.status,
      vehicleConfiguration: vehicleConfiguration ?? this.vehicleConfiguration,
      errorMessage: errorMessage,
      vehicleList: vehicleList ?? this.vehicleList,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
    );
  }

  @override
  List<Object?> get props => [
    status,
    vehicleConfiguration,
    errorMessage,
    vehicleList,
    selectedVehicle,
  ];
}