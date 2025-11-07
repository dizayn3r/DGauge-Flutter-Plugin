import 'package:flutter/material.dart';

class TyrePositionsScreen extends StatelessWidget {
  const TyrePositionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const List<String> tyrePositions = [
      "FL",
      "FR",
      "DLO1",
      "DLI1",
      "DRO1",
      "DRI1",
      "DLO2",
      "DLI2",
      "DRO2",
      "DRI2",
      "TLO1",
      "TLI1",
      "TRO1",
      "TRI1",
      "TLO2",
      "TLI2",
      "TRO2",
      "TRI2",
      "TLO3",
      "TLI3",
      "TRO3",
      "TRI3",
      "STP",
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tyre Positions'),
      ),
    );
  }
}
