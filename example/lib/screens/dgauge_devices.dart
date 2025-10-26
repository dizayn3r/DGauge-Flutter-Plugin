import 'package:dgauge_flutter_example/screens/add_dgauge_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dgauge_cubit.dart';
import '../bloc/dgauge_state.dart';
import '../custom_functions.dart';
import '../models/device_model.dart';

class DgaugeDevices extends StatefulWidget {
  const DgaugeDevices({super.key});

  @override
  State<DgaugeDevices> createState() => _DgaugeDevicesState();
}

class _DgaugeDevicesState extends State<DgaugeDevices> {
  @override
  void initState() {
    super.initState();
    context.read<DGaugeCubit>().getDgaugeDevices();
  }

  Future<void> _refreshDevices() async {
    await context.read<DGaugeCubit>().getDgaugeDevices();
  }

  void _confirmDelete(BuildContext context, DGaugeDeviceModel device) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Device"),
        content: Text(
          "Are you sure you want to delete '${device.name ?? 'Unknown'}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context.read<DGaugeCubit>().deleteDevice(device);
              if (context.mounted) {
                showSnackBar(context, "Device deleted successfully!");
              }
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(List<DGaugeDeviceModel> devices) {
    return RefreshIndicator(
      onRefresh: _refreshDevices,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 10),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
            child: ListTile(
              title: Text(device.name ?? "Unnamed Device"),
              subtitle: Text(device.macAddress ?? "No MAC Address"),
              leading: const Icon(Icons.bluetooth, color: Colors.blueAccent),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context, device),
              ),
              onTap: () {
                // Optionally mark as selected or connect
                context.read<DGaugeCubit>().setSelectedDevice(device);
                showSnackBar(context, "Selected ${device.name ?? "Device"}");
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _refreshDevices,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DGauge Devices"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDevices,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddDgaugeDevice()),
          );
          // Refresh after returning from Add screen
          if (context.mounted) {
            _refreshDevices();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<DGaugeCubit, DGaugeState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            showSnackBar(context, state.errorMessage!, isError: true);
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            return _buildError(state.errorMessage!);
          }

          if (state.dgaugeDevices.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshDevices,
              child: ListView(
                children: const [
                  SizedBox(height: 300),
                  Center(
                    child: Text(
                      "No DGauge devices found.\nTap '+' to add one.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          return _buildDeviceList(state.dgaugeDevices);
        },
      ),
    );
  }
}
