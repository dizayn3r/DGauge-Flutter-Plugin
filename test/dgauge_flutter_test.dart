import 'package:flutter_test/flutter_test.dart';
import 'package:dgauge_flutter/dgauge_flutter.dart';
import 'package:dgauge_flutter/dgauge_flutter_platform_interface.dart';
import 'package:dgauge_flutter/dgauge_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDGaugeFlutterPlatform
    with MockPlatformInterfaceMixin
    implements DGaugeFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DGaugeFlutterPlatform initialPlatform = DGaugeFlutterPlatform.instance;

  test('$MethodChannelDGaugeFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDGaugeFlutter>());
  });

  test('getPlatformVersion', () async {
    MockDGaugeFlutterPlatform fakePlatform = MockDGaugeFlutterPlatform();
    DGaugeFlutterPlatform.instance = fakePlatform;

    expect(await DGaugeFlutter.getPlatformVersion(), '42');
  });
}
