import 'package:dgauge_flutter/services/logger_service.dart';
import 'package:flutter/material.dart';

class VehicleDetailsScreen extends StatefulWidget {
  const VehicleDetailsScreen({super.key});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  // map to hold sample psi/temp data and selection
  late Map<String, TyreInfo> tyres;

  final _log = LoggerService.tagged("VehicleDetailsScreen");

  List<String> tyrePositions = [
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

  @override
  void initState() {
    super.initState();
    // seed example data (in real app you will fetch these values)
    tyres = {
      for (var p in tyrePositions)
        p: TyreInfo(
            position: p, psi: null, temp: null, status: TyreStatus.empty)
    };

    // add some demo values to resemble the screenshot
    tyres['FL'] = TyreInfo(
      position: 'FL',
      psi: 141,
      temp: 37,
      status: TyreStatus.partiallyFilled,
    );
    tyres['FR'] = TyreInfo(
      position: 'FR',
      psi: 141,
      temp: 34,
      status: TyreStatus.partiallyFilled,
    );
    tyres['DLO1'] = TyreInfo(
      position: 'DLO1',
      psi: 141,
      temp: 39,
      status: TyreStatus.partiallyFilled,
    );
    tyres['DRO1'] = TyreInfo(
      position: 'DRO1',
      psi: 135,
      temp: 28,
      status: TyreStatus.partiallyFilled,
    );
    tyres['DLO2'] = TyreInfo(
      position: 'DLO2',
      psi: 132,
      temp: 34,
      status: TyreStatus.filled,
    );
    tyres['DLI2'] = TyreInfo(
      position: 'DLI2',
      psi: 129,
      temp: 25,
      status: TyreStatus.filled,
    );
    tyres['TLO3'] = TyreInfo(
      position: 'TLO3',
      psi: 144,
      temp: 38,
      status: TyreStatus.filled,
    );
    tyres['STP'] = TyreInfo(
      position: 'STP',
      psi: null,
      temp: null,
      status: TyreStatus.filled,
    );
  }

  Widget _tyreBar(TyreInfo info) {
    if (info.position.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => _log.info("Tyre Info: ${info.toString()}"),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: info.status == TyreStatus.partiallyFilled
              ? const Color(0xFFFABA22).withOpacity(0.25)
              : info.status == TyreStatus.filled
                  ? const Color(0xFF00AF4C).withOpacity(0.25)
                  : const Color(0xFFF6867E).withOpacity(0.25),
          border: Border.all(
            color: info.status == TyreStatus.partiallyFilled
                ? const Color(0xFFFABA22)
                : info.status == TyreStatus.filled
                    ? const Color(0xFF00AF4C)
                    : const Color(0xFFF6867E),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              info.position,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${info.psi ?? "--"}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "PSI",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${info.temp ?? "--"}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "°C",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _axleRow(
      {required String title,
      required String? leftOuter,
      required String? leftInner,
      required String? rightInner,
      required String? rightOuter}) {
    // Each axle row shows two columns: left and right. Middle has chassis lines.
    final leftOuterInfo =
        leftOuter != null ? tyres[leftOuter]! : TyreInfo.empty();
    final leftInnerInfo =
        leftInner != null ? tyres[leftInner]! : TyreInfo.empty();
    final rightInnerInfo =
        rightInner != null ? tyres[rightInner]! : TyreInfo.empty();
    final rightOuterInfo =
        rightOuter != null ? tyres[rightOuter]! : TyreInfo.empty();

    Widget _buildLeft() => Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // LO
            _tyreBar(leftOuterInfo),
            // LI
            _tyreBar(leftInnerInfo),
          ],
        );

    Widget _buildRight() => Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // RI
            _tyreBar(rightInnerInfo),
            // RO
            _tyreBar(rightOuterInfo),
          ],
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildLeft(),
          _buildRight(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // helpers to get positions or null if missing
    String? posIfExists(String p) => tyrePositions.contains(p) ? p : null;

    return Scaffold(
      appBar: AppBar(title: const Text("12X4 (22+1)")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Front axle
                _axleRow(
                  title: 'Front',
                  leftOuter: posIfExists('FL'),
                  leftInner: null,
                  rightInner: null,
                  rightOuter: posIfExists('FR'),
                ),

                // Drive Axles 1


                // Drive axles: we check for index 1 and 2
                if (tyrePositions.any((p) => p.startsWith('D')))
                  _axleRow(
                    title: 'Drive 1',
                    leftOuter: posIfExists('DLO1'),
                    leftInner: posIfExists('DLI1'),
                    rightInner: posIfExists('DRI1'),
                    rightOuter: posIfExists('DRO1'),
                  ),
                if (tyrePositions.any((p) =>
                    p.contains('DLO2') ||
                    p.contains('DLI2') ||
                    p.contains('DRI2') ||
                    p.contains('DRO2')))
                  _axleRow(
                    title: 'Drive 2',
                    leftOuter: posIfExists('DLO2'),
                    leftInner: posIfExists('DLI2'),
                    rightInner: posIfExists('DRI2'),
                    rightOuter: posIfExists('DRO2'),
                  ),

                // Trailer axles
                if (tyrePositions.any((p) => p.startsWith('T')))
                  _axleRow(
                    title: 'Trailer 1',
                    leftOuter: posIfExists('TLO1'),
                    leftInner: posIfExists('TLI1'),
                    rightInner: posIfExists('TRI1'),
                    rightOuter: posIfExists('TRO1'),
                  ),
                if (tyrePositions.any((p) =>
                    p.contains('TLO2') ||
                    p.contains('TLI2') ||
                    p.contains('TRI2') ||
                    p.contains('TRO2')))
                  _axleRow(
                    title: 'Trailer 2',
                    leftOuter: posIfExists('TLO2'),
                    leftInner: posIfExists('TLI2'),
                    rightInner: posIfExists('TRI2'),
                    rightOuter: posIfExists('TRO2'),
                  ),
                if (tyrePositions.any((p) =>
                    p.contains('TLO3') ||
                    p.contains('TLI3') ||
                    p.contains('TRI3') ||
                    p.contains('TRO3')))
                  _axleRow(
                    title: 'Trailer 3',
                    leftOuter: posIfExists('TLO3'),
                    leftInner: posIfExists('TLI3'),
                    rightInner: posIfExists('TRI3'),
                    rightOuter: posIfExists('TRO3'),
                  ),

                // Spare
                if (tyrePositions.contains('STP'))
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Column(
                      children: [
                        Container(height: 12),
                        // centred spare bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 16,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade800
                                ]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Stepney',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TyreInfo {
  final String position;
  final int? psi;
  final int? temp;
  final TyreStatus status;

  TyreInfo({required this.position, this.psi, this.temp, required this.status});

  TyreInfo copyWith({int? psi, int? temp, TyreStatus? status}) => TyreInfo(
        position: position,
        psi: psi ?? this.psi,
        temp: temp ?? this.temp,
        status: status ?? this.status,
      );

  static TyreInfo empty() =>
      TyreInfo(position: '', psi: null, temp: null, status: TyreStatus.empty);
}

enum TyreStatus { empty, partiallyFilled, filled }
