import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dgauge_flutter_platform_interface.dart';

/// An implementation of [DGaugeFlutterPlatform] that uses method channels.
class MethodChannelDGaugeFlutter extends DGaugeFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('dgauge_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
