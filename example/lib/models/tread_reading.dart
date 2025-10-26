import 'package:equatable/equatable.dart';

/// Typed model for one DGauge tyre packet (real-time or batch)
class TreadReading extends Equatable {
  final int tireNumber;            // 1..N
  final int? noOfTreadDepth;       // how many depths device reports (1..4)
  final String? pressureValue;     // e.g. "125"
  final String? temperatureValue;  // e.g. "45"
  final double? treadDepth1;
  final double? treadDepth2;
  final double? treadDepth3;
  final double? treadDepth4;
  final List<double> treadDepths;  // convenience array
  final int? treadReadingStatus;   // 0/1/2 etc
  final String? identifier;        // unique id for P/T packet

  const TreadReading({
    required this.tireNumber,
    this.noOfTreadDepth,
    this.pressureValue,
    this.temperatureValue,
    this.treadDepth1,
    this.treadDepth2,
    this.treadDepth3,
    this.treadDepth4,
    this.treadDepths = const [],
    this.treadReadingStatus,
    this.identifier,
  });

  /// Useful computed stats
  double? get avgTreadDepth {
    final vals = _depthsNonNull;
    if (vals.isEmpty) return null;
    return vals.reduce((a, b) => a + b) / vals.length;
  }

  double? get minTreadDepth {
    final vals = _depthsNonNull;
    if (vals.isEmpty) return null;
    vals.sort();
    return vals.first;
  }

  double? get maxTreadDepth {
    final vals = _depthsNonNull;
    if (vals.isEmpty) return null;
    vals.sort();
    return vals.last;
  }

  List<double> get _depthsNonNull => [
    if (treadDepth1 != null) treadDepth1!,
    if (treadDepth2 != null) treadDepth2!,
    if (treadDepth3 != null) treadDepth3!,
    if (treadDepth4 != null) treadDepth4!,
    ...treadDepths.where((e) => e != double.nan),
  ];

  TreadReading copyWith({
    int? tireNumber,
    int? noOfTreadDepth,
    String? pressureValue,
    String? temperatureValue,
    double? treadDepth1,
    double? treadDepth2,
    double? treadDepth3,
    double? treadDepth4,
    List<double>? treadDepths,
    int? treadReadingStatus,
    String? identifier,
  }) {
    return TreadReading(
      tireNumber: tireNumber ?? this.tireNumber,
      noOfTreadDepth: noOfTreadDepth ?? this.noOfTreadDepth,
      pressureValue: pressureValue ?? this.pressureValue,
      temperatureValue: temperatureValue ?? this.temperatureValue,
      treadDepth1: treadDepth1 ?? this.treadDepth1,
      treadDepth2: treadDepth2 ?? this.treadDepth2,
      treadDepth3: treadDepth3 ?? this.treadDepth3,
      treadDepth4: treadDepth4 ?? this.treadDepth4,
      treadDepths: treadDepths ?? this.treadDepths,
      treadReadingStatus: treadReadingStatus ?? this.treadReadingStatus,
      identifier: identifier ?? this.identifier,
    );
  }

  Map<String, dynamic> toMap() => {
    'tireNumber': tireNumber,
    'noOfTreadDepth': noOfTreadDepth,
    'pressureValue': pressureValue,
    'temperatureValue': temperatureValue,
    'treadDepth1': treadDepth1,
    'treadDepth2': treadDepth2,
    'treadDepth3': treadDepth3,
    'treadDepth4': treadDepth4,
    'treadDepths': treadDepths,
    'treadReadingStatus': treadReadingStatus,
    'identifier': identifier,
  };

  factory TreadReading.fromMap(Map<String, dynamic> m) {
    double? _toD(val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      if (val is String) {
        final v = double.tryParse(val);
        return v;
      }
      return null;
    }

    List<double> _toDepthList(dynamic v) {
      if (v is List) {
        return v
            .map((e) => _toD(e))
            .whereType<double>()
            .toList(growable: false);
      }
      return const [];
    }

    return TreadReading(
      tireNumber: (m['tireNumber'] ?? m['tyreNumber'] ?? 0) is num
          ? (m['tireNumber'] ?? m['tyreNumber'] as num).toInt()
          : int.tryParse('${m['tireNumber'] ?? m['tyreNumber'] ?? 0}') ?? 0,
      noOfTreadDepth: (m['noOfTreadDepth'] is num)
          ? (m['noOfTreadDepth'] as num).toInt()
          : int.tryParse('${m['noOfTreadDepth'] ?? ''}'),
      pressureValue: m['pressureValue']?.toString(),
      temperatureValue: m['temperatureValue']?.toString(),
      treadDepth1: _toD(m['treadDepth1']),
      treadDepth2: _toD(m['treadDepth2']),
      treadDepth3: _toD(m['treadDepth3']),
      treadDepth4: _toD(m['treadDepth4']),
      treadDepths: _toDepthList(m['treadDepths']),
      treadReadingStatus: (m['treadReadingStatus'] is num)
          ? (m['treadReadingStatus'] as num).toInt()
          : int.tryParse('${m['treadReadingStatus'] ?? ''}'),
      identifier: m['identifier']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
    tireNumber,
    noOfTreadDepth,
    pressureValue,
    temperatureValue,
    treadDepth1,
    treadDepth2,
    treadDepth3,
    treadDepth4,
    treadDepths,
    treadReadingStatus,
    identifier,
  ];

  @override
  String toString() =>
      'TreadReading(#$tireNumber, depths=$treadDepths, P=$pressureValue, T=$temperatureValue, status=$treadReadingStatus)';
}
