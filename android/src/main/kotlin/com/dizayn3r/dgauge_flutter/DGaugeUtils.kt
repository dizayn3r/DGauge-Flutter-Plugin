package com.dizayn3r.dgauge_flutter

import com.treel.dgaugesdk.scanResult.TyreConfigurations
import com.treel.dgaugesdk.scanResult.VehicleConfiguration

object DGaugeUtils {
    fun toVehicleConfig(map: Map<String, Any>): VehicleConfiguration {
        val tyres = (map["tireConfigurations"] as List<Map<String, Any>>).map { tm ->
            TyreConfigurations().apply {
                tyreNumber = (tm["tireNumber"] as Number).toInt()
                tyreStatus = (tm["tireStatus"] as Number).toInt()
                tyreSerialNumber = tm["tireSerialNumber"] as String
                identifier = (tm["identifier"] as Number).toInt()
                pressureValue = tm["pressureValue"] as String
                temperatureValue = tm["temperatureValue"] as String
            }
        }
        return VehicleConfiguration().apply {
            vehicleNumber = map["vehicleNumber"] as String
            axleConfiguration = map["axleConfiguration"] as String
            noOfTyres = (map["numberOfTires"] as Number).toInt()
            tyreConfigurations = tyres
        }
    }
}
