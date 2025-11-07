import 'dart:developer';

import 'package:dgauge_flutter_example/bloc/vehicle_cubit.dart';
import 'package:dgauge_flutter_example/bloc/vehicle_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dgauge_cubit.dart';
import '../bloc/dgauge_state.dart';
import '../custom_functions.dart';
import '../models/vehicle_configuration.dart';
import '../models/tread_reading.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DGaugeCubit>().initialize();
    context.read<VehicleCubit>().loadAllVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vehicle Configuration")),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              _TyreConfigPane(),
              _ReadingsPane(),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------------------
/// LEFT: Vehicle & Tyre Config
/// ------------------------------
class _TyreConfigPane extends StatelessWidget {
  const _TyreConfigPane();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleCubit, VehicleState>(
      builder: (context, vState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vehicle picker
            InkWell(
              onTap: () => _showVehiclePicker(context, vState),
              child: _boxed(
                context,
                child: vState.selectedVehicle != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _kv("Vehicle Number",
                              vState.selectedVehicle?.vehicleNumber),
                          _kv("Axle Config",
                              vState.selectedVehicle?.axleConfiguration),
                          _kv("Tyres",
                              "${vState.selectedVehicle?.numberOfTyres}"),
                        ],
                      )
                    : const Text("Select Vehicle Configuration"),
              ),
            ),
            const SizedBox(height: 16),

