import 'package:dgauge_flutter_example/bloc/vehicle_cubit.dart';
import 'package:dgauge_flutter_example/bloc/vehicle_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TyreConfigurationsList extends StatelessWidget {
  const TyreConfigurationsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleCubit, VehicleState>(
      builder: (context, state) {
        final _vehicleConfig = state.selectedVehicle;
        return Column(
          children: [
            const Text(
              "Tyre Configuration",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _vehicleConfig?.tyreConfigurations.length,
              itemBuilder: (context, index) {
                final tyre = _vehicleConfig?.tyreConfigurations[index];
                if (tyre == null) return const SizedBox();
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(tyre.tyreNumber.toString()),
                    ),
                    title: Text("Serial: ${tyre.tyreSerialNumber.toString()}"),
                    subtitle: Text(
                      "Tread Count: ${tyre.treadCount}, Pressure: ${tyre.pressureValue}, Temp: ${tyre.temperatureValue}",
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
