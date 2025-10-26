package com.applore.dgauge_flutter

import com.treel.dgaugesdk.scanResult.TyreConfigurations
import com.treel.dgaugesdk.scanResult.VehicleConfiguration

object DGaugeUtils {

    @Suppress("UNCHECKED_CAST")
    fun toVehicleConfig(map: Map<String, Any>): VehicleConfiguration {
        val v = VehicleConfiguration()

        // vehicleNumber and axleConfiguration expected as String? in SDK
        v.vehicleNumber = (map["vehicleNumber"] as? String)
            ?: (map["vehicleNo"] as? String)
                    ?: ""

        v.axleConfiguration = (map["axleConfiguration"] as? String) ?: ""

        // numeric fields: noOfTyres (Int)
        val noOfTyresAny = map["noOfTyres"] ?: map["numberOfTires"]
        v.noOfTyres = when (noOfTyresAny) {
            is Number -> noOfTyresAny.toInt()
            is String -> noOfTyresAny.toIntOrNull() ?: 0
            else -> 0
        }

        // tyreConfigurations: expect a List<Map<String, Any>>
        val tyresAny = map["tyreConfigurations"] as? List<Map<String, Any>>
        if (tyresAny != null) {
            val tyreList = tyresAny.map { tmap ->
                val t = TyreConfigurations()

                // integer fields
                t.tyreNumber = (tmap["tyreNumber"] as? Number)?.toInt()
                    ?: (tmap["tyreNumber"] as? String)?.toIntOrNull()
                            ?: 0

                t.tyreStatus = (tmap["tyreStatus"] as? Number)?.toInt()
                    ?: (tmap["tyreStatus"] as? String)?.toIntOrNull()
                            ?: 0

                // treadCount in the SDK (based on your earlier code) is a String or can be represented as String
                t.treadCount = (tmap["treadCount"] as? String)
                    ?: (tmap["treadCount"] as? Number)?.toString()
                            ?: ""

                // tyreSerialNumber expected as String
                t.tyreSerialNumber = (tmap["tyreSerialNumber"] as? String) ?: ""

                // identifier integer
                t.identifier = (tmap["identifier"] as? Number)?.toInt()
                    ?: (tmap["identifier"] as? String)?.toIntOrNull()
                            ?: 0

                // pressureValue and temperatureValue: keep them as String (SDK expects String?)
                t.pressureValue = tmap["pressureValue"]?.toString() ?: ""
                t.temperatureValue = tmap["temperatureValue"]?.toString() ?: ""

                t
            }
            v.tyreConfigurations = tyreList
        } else {
            v.tyreConfigurations = listOf()
        }

        return v
    }
}
