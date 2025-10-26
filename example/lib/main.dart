// lib/main.dart
import 'dart:io';

import 'package:dgauge_flutter/dgauge_flutter.dart';
import 'package:dgauge_flutter_example/bloc/vehicle_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'bloc/dgauge_cubit.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request permissions before launching the app UI
  await _ensurePermissions();

  runApp(const MyApp());
}

/// Request runtime permissions needed for DGauge plugin
/// - On Android 12+ we request bluetoothScan, bluetoothConnect (and bluetoothAdvertise if needed)
/// - Also request location permission (ACCESS_FINE_LOCATION)
Future<void> _ensurePermissions() async {
  if (!Platform.isAndroid) {
    // iOS permission flow not required for this plugin (or handled separately)
    return;
  }

  // Build permission list to request
  final List<Permission> permissionsToRequest = [];

  // Common location permission required for BLE scanning on Android <=11 and sometimes needed by the SDK
  permissionsToRequest.add(Permission.location);

  // Try to include fine location explicitly if available
  permissionsToRequest.add(Permission.locationWhenInUse);

  // Bluetooth runtime permissions (Android 12+)
  // permission_handler exposes these: bluetooth, bluetoothScan, bluetoothConnect, bluetoothAdvertise
  // We include bluetooth for older versions and the splits for Android 12+
  permissionsToRequest.add(Permission.bluetooth);
  permissionsToRequest.add(Permission.bluetoothScan);
  permissionsToRequest.add(Permission.bluetoothConnect);
  permissionsToRequest.add(Permission.bluetoothAdvertise);

  // Request them (duplicates/missing ones are ignored by the plugin)
  final Map<Permission, PermissionStatus> statuses = await permissionsToRequest.request();

  // Check for denied or permanently denied
  final denied = statuses.entries.where((e) => e.value.isDenied).toList();
  final permanentlyDenied = statuses.entries.where((e) => e.value.isPermanentlyDenied).toList();

  if (denied.isNotEmpty) {
    // Ask again politely (this will show system dialogs for those that can still be asked)
    final retried = await denied.map((e) => e.key).toList().request();
    // update permanentlyDenied check after retry
    final stillPermanent = retried.entries.where((e) => e.value.isPermanentlyDenied).toList();
    if (stillPermanent.isNotEmpty) {
      // Open app settings so user can enable manually
      await _showSettingsDialog();
    }
  } else if (permanentlyDenied.isNotEmpty) {
    // If any permanently denied, kindly ask to open app settings
    await _showSettingsDialog();
  }
}

/// Ask user to open App Settings so they can enable permissions manually.
/// This is called before the app UI is shown (so we use a simple native dialog)
Future<void> _showSettingsDialog() async {
  // Try to open app settings directly
  final opened = await openAppSettings();
  if (!opened) {
    // If openAppSettings failed for some reason, we just return; user can manually enable permissions.
    debugPrint("Please enable required permissions from app settings.");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide DGaugeCubit to the app; VehicleScreen will call initialize() in its initState.
    return MultiBlocProvider(
      providers: [
        BlocProvider<DGaugeCubit>(create: (_) => DGaugeCubit(DGaugeFlutter())),
        BlocProvider<VehicleCubit>(create: (_) => VehicleCubit()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}
