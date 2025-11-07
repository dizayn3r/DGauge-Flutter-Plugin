package com.applore.dgauge_flutter

import android.content.Context
import android.util.Log
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import com.treel.dgaugesdk.DGaugeConnectivity
import com.treel.dgaugesdk.exception.BleScanException
import com.treel.dgaugesdk.event.EventCallbackListener
import com.treel.dgaugesdk.scanResult.ResponseStatus
import com.treel.dgaugesdk.scanResult.TreadDepthData
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// NEW: for one-shot read timeouts
import android.os.Handler
import android.os.Looper

private const val TAG = "DGaugeFlutterPlugin"

// ANSI colors (for boxed logs)
private const val COLOR_RESET = "\u001B[0m"
private const val COLOR_RED = "\u001B[31m"
private const val COLOR_GREEN = "\u001B[32m"
private const val COLOR_YELLOW = "\u001B[33m"
private const val COLOR_CYAN = "\u001B[36m"

// Operation type constants based on SDK patterns
private const val OPERATION_TYPE_READ = 1
private const val OPERATION_TYPE_WRITE = 2
private const val OPERATION_TYPE_SCAN = 0

private fun logBox(level: String, color: String, message: String) {
    val timestamp = SimpleDateFormat("HH:mm:ss.SSS", Locale.getDefault()).format(Date())
    val trace = Throwable().stackTrace
    val traceLine = trace.firstOrNull { it.className.contains("DGauge") || it.className.contains("Flutter") }
    val location = if (traceLine != null) "(${traceLine.fileName}:${traceLine.lineNumber})" else "(Unknown Location)"
    val tag = "[DGauge]"
    val boxTop = "┌────────────────────────────────────────────────────────────────────────────────────────────"
    val boxBottom = "└────────────────────────────────────────────────────────────────────────────────────────────"
    Log.println(
        when (level) {
            "E" -> Log.ERROR
            "W" -> Log.WARN
            "I" -> Log.INFO
            else -> Log.DEBUG
        },
        tag,
        """
$color$boxTop
│ 🕒 $timestamp $location
│ $message
$boxBottom$COLOR_RESET
""".trimIndent()
    )
}

private fun logInfo(message: String) = logBox("I", COLOR_GREEN, message)
private fun logDebug(message: String) = logBox("D", COLOR_CYAN, message)
private fun logWarn(message: String) = logBox("W", COLOR_YELLOW, message)
private fun logError(message: String) = logBox("E", COLOR_RED, message)

