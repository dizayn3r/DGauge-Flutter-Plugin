import 'package:dgauge_flutter/dgauge_flutter.dart';
import 'package:flutter/material.dart';

class TireInspectionScreen extends StatefulWidget {
  const TireInspectionScreen({super.key});

  @override
  _TireInspectionScreenState createState() => _TireInspectionScreenState();
}

class _TireInspectionScreenState extends State<TireInspectionScreen> {
  String status = "Ready";
  List<Map<String, dynamic>> tireData = [];

  @override
  void initState() {
    super.initState();
    initializeDGuage();
    listenToEvents();
  }

  Future<void> initializeDGuage() async {
    await DGaugeFlutter.initialize();
    setState(() {
      status = "Initialized";
    });
  }

  void listenToEvents() {
    DGaugeFlutter.eventStream.listen((event) {
      switch (event['type']) {
        case 'connectivity':
          setState(() {
            status = event['message'];
          });
          break;
        case 'single_tire_data':
          // Handle individual tire readings
          break;
        case 'all_tire_data':
          setState(() {
            tireData = List<Map<String, dynamic>>.from(event['data']);
          });
          break;
      }
    });
  }

  Future<void> startInspection() async {
    // Create vehicle configuration
    final vehicleConfig = VehicleConfiguration(
      vehicleNumber: "DL01AD1234",
      axleConfiguration: "2x2x1",
      numberOfTires: 5,
      tireConfigurations: [
        TireConfiguration(
          tireNumber: 1,
          tireStatus: 0,
          treadCount: "4",
          tireSerialNumber: "CO001234DF34",
          identifier: 1,
          pressureValue: "",
          temperatureValue: "",
        ),
        // Add more tire configurations...
      ],
    );

    // Send configuration and start inspection
    String macAddress = "ABCDEF010203"; // Your DGuage device MAC address

    await DGaugeFlutter.sendVehicleConfiguration(
      macAddress: macAddress,
      vehicleConfig: vehicleConfig.toMap(),
    );

    await DGaugeFlutter.startTireInspection(macAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tire Inspection'),
      ),
      body: Column(
        children: [
          Text('Status: $status'),
          ElevatedButton(
            onPressed: startInspection,
            child: const Text('Start Inspection'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tireData.length,
              itemBuilder: (context, index) {
                final tire = tireData[index];
                return ListTile(
                  title: Text('Tire ${tire['tireNumber']}'),
                  subtitle: Text(
                    'Pressure: ${tire['pressureValue']}, '
                    'Temperature: ${tire['temperatureValue']}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
