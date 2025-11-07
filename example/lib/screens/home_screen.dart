import 'package:flutter/material.dart';
import 'dgauge_devices.dart';
import 'tyre_positions_screen.dart';
import 'vehicle_details_screen.dart';
import 'vehicle_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DgaugeDevices(),
    VehicleScreen(),
    // TyrePositionsScreen(),
    VehicleDetailsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sensors),
            label: 'DGauge Devices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Vehicles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle_outlined),
            label: 'Tyre Positions',
          ),
        ],
      ),
    );
  }
}