class DGaugeFlutterPlugin : FlutterPlugin,
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler,
    EventCallbackListener {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private var dgauge: DGaugeConnectivity? = null
    private lateinit var context: Context

    // NEW: one-shot / batch awaiting support
    private val mainHandler = Handler(Looper.getMainLooper())
    private var pendingSingleRead: MethodChannel.Result? = null
    private var pendingAllRead: MethodChannel.Result? = null
    private var singleReadTimeout: Runnable? = null
    private var allReadTimeout: Runnable? = null

    private fun clearSingleReadPending() {
        singleReadTimeout?.let { mainHandler.removeCallbacks(it) }
        singleReadTimeout = null
        pendingSingleRead = null
    }

    private fun clearAllReadPending() {
        allReadTimeout?.let { mainHandler.removeCallbacks(it) }
        allReadTimeout = null
        pendingAllRead = null
    }

    // FlutterPlugin lifecycle
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, "dgauge_flutter")
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(binding.binaryMessenger, "dgauge_flutter_events")
        eventChannel.setStreamHandler(this)
        logDebug("Plugin attached to engine")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        logDebug("Plugin detached from engine")
    }

    // MethodChannel.MethodCallHandler
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        logDebug("Received method call: ${call.method} with args ${call.arguments}")
        when (call.method) {
            "getPlatformVersion" -> {
                result.success(android.os.Build.VERSION.RELEASE)
            }

            "initialize" -> {
                try {
                    dgauge = DGaugeConnectivity(context)
                    dgauge?.addOnEventCallbackListener(this)
                    logInfo("DGaugeConnectivity initialized successfully")
                    result.success(true)
                } catch (e: Exception) {
                    logError("Failed to initialize DGaugeConnectivity: ${e.message}")
                    result.error("INIT_ERROR", "Failed to initialize: ${e.message}", null)
                }
            }

            "sendVehicleConfiguration" -> {
                val mac = call.argument<String>("macAddress") ?: run {
                    result.error("ARG_ERROR", "macAddress missing", null)
                    return
                }
                @Suppress("UNCHECKED_CAST")
                val cfgMap = call.argument<Map<String, Any>>("vehicleConfig") ?: run {
                    result.error("ARG_ERROR", "vehicleConfig missing", null)
                    return
                }
                try {
                    val vehicleCfg = DGaugeUtils.toVehicleConfig(cfgMap)
                    val response = dgauge?.sendVehicleAndTyreConfigurations(mac, vehicleCfg)
                    logInfo("Sent vehicle configuration for MAC: $mac | Response: ${response.toString()}")
                    result.success(true)
                } catch (e: Exception) {
                    logError("Failed to send vehicle configuration: ${e.message}")
                    result.error("CONFIG_ERROR", "Failed to send configuration: ${e.message}", null)
                }
            }

            "getVehicleConfiguration" -> {
                val mac = call.argument<String>("macAddress") ?: run {
                    result.error("ARG_ERROR", "macAddress missing", null)
                    return
                }
                try {
                    dgauge?.readDeviceConfigurations(mac)
                    logInfo("Read vehicle configuration for MAC: $mac")
                    result.success(true)
                } catch (e: Exception) {
                    logError("Failed to get vehicle configuration: ${e.message}")
                    result.error("CONFIG_ERROR", "Failed to get configuration: ${e.message}", null)
                }
            }

            "startTireInspection" -> {
                val mac = call.argument<String>("macAddress") ?: run {
                    result.error("ARG_ERROR", "macAddress missing", null)
                    return
                }
                try {
                    dgauge?.takeTreadDepthReadings(mac)
                    logInfo("Started tire inspection for MAC $mac")
                    result.success(true)
                } catch (e: Exception) {
                    logError("Failed to start tire inspection: ${e.message}")
                    result.error("INSPECTION_ERROR", "Failed to start inspection: ${e.message}", null)
                }
            }

            "fetchAllTireData" -> {
                val mac = call.argument<String>("macAddress") ?: run {
                    result.error("ARG_ERROR", "macAddress missing", null)
                    return
                }
                try {
                    dgauge?.fetchAllTreadDepthReadings(mac)
                    logInfo("Fetching all tire data for MAC $mac")
                    result.success(true)
                } catch (e: Exception) {
                    logError("Failed to fetch tire data: ${e.message}")
                    result.error("FETCH_ERROR", "Failed to fetch tire data: ${e.message}", null)
                }
            }

            "connectDGauge" -> {
                val mac = call.argument<String>("macAddress") ?: run {
                    result.error("ARG_ERROR", "macAddress missing", null)
                    return
                }
                try {
                    val success = connectToDevice(mac)
                    if (success) {
                        logInfo("Connection initiated for MAC: $mac")
                        result.success(true)
                    } else {
                        logWarn("Failed to initiate connection for MAC: $mac")
                        result.error("CONNECT_FAILED", "Unable to start connection process", null)
                    }
                } catch (e: Exception) {
                    logError("Error in connectDGauge: ${e.message}")
                    result.error("CONNECT_ERROR", e.message, null)
                }
            }

            "disconnectDGauge" -> {
                try {
                    disconnectDevice()
                    logInfo("Disconnect initiated")
                    result.success(true)
                } catch (e: Exception) {
                    logError("Error during disconnectDGauge: ${e.message}")
                    result.error("DISCONNECT_ERROR", e.message, null)
                }
            }

            // NEW: one-shot read (first live packet after request)
            "readTreadDepthOnce" -> {
                val mac = call.argument<String>("macAddress") ?: run {
                    result.error("ARG_ERROR", "macAddress missing", null); return
                }
                if (pendingSingleRead != null) {
                    result.error("BUSY", "A single read is already in progress", null); return
                }
                try {
                    pendingSingleRead = result
                    val timeoutMs = (call.argument<Int>("timeoutMs") ?: 12000).coerceAtLeast(1000)
                    singleReadTimeout = Runnable {
                        pendingSingleRead?.error("TIMEOUT", "Timed out waiting for a tread reading", null)
                        clearSingleReadPending()
                    }.also { mainHandler.postDelayed(it, timeoutMs.toLong()) }

                    dgauge?.takeTreadDepthReadings(mac)
                    logInfo("One-shot tread depth read started for MAC $mac (timeout=$timeoutMs ms)")
                } catch (e: Exception) {
                    clearSingleReadPending()
                    logError("readTreadDepthOnce failed: ${e.message}")
                    result.error("READ_ERROR", e.message, null)
                }
            }

            // NEW: batch read (list of all tyres)
            "readAllTreadDepths" -> {
                val mac = call.argument<String>("macAddress") ?: run {
                    result.error("ARG_ERROR", "macAddress missing", null); return
                }
                if (pendingAllRead != null) {
                    result.error("BUSY", "An all-read is already in progress", null); return
                }
                try {
                    pendingAllRead = result
                    val timeoutMs = (call.argument<Int>("timeoutMs") ?: 20000).coerceAtLeast(2000)
                    allReadTimeout = Runnable {
                        pendingAllRead?.error("TIMEOUT", "Timed out waiting for all tread readings", null)
                        clearAllReadPending()
                    }.also { mainHandler.postDelayed(it, timeoutMs.toLong()) }

                    dgauge?.fetchAllTreadDepthReadings(mac)
                    logInfo("All-tyres tread depth fetch started for MAC $mac (timeout=$timeoutMs ms)")
                } catch (e: Exception) {
                    clearAllReadPending()
                    logError("readAllTreadDepths failed: ${e.message}")
                    result.error("READ_ALL_ERROR", e.message, null)
                }
            }

            else -> {
                logWarn("Method not implemented: ${call.method}")
                result.notImplemented()
            }
        }
    }

    /**
     * Attempts to connect to the DGauge device using proper SDK methods
     */
    private fun connectToDevice(macAddress: String): Boolean {
        val target = dgauge ?: return false
        try {
            // Set the MAC address into the SDK’s private field
            setMacAddress(macAddress)

            // Try scan -> connect flow
            try {
                val scanMethod = target.javaClass.getDeclaredMethod(
                    "scanTpmsDGaugeDevice",
                    Int::class.javaPrimitiveType
                )
                scanMethod.isAccessible = true
                scanMethod.invoke(target, OPERATION_TYPE_SCAN)
                logInfo("Invoked scanTpmsDGaugeDevice with operation type $OPERATION_TYPE_SCAN")
                return true
            } catch (_: NoSuchMethodException) {
                logWarn("scanTpmsDGaugeDevice not found, trying alternatives")
            }

            // Direct connect
            try {
                val connectMethod = target.javaClass.getDeclaredMethod(
                    "connectDeviceToDGauge",
                    Int::class.javaPrimitiveType
                )
                connectMethod.isAccessible = true
                connectMethod.invoke(target, OPERATION_TYPE_READ)
                logInfo("Invoked connectDeviceToDGauge with operation type $OPERATION_TYPE_READ")
                return true
            } catch (_: NoSuchMethodException) {
                logWarn("connectDeviceToDGauge not found")
            }

            // Prepare connection observable + observe BLE state
            try {
                val prepareMethod = target.javaClass.getDeclaredMethod("prepareConnectionObservable")
                prepareMethod.isAccessible = true
                prepareMethod.invoke(target)
                logInfo("Invoked prepareConnectionObservable")

                try {
                    val observeMethod = target.javaClass.getDeclaredMethod("observeBleStateChanges")
                    observeMethod.isAccessible = true
                    observeMethod.invoke(target)
                    logInfo("Invoked observeBleStateChanges")
                } catch (e: Exception) {
                    logDebug("observeBleStateChanges invocation skipped: ${e.message}")
                }

                return true
            } catch (_: NoSuchMethodException) {
                logWarn("prepareConnectionObservable not found")
            }

            logError("No suitable connection method found in SDK")
            return false
        } catch (e: Exception) {
            logError("Unexpected error in connectToDevice: ${e.message}")
            e.printStackTrace()
            return false
        }
    }

    /**
     * Sets the MAC address in the SDK's internal field
     */
    private fun setMacAddress(macAddress: String) {
        try {
            val target = dgauge ?: return
            val field = target.javaClass.getDeclaredField("macAddressValue")
            field.isAccessible = true
            field.set(target, macAddress)
            logDebug("Set macAddressValue to: $macAddress")
        } catch (e: NoSuchFieldException) {
            logWarn("macAddressValue field not found in SDK: ${e.message}")
        } catch (e: Exception) {
            logWarn("Failed to set macAddressValue: ${e.message}")
        }
    }

    /**
     * Disconnects from the DGauge device using proper SDK methods
     */
    private fun disconnectDevice() {
        val target = dgauge ?: return
        var didDisconnect = false

        // Primary: triggerDisconnect
        try {
            target.triggerDisconnect()
            logInfo("Called triggerDisconnect()")
            didDisconnect = true
        } catch (e: Exception) {
            logWarn("triggerDisconnect() failed: ${e.message}")
        }

        // Secondary: disconnectDevice
        try {
            target.disconnectDevice()
            logInfo("Called disconnectDevice()")
            didDisconnect = true
        } catch (e: Exception) {
            logWarn("disconnectDevice() failed: ${e.message}")
        }

        // Stop scanning via reflection if available
        try {
            val stopScanMethod = target.javaClass.getDeclaredMethod("stopScan")
            stopScanMethod.isAccessible = true
            stopScanMethod.invoke(target)
            logInfo("Called stopScan() via reflection")
            didDisconnect = true
        } catch (_: NoSuchMethodException) {
            logDebug("stopScan() method not found")
        } catch (e: Exception) {
            logWarn("stopScan() failed: ${e.message}")
        }

        if (didDisconnect) {
            emitEvent(
                "onDGaugeDisconnected",
                mapOf("reason" to "requested_by_flutter", "success" to true)
            )
        }
    }

    // Optional helpers (reflection checks)
    private fun isDeviceConnected(): Boolean {
        try {
            val target = dgauge ?: return false
            val method = target.javaClass.getDeclaredMethod("isConnected1")
            method.isAccessible = true
            val invoked = method.invoke(target) as? Boolean
            return invoked ?: false
        } catch (e: Exception) {
            logDebug("isConnected1() check failed: ${e.message}")
            return false
        }
    }

    private fun isCurrentlyScanning(): Boolean {
        try {
            val target = dgauge ?: return false
            val method = target.javaClass.getDeclaredMethod("isScanning")
            method.isAccessible = true
            val invoked = method.invoke(target) as? Boolean
            return invoked ?: false
        } catch (e: Exception) {
            logDebug("isScanning() check failed: ${e.message}")
            return false
        }
    }

    // EventChannel.StreamHandler
    override fun onListen(args: Any?, sink: EventChannel.EventSink?) {
        eventSink = sink
        logDebug("EventChannel listener attached")
    }

    override fun onCancel(args: Any?) {
        eventSink = null
        logDebug("EventChannel listener cancelled")
    }

    // --- Mappers ---
    private fun treadDepthToMap(d: TreadDepthData): Map<String, Any?> {
        return mapOf(
            "tireNumber" to d.tireNumber,
            "noOfTreadDepth" to d.noOfTreadDeapth,
            "pressureValue" to d.pressureValue,
            "temperatureValue" to d.temperatureValue,
            "treadDepth1" to d.treadDepth1,
            "treadDepth2" to d.treadDepth2,
            "treadDepth3" to d.treadDepth3,
            "treadDepth4" to d.treadDepth4,
            "treadDepths" to listOf(d.treadDepth1, d.treadDepth2, d.treadDepth3, d.treadDepth4),
            "treadReadingStatus" to d.treadReadingStatus,
            "identifier" to d.identifier
        )
    }

    // SDK EventCallbackListener implementations
    override fun handleBleException(errorCode: Int?) {
        logError("BLE Exception with code: $errorCode")

        val message = try {
            when (errorCode) {
                BleScanException.SCAN_FAILED_CONFIGURATION_NOT_AVAILABLE ->
                    "Sensor configuration not available"
                BleScanException.BLUETOOTH_NOT_AVAILABLE ->
                    "Bluetooth is not available on this device"
                BleScanException.BLUETOOTH_DISABLED ->
                    "Bluetooth is disabled. Please enable Bluetooth and try again."
                BleScanException.LOCATION_PERMISSION_MISSING ->
                    "Location permission is required for Bluetooth scanning on Android 6+."
                BleScanException.LOCATION_SERVICES_DISABLED ->
                    "Location services are disabled. Please enable location services."
                BleScanException.SCAN_FAILED_ALREADY_STARTED ->
                    "Scan is already in progress."
                BleScanException.SCAN_FAILED_APPLICATION_REGISTRATION_FAILED ->
                    "Failed to register application for Bluetooth scan."
                BleScanException.SCAN_FAILED_FEATURE_UNSUPPORTED ->
                    "Scan with specified parameters is not supported by this device."
                BleScanException.SCAN_FAILED_INTERNAL_ERROR ->
                    "Scan failed due to an internal error."
                BleScanException.SCAN_FAILED_OUT_OF_HARDWARE_RESOURCES ->
                    "Scan cannot start due to limited hardware resources."
                BleScanException.UNDOCUMENTED_SCAN_THROTTLE -> {
                    val retrySeconds = 30
                    String.format(
                        Locale.getDefault(),
                        "Android 7+ restricts scan frequency. Please try again in %d seconds.",
                        retrySeconds
                    )
                }
                BleScanException.UNKNOWN_ERROR_CODE,
                BleScanException.BLUETOOTH_CANNOT_START ->
                    "Unable to start scanning (internal or unknown error)."
                else ->
                    "Unable to start scanning (error code: $errorCode)."
            }
        } catch (ex: Exception) {
            logWarn("Error mapping BLE error code: ${ex.message}")
            "Unable to start scanning (error code: $errorCode)."
        }

        emitEvent("handleBleException", mapOf("errorCode" to errorCode, "message" to message))

        // NEW: fail any pending reads so the Flutter Future doesn't hang
        pendingSingleRead?.error("BLE_ERROR", message, errorCode); clearSingleReadPending()
        pendingAllRead?.error("BLE_ERROR", message, errorCode); clearAllReadPending()
    }

    override fun handleDGaugeConnectivity(response: Int?, message: String) {
        logDebug("DGauge connectivity event -> response=$response, message='$message'")

        val normalized = message.trim().uppercase(Locale.getDefault())

        val (status, userMsg) = when {
            normalized.contains("INVALID") && normalized.contains("MAC") ->
                "INVALID_MAC_ADDRESS" to "Provided MAC address is invalid."
            normalized.contains("SCANNING") && !normalized.contains("STOP") ->
                "SCANNING_IN_PROGRESS" to "Scanning for DGauge device..."
            normalized.contains("STOP") && normalized.contains("SCAN") ->
                "SCANNING_STOPPED" to "Device scan stopped."
            normalized.contains("CONNECTING") ->
                "CONNECTING_TO_DGAUGE" to "Connecting to DGauge device..."
            normalized.contains("CONNECTED") && !normalized.contains("DISCONNECT") ->
                "CONNECTED_DGAUGE" to "Successfully connected to DGauge."
            normalized.contains("DISCONNECT") || normalized.contains("DISCONNECTED") ->
                "DGAUGE_DISCONNECTED" to "DGauge device disconnected."
            normalized.contains("SYNC") ->
                "SYNCING_CONFIG" to "Syncing configuration with device..."
            normalized.contains("CONFIG") && normalized.contains("SUCCESS") ->
                "CONFIG_SUCCESS" to "Configuration applied successfully."
            normalized.contains("TIMEOUT") || normalized.contains("TIMED OUT") ->
                "CONNECTION_TIMEOUT" to "Connection attempt timed out."
            normalized.contains("FAILED") || normalized.contains("FAIL") ->
                "CONNECTION_FAILED" to message
            normalized.contains("FACTORY") && normalized.contains("SETTING") ->
                "FACTORY_SETTINGS_READ" to "Factory settings retrieved."
            normalized.isNotEmpty() ->
                "CUSTOM_MESSAGE" to message
            else -> when (response) {
                0 -> "IDLE" to "DGauge idle."
                1 -> "SCANNING_IN_PROGRESS" to "Scanning for DGauge device..."
                2 -> "SCANNING_STOPPED" to "Device scan stopped."
                3 -> "CONNECTION_FAILED" to "Failed to connect to DGauge."
                4 -> "CONNECTED_DGAUGE" to "Successfully connected to DGauge."
                6 -> "STATUS_CODE_6" to "DGauge status code: 6."
                8 -> "FACTORY_SETTINGS_READ" to "Factory settings retrieved successfully."
                else -> "UNKNOWN_RESPONSE" to "DGauge status code: ${response ?: "null"}."
            }
        }

        emitEvent(
            "handleDGaugeConnectivity",
            mapOf(
                "response" to response,
                "message" to message,
                "status" to status,
                "userMessage" to userMsg
            )
        )

        // NEW: If the connectivity message is a failure/timeout, fail pending reads
        val isFailure = normalized.contains("FAILED") || normalized.contains("TIMEOUT") || normalized.contains("TIMED OUT")
        if (isFailure) {
            pendingSingleRead?.error("CONNECTIVITY_ERROR", message, response); clearSingleReadPending()
            pendingAllRead?.error("CONNECTIVITY_ERROR", message, response); clearAllReadPending()
        }
    }

    override fun onSyncConfigurationResponse(responseStatus: ResponseStatus) {
        logInfo("Configuration sync response: success=${responseStatus.success}, message=${responseStatus.message}")
        emitEvent(
            "onSyncConfigurationResponse",
            mapOf(
                "success" to responseStatus.success,
                "message" to responseStatus.message,
                "errorCode" to responseStatus.errorCode,
                "configCompleteStatus" to responseStatus.configCompleteStatus
            )
        )
    }

    override fun onDGuageTreadReadingStatus(status: Int) {
        logDebug("Tread reading status: $status")
        emitEvent("onDGuageTreadReadingStatus", mapOf("status" to status))
    }

    // Add this method to the DGaugeFlutterPlugin class
    override fun onDGuageConfiguredVehicle(vehicleNo: String) {
        try {
            logInfo("onDGuageConfiguredVehicle -> vehicleNo='$vehicleNo'")
            emitEvent(
                "onDGuageConfiguredVehicle",
                mapOf(
                    "vehicleNo" to vehicleNo
                )
            )
        } catch (e: Exception) {
            logWarn("onDGuageConfiguredVehicle handler failed: ${e.message}")
        }
    }

    // 3.5.5 real-time per-tyre callback
    override fun onDGaugeScanningData(data: TreadDepthData) {
        logInfo("Received tire data for tire #${data.tireNumber} (status=${data.treadReadingStatus})")

        val payload = treadDepthToMap(data)

//    // NEW: Stable, clearer event name for UI
//    emitEvent("inspectionLiveData", payload)

        // Backward-compat event (kept as-is)
        emitEvent(
            "onDGaugeScanningData",
            mapOf(
                "tireNumber" to data.tireNumber,
                "pressureValue" to data.pressureValue,
                "temperatureValue" to data.temperatureValue,
                "treadDepths" to listOf(
                    data.treadDepth1,
                    data.treadDepth2,
                    data.treadDepth3,
                    data.treadDepth4
                )
            )
        )

        // NEW: Complete pending one-shot read (first packet wins)
        pendingSingleRead?.let { pending ->
            pending.success(payload)
            clearSingleReadPending()
        }
    }

    // 3.5.6 all-tyres batch callback
    override fun onDGuageAllTreadReadingData(list: List<TreadDepthData>?) {
        val tireCount = list?.size ?: 0
        logInfo("Received all tire data: $tireCount tires")

        val items = (list ?: emptyList()).map { treadDepthToMap(it) }

//    // NEW: Stable batch event
//    emitEvent("inspectionAllData", mapOf("items" to items, "count" to items.size))

        // Backward-compat event (original)
        emitEvent("onDGuageAllTreadReadingData", mapOf("items" to items))

        // NEW: Complete pending all-read Future
        pendingAllRead?.let { pending ->
            pending.success(items)
            clearAllReadPending()
        }
    }

    /** Emits an event to the Flutter event channel */
    private fun emitEvent(eventName: String, data: Any?) {
        val payload = mapOf(
            "event" to eventName,
            "data" to (data ?: emptyMap<String, Any>())
        )
        try {
            eventSink?.success(payload)
            logDebug("Event emitted: $eventName")
        } catch (e: Exception) {
            logError("Failed to emit event $eventName: ${e.message}")
        }
    }
}
