import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'dgauge_flutter_method_channel.dart';

abstract class DGaugeFlutterPlatform extends PlatformInterface {
  /// Constructs a DGaugeFlutterPlatform.
  DGaugeFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static DGaugeFlutterPlatform _instance = MethodChannelDGaugeFlutter();

  /// The default instance of [DGaugeFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelDGaugeFlutter].
  static DGaugeFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DGaugeFlutterPlatform] when
  /// they register themselves.
  static set instance(DGaugeFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
