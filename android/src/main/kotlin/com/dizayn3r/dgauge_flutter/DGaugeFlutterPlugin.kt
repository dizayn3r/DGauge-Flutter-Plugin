package com.dizayn3r.dgauge_flutter

import com.treel.dgaugesdk.scanResult.ResponseStatus
import com.treel.dgaugesdk.scanResult.TyreConfigurations
import com.treel.dgaugesdk.scanResult.VehicleConfiguration

import com.dizayn3r.dgauge_flutter.DGaugeUtils

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.treel.dgaugesdk.DGaugeConnectivity
import com.treel.dgaugesdk.event.EventCallbackListener
import com.treel.dgaugesdk.scanResult.TreadDepthData
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

private const val TAG = "DGaugeFlutterPlugin"

class DGaugeFlutterPlugin : FlutterPlugin,
  MethodChannel.MethodCallHandler,
  EventChannel.StreamHandler,
  EventCallbackListener {

  private lateinit var methodChannel: MethodChannel
  private lateinit var eventChannel: EventChannel
  private var eventSink: EventChannel.EventSink? = null
  private var dgauge: DGaugeConnectivity? = null
  private lateinit var context: Context

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    context = binding.applicationContext
    methodChannel = MethodChannel(binding.binaryMessenger, "dgauge_flutter")
    methodChannel.setMethodCallHandler(this)
    eventChannel = EventChannel(binding.binaryMessenger, "dgauge_flutter_events")
    eventChannel.setStreamHandler(this)
    Log.d(TAG, "Plugin attached to engine")
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
    Log.d(TAG, "Plugin detached from engine")
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    Log.d(TAG, "Received method call: ${call.method} with args ${call.arguments}")
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "initialize" -> {
        dgauge = DGaugeConnectivity(context)
        dgauge?.addOnEventCallbackListener(this)
        Log.d(TAG, "DGaugeConnectivity initialized")
        result.success(null)
      }
      "sendVehicleConfiguration" -> {
        val mac = call.argument<String>("macAddress")!!
        @Suppress("UNCHECKED_CAST")
        val cfgMap = call.argument<Map<String, Any>>("vehicleConfig")!!
        val vehicleCfg = DGaugeUtils.toVehicleConfig(cfgMap)
        dgauge?.sendVehicleAndTyreConfigurations(mac, vehicleCfg)
        Log.d(TAG, "Sent vehicle configuration for MAC $mac: $cfgMap")
        result.success(true)
      }
      "startTireInspection" -> {
        val mac = call.argument<String>("macAddress")!!
        dgauge?.takeTreadDepthReadings(mac)
        Log.d(TAG, "Started tire inspection for MAC $mac")
        result.success(null)
      }
      "fetchAllTireData" -> {
        val mac = call.argument<String>("macAddress")!!
        dgauge?.fetchAllTreadDepthReadings(mac)
        Log.d(TAG, "Fetching all tire data for MAC $mac")
        result.success(null)
      }
      else -> {
        Log.w(TAG, "Method not implemented: ${call.method}")
        result.notImplemented()
      }
    }
  }

  // EventChannel.StreamHandler
  override fun onListen(args: Any?, sink: EventChannel.EventSink?) {
    eventSink = sink
    Log.d(TAG, "EventChannel onListen: $args")
  }

  override fun onCancel(args: Any?) {
    eventSink = null
    Log.d(TAG, "EventChannel onCancel")
  }

  // SDK EventCallbackListener
  override fun handleBleException(errorCode: Int?) {
    Log.e(TAG, "BLE Exception: $errorCode")
    eventSink?.success(mapOf("type" to "ble_exception", "errorCode" to errorCode))
  }

  override fun handleDGaugeConnectivity(response: Int?, message: String) {
    Log.d(TAG, "Connectivity: response=$response, message=$message")
    eventSink?.success(mapOf("type" to "connectivity", "response" to response, "message" to message))
  }

  override fun onSyncConfigurationResponse(responseStatus: ResponseStatus) {
    Log.d(TAG, "Sync response: $responseStatus")
    eventSink?.success(mapOf(
      "type" to "sync_response",
      "success" to responseStatus.success,
      "message" to responseStatus.message,
      "errorCode" to responseStatus.errorCode
    ))
  }

  override fun onDGuageTreadReadingStatus(status: Int) {
    Log.d(TAG, "Tread reading status: $status")
    eventSink?.success(mapOf("type" to "reading_status", "status" to status))
  }

  override fun onDGaugeScanningData(data: TreadDepthData) {
    Log.d(TAG, "Single tire data: $data")
    eventSink?.success(mapOf(
      "type" to "single_tire_data",
      "tireNumber" to data.tireNumber,
      "pressureValue" to data.pressureValue,
      "temperatureValue" to data.temperatureValue,
      "treadDepths" to listOf(data.treadDepth1, data.treadDepth2, data.treadDepth3, data.treadDepth4)
    ))
  }

  override fun onDGuageAllTreadReadingData(list: List<TreadDepthData>?) {
    Log.d(TAG, "All tire data count: ${list?.size ?: 0}")
    val all = list?.map { d ->
      mapOf(
        "tireNumber" to d.tireNumber,
        "pressureValue" to d.pressureValue,
        "temperatureValue" to d.temperatureValue,
        "treadDepths" to listOf(d.treadDepth1, d.treadDepth2, d.treadDepth3, d.treadDepth4)
      )
    }
    eventSink?.success(mapOf("type" to "all_tire_data", "data" to all))
  }
}