            // Tyre configuration grid (from selected vehicle) + color by reading status
            if (vState.selectedVehicle != null)
              _TyreLayoutPreview(config: vState.selectedVehicle!),
            if (vState.selectedVehicle != null) const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  static void _showVehiclePicker(BuildContext context, VehicleState state) {
    showBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      showDragHandle: false,
      enableDrag: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Text("Select Vehicle Configuration",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: state.vehicleList.length,
                  itemBuilder: (context, index) {
                    final vehicle = state.vehicleList[index];
                    final selected = state.selectedVehicle == vehicle;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(
                          color: selected ? Colors.teal : Colors.grey.shade300,
                        ),
                      ),
                      child: ListTile(
                        title: Text("Axle: ${vehicle.axleConfiguration}"),
                        subtitle: Text("Tyres: ${vehicle.numberOfTyres}"),
                        onTap: () {
                          context.read<VehicleCubit>().selectVehicle(vehicle);
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

/// Tyre grid that reflects reading status (green when completed) and is tappable.
class _TyreLayoutPreview extends StatelessWidget {
  final VehicleConfiguration config;

  const _TyreLayoutPreview({required this.config});

  @override
  Widget build(BuildContext context) {
    final total = config.numberOfTyres;

    return _boxed(
      context,
      title: "Tyre Configuration",
      child: BlocBuilder<DGaugeCubit, DGaugeState>(
        builder: (context, dState) {
          // Build a quick lookup of latest reading per tyre
          final Map<int, TreadReading> latestByTyre = {};

          // prefer batch readings
          for (final r in dState.allReadings) {
            latestByTyre[r.tireNumber] = r;
          }
          // override with the latest live packet if present
          final lr = dState.lastReading;
          if (lr != null) latestByTyre[lr.tireNumber] = lr;

          return GridView.builder(
            shrinkWrap: true,
            primary: false,
            itemCount: total,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // tweak as needed / make responsive
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (_, i) {
              final tyreNo = i + 1;
              final reading = latestByTyre[tyreNo];

              // Completed if SDK says status == 2
              final bool isCompleted = (reading?.treadReadingStatus == 2);

              return InkWell(
                onTap: () {
                  if (reading == null) {
                    showSnackBar(_, "No reading yet for Tyre $tyreNo");
                    return;
                  }
                  _showReadingSheet(context, reading);
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green.shade100 : Colors.white,
                    border: Border.all(
                      color: isCompleted ? Colors.green : Colors.grey.shade400,
                      width: isCompleted ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (isCompleted)
                        BoxShadow(
                          color: Colors.green.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "Tyre $tyreNo",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (reading == null)
                        const Flexible(
                          child: Text(
                            "-",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            _miniStat("P", reading.pressureValue ?? "-"),
                            _miniStat("T", reading.temperatureValue ?? "-"),
                          ],
                        ),
                      // const SizedBox(height: 8),
                      // if (isCompleted)
                      //   const Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       Icon(
                      //         Icons.check_circle,
                      //         size: 16,
                      //         color: Colors.green,
                      //       ),
                      //       SizedBox(width: 6),
                      //       Text(
                      //         "Completed",
                      //         style: TextStyle(
                      //             color: Colors.green,
                      //             fontWeight: FontWeight.w600),
                      //       ),
                      //     ],
                      //   )
                      // else
                      //   const Text(
                      //     "Pending",
                      //     style: TextStyle(color: Colors.grey, fontSize: 12),
                      //   ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _miniStat(String k, String v) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text("$k: $v", style: const TextStyle(fontSize: 12)),
    );
  }

  void _showReadingSheet(BuildContext context, TreadReading reading) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      showDragHandle: true,
      builder: (ctx) {
        log("Tyre Number: ${reading.toMap()}");
        String d(double? v) => v == null ? "-" : v.toStringAsFixed(1);
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            runSpacing: 8,
            children: [
              Row(
                children: [
                  Text("Tyre #${reading.tireNumber}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Chip(
                    label: Text(
                      reading.treadReadingStatus == 2
                          ? "Completed"
                          : "In Progress",
                    ),
                    backgroundColor: reading.treadReadingStatus == 2
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                  ),
                ],
              ),
              const Divider(),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _kv("Pressure", reading.pressureValue ?? "-"),
                  _kv("Temperature", reading.temperatureValue ?? "-"),
                  _kv("Depth 1", d(reading.treadDepth1)),
                  _kv("Depth 2", d(reading.treadDepth2)),
                  _kv("Depth 3", d(reading.treadDepth3)),
                  _kv("Depth 4", d(reading.treadDepth4)),
                  _kv("Avg", d(reading.avgTreadDepth)),
                  _kv("Min", d(reading.minTreadDepth)),
                  _kv("Max", d(reading.maxTreadDepth)),
                  _kv("Identifier", reading.identifier ?? "-"),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

/// ------------------------------
/// RIGHT: Device & Readings
/// ------------------------------
class _ReadingsPane extends StatelessWidget {
  const _ReadingsPane();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DGaugeCubit, DGaugeState>(
      builder: (context, dState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Device picker
            InkWell(
              onTap: () => _showDevicePicker(context, dState),
              child: _boxed(
                context,
                child: dState.selectedDevice != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _kv("Device", dState.selectedDevice?.name),
                          _kv("MAC", dState.selectedDevice?.macAddress),
                        ],
                      )
                    : const Text("Select DGauge Device"),
              ),
            ),
            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.sync),
                    onPressed: dState.selectedDevice == null
                        ? null
                        : () {
                            final vState = context.read<VehicleCubit>().state;
                            final cfg = vState.selectedVehicle;
                            if (cfg == null) {
                              showSnackBar(context, "Please select a vehicle");
                              return;
                            }
                            context
                                .read<DGaugeCubit>()
                                .syncVehicleConfiguration(
                                  dState.selectedDevice!.macAddress.toString(),
                                  cfg,
                                );
                          },
                    label: const Text("Sync Config"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: dState.selectedDevice == null
                        ? null
                        : () {
                            context.read<DGaugeCubit>().startTireInspection(
                                  dState.selectedDevice!.macAddress.toString(),
                                );
                          },
                    child: const Text("Start Inspection (Live)"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: dState.selectedDevice == null
                        ? null
                        : () {
                            context.read<DGaugeCubit>().fetchAllTireData(
                                  dState.selectedDevice!.macAddress.toString(),
                                );
                          },
                    child: const Text("Fetch All (Batch via Events)"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: dState.selectedDevice == null
                        ? null
                        : () async {
                            final mac = dState.selectedDevice!.macAddress!;
                            final one = await context
                                .read<DGaugeCubit>()
                                .readTreadDepthOnce(mac);
                            if (one != null) {
                              showSnackBar(context,
                                  "One-shot read: Tyre ${one['tireNumber']}");
                            }
                          },
                    child: const Text("One-shot Read"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Live reading card
            _boxed(
              context,
              title: "Live Reading",
              child: _LiveReadingView(reading: dState.lastReading),
            ),

            const SizedBox(height: 16),

            // Batch table
            _boxed(
              context,
              title: "All Tyre Readings (Last Batch)",
              child: _ReadingTable(items: dState.allReadings),
            ),
          ],
        );
      },
    );
  }

  static void _showDevicePicker(BuildContext context, DGaugeState state) {
    showBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      showDragHandle: false,
      enableDrag: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Text("Select DGauge Device",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const Divider(),
              Expanded(
                child: BlocBuilder<DGaugeCubit, DGaugeState>(
                  builder: (context, dState) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(12.0),
                      itemCount: dState.dgaugeDevices.length,
                      itemBuilder: (context, index) {
                        final device = dState.dgaugeDevices[index];
                        final selected = dState.selectedDevice == device;
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                              color:
                                  selected ? Colors.teal : Colors.grey.shade300,
                            ),
                          ),
                          child: ListTile(
                            title: Text(device.name ?? "NA"),
                            subtitle: Text(device.macAddress ?? "NA"),
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
                                showSnackBar(
                                    context, "Device deleted successfully!");
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ------------------------------
/// Widgets
/// ------------------------------
Widget _boxed(BuildContext context, {Widget? child, String? title}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      border: Border.all(color: Colors.grey.shade400),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 12),
        ],
        if (child != null) child,
      ],
    ),
  );
}

Widget _kv(String key, String? value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6.0),
    child: Row(
      children: [
        SizedBox(
            width: 140,
            child: Text("$key:",
                style: const TextStyle(fontWeight: FontWeight.w600))),
        Expanded(child: Text(value ?? "NA")),
      ],
    ),
  );
}

/// Live reading compact card
class _LiveReadingView extends StatelessWidget {
  final TreadReading? reading;

  const _LiveReadingView({required this.reading});

  @override
  Widget build(BuildContext context) {
    if (reading == null) {
      return const Text(
          "No live reading yet. Start inspection or use One-shot Read.");
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(spacing: 16, runSpacing: 8, children: [
          _chip("Tyre", "#${reading!.tireNumber}"),
          _chip("Pressure", reading!.pressureValue ?? "-"),
          _chip("Temp", reading!.temperatureValue ?? "-"),
          _chip(
            "Depths",
            reading!.treadDepths.isNotEmpty
                ? reading!.treadDepths
                    .map((e) => e.toStringAsFixed(1))
                    .join(", ")
                : _depthsInline(reading!),
          ),
          if (reading!.avgTreadDepth != null)
            _chip("Avg", reading!.avgTreadDepth!.toStringAsFixed(1)),
          if (reading!.minTreadDepth != null)
            _chip("Min", reading!.minTreadDepth!.toStringAsFixed(1)),
          if (reading!.maxTreadDepth != null)
            _chip("Max", reading!.maxTreadDepth!.toStringAsFixed(1)),
        ]),
      ],
    );
  }

  String _depthsInline(TreadReading r) {
    final vals = [
      if (r.treadDepth1 != null) r.treadDepth1!.toStringAsFixed(1),
      if (r.treadDepth2 != null) r.treadDepth2!.toStringAsFixed(1),
      if (r.treadDepth3 != null) r.treadDepth3!.toStringAsFixed(1),
      if (r.treadDepth4 != null) r.treadDepth4!.toStringAsFixed(1),
    ];
    return vals.isEmpty ? "-" : vals.join(", ");
  }

  Widget _chip(String label, String value) {
    return Chip(
      label: Text("$label: $value"),
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Table for batch readings
class _ReadingTable extends StatelessWidget {
  final List<TreadReading> items;

  const _ReadingTable({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text(
          "No batch data yet. Use Fetch All or complete an inspection.");
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Tyre #")),
          DataColumn(label: Text("Pressure")),
          DataColumn(label: Text("Temp")),
          DataColumn(label: Text("Depth1")),
          DataColumn(label: Text("Depth2")),
          DataColumn(label: Text("Depth3")),
          DataColumn(label: Text("Depth4")),
          DataColumn(label: Text("Avg")),
          DataColumn(label: Text("Min")),
          DataColumn(label: Text("Max")),
          DataColumn(label: Text("Status")),
        ],
        rows: items.map((r) {
          String d(double? v) => v == null ? "-" : v.toStringAsFixed(1);
          return DataRow(cells: [
            DataCell(Text("#${r.tireNumber}")),
            DataCell(Text(r.pressureValue ?? "-")),
            DataCell(Text(r.temperatureValue ?? "-")),
            DataCell(Text(d(r.treadDepth1))),
            DataCell(Text(d(r.treadDepth2))),
            DataCell(Text(d(r.treadDepth3))),
            DataCell(Text(d(r.treadDepth4))),
            DataCell(Text(d(r.avgTreadDepth))),
            DataCell(Text(d(r.minTreadDepth))),
            DataCell(Text(d(r.maxTreadDepth))),
            DataCell(
              Row(
                children: [
                  Icon(
                    r.treadReadingStatus == 2
                        ? Icons.check_circle
                        : Icons.timelapse,
                    size: 16,
                    color: r.treadReadingStatus == 2
                        ? Colors.green
                        : Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(r.treadReadingStatus == 2 ? "Completed" : "In Progress"),
                ],
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }
}
