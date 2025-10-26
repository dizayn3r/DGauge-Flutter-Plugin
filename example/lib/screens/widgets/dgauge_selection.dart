import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/dgauge_cubit.dart';
import '../../bloc/dgauge_state.dart';
import '../../custom_functions.dart';

class DGaugeSelection extends StatelessWidget {
  const DGaugeSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DGaugeCubit, DGaugeState>(
      builder: (context, state) {
        return Column(
          children: [
            InkWell(
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
                          "Select DGauge Device",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: false,
                            padding: const EdgeInsets.all(12.0),
                            itemCount: state.dgaugeDevices.length,
                            itemBuilder: (context, index) {
                              var device = state.dgaugeDevices[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12.0),
                                  side: BorderSide(
                                    color:
                                    (state.selectedDevice != null &&
                                        state.selectedDevice ==
                                            device)
                                        ? Colors.teal
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(device.name ?? "NA"),
                                  subtitle:
                                  Text(device.macAddress ?? "NA"),
                                  onTap: () {
                                    context
                                        .read<DGaugeCubit>()
                                        .setSelectedDevice(device);
                                    Navigator.of(context).pop();
                                  },
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      context
                                          .read<DGaugeCubit>()
                                          .deleteDevice(device);
                                      showSnackBar(context,
                                          "Device deleted successfully!");
                                    },
                                  ),
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
                child: state.selectedDevice != null
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${state.selectedDevice?.name}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "${state.selectedDevice?.macAddress}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                )
                    : const Text("Select DGauge Device"),
              ),
            ),
          ],
        );
      },
    );
  }
}
