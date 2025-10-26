import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/tyre_configuration.dart';
import '../models/vehicle_configuration.dart';
import 'vehicle_state.dart';

class VehicleCubit extends Cubit<VehicleState> {
  VehicleCubit() : super(const VehicleState());

  /// Load all vehicle configurations
  Future<void> loadAllVehicles() async {
    emit(state.copyWith(status: VehicleStatus.loading));

    try {
      await Future.delayed(const Duration(seconds: 1));

      final vehicles = _getAllMockVehicles();

      emit(state.copyWith(
        status: VehicleStatus.loaded,
        vehicleList: vehicles,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VehicleStatus.error,
        errorMessage: 'Failed to load vehicles: ${e.toString()}',
      ));
    }
  }

  /// Select a vehicle configuration
  void selectVehicle(VehicleConfiguration vehicle) {
    emit(state.copyWith(
      selectedVehicle: vehicle,
      vehicleConfiguration: vehicle,
    ));
  }

  /// Reset state
  void reset() {
    emit(const VehicleState());
  }

  List<VehicleConfiguration> _getAllMockVehicles() {
    return [
      /// 2x2x0 (4 Tyres + 0 Stepney)
      VehicleConfiguration(
        vehicleNumber: "HR55AB1234",
        axleConfiguration: "2x2x0",
        numberOfTyres: 4,
        tyreConfigurations: List.generate(
          4,
          (i) => TyreConfiguration(
            tyreNumber: i + 1,
            tyreStatus: 1,
            treadCount: "3",
            tyreSerialNumber: "H215385292${i + 4}",
            identifier: 1,
            pressureValue: "32",
            temperatureValue: "28",
          ),
        ),
      ),

      /// 2x4x0 (6 Tyres + 0 Stepney)
      VehicleConfiguration(
        vehicleNumber: "HR55CD5678",
        axleConfiguration: "2x4x0",
        numberOfTyres: 6,
        tyreConfigurations: List.generate(
          6,
              (i) => TyreConfiguration(
            tyreNumber: i + 1,
            tyreStatus: 1,
            treadCount: "3",
            tyreSerialNumber: "H215885362${i + 4}",
            identifier: i + 1,
            pressureValue: "31",
            temperatureValue: "27",
          ),
        ),
      ),

      /// 2x4x1 (6 Tyres + 1 Stepney)
      VehicleConfiguration(
        vehicleNumber: "HR55AC7825",
        axleConfiguration: "2x4x1",
        numberOfTyres: 7,
        tyreConfigurations: List.generate(
          7,
              (i) => TyreConfiguration(
            tyreNumber: i + 1,
            tyreStatus: 1,
            treadCount: "3",
            tyreSerialNumber: "H215885362${i + 4}",
            identifier: i + 1,
            pressureValue: "31",
            temperatureValue: "27",
          ),
        ),
      ),

      /// 2x4x4x1 (10 Tyres + 1 Stepney)
      VehicleConfiguration(
        vehicleNumber: "HR55EF9012",
        axleConfiguration: "2x4x4x1",
        numberOfTyres: 11,
        tyreConfigurations: List.generate(
          11,
              (i) => TyreConfiguration(
            tyreNumber: i + 1,
            tyreStatus: 1,
            treadCount: "3",
            tyreSerialNumber: "H215885362${i + 4}",
            identifier: i + 1,
            pressureValue: "31",
            temperatureValue: "27",
          ),
        ),
      ),

      /// 2x4x4x4x2 (16 Tyres + 2 Stepney)
      VehicleConfiguration(
        vehicleNumber: "HR55EF4012",
        axleConfiguration: "2x4x4x4x2",
        numberOfTyres: 16,
        tyreConfigurations: List.generate(
          16,
              (i) => TyreConfiguration(
            tyreNumber: i + 1,
            tyreStatus: 1,
            treadCount: "3",
            tyreSerialNumber: "H215885362${i + 4}",
            identifier: i + 1,
            pressureValue: "31",
            temperatureValue: "27",
          ),
        ),
      ),
    ];
  }
}
