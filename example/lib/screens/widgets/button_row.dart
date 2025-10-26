import 'package:dgauge_flutter_example/bloc/dgauge_cubit.dart';
import 'package:dgauge_flutter_example/bloc/dgauge_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../custom_functions.dart';

class ButtonRow extends StatelessWidget {
  const ButtonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DGaugeCubit, DGaugeState>(
      builder: (context, state) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.bluetooth, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600),
                    onPressed: state.selectedDevice == null
                        ? null
                        : () async {
                            final mac =
                                state.selectedDevice?.macAddress ?? "Unknown";
                            await context
                                .read<DGaugeCubit>()
                                .connectDGauge(mac);
                            showSnackBar(context, "Connected $mac");
                          },
                    label: const Text(
                      "DGauge",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.bluetooth_disabled,
                        color: Colors.white),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600),
                    onPressed: state.selectedDevice == null
                        ? null
                        : () async {
                            final mac =
                                state.selectedDevice?.macAddress ?? "Unknown";
                            await context
                                .read<DGaugeCubit>()
                                .disconnectDGauge(mac);
                            showSnackBar(context, "Disconnected $mac");
                          },
                    label: const Text(
                      "DGauge",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
