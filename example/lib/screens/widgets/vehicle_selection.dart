import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/vehicle_cubit.dart';
import '../../bloc/vehicle_state.dart';

class VehicleSelection extends StatelessWidget {
  const VehicleSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleCubit, VehicleState>(
      builder: (context, state) {
        return InkWell(
          onTap: () {
            showBottomSheet(
              backgroundColor:
              Theme.of(context).scaffoldBackgroundColor,
              context: context,
              showDragHandle: false,
              enableDrag: true,
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      "Select Vehicle Configuration",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: false,
                        padding: const EdgeInsets.all(12.0),
                        itemCount: state.vehicleList.length,
                        itemBuilder: (context, index) {
                          var vehicle = state.vehicleList[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              side: BorderSide(
                                color: (state.selectedVehicle != null &&
                                    state.selectedVehicle ==
                                        vehicle)
                                    ? Colors.teal
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                  "Axle Configuration: ${vehicle.axleConfiguration}"),
                              subtitle: Text(
                                  "Number of Tyres: ${vehicle.numberOfTyres}"),
                              onTap: () {
                                context
                                    .read<VehicleCubit>()
                                    .selectVehicle(vehicle);
                                Navigator.of(context).pop();
                              },
                            ),
                          );
                        },
                      ),
                    )
                  ],
                );
              },
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey),
            ),
            child: state.selectedVehicle != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Vehicle Number: ${state.selectedVehicle?.vehicleNumber}",
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  "Axle Configuration: ${state.selectedVehicle?.axleConfiguration}",
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  "Number of Tyres: ${state.selectedVehicle?.numberOfTyres}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            )
                : const Text("Select Vehicle Configuration"),
          ),
        );
      },
    );
  }
}
