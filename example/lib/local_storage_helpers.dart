import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class UserSimplePreferences {
  static const String dgaugeDevices = "dgauge_devices";

  static Future<void> saveDgaugeDevice(String devices) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(dgaugeDevices, devices);
  }

  static Future<List<dynamic>> getDgaugeDevices() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(dgaugeDevices);

    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return [];
  }
}