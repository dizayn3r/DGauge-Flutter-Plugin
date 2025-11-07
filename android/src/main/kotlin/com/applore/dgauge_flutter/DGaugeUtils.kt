package com.applore.dgauge_flutter

import com.treel.dgaugesdk.scanResult.TyreConfigurations
import com.treel.dgaugesdk.scanResult.VehicleConfiguration

object DGaugeUtils {

    // normalize any incoming value to a safe String ("" if null or "null")
    private fun cleanString(value: Any?): String {
        return when (value) {
            null -> ""
            is String -> {
                val trimmed = value.trim()
                if (trimmed.equals("null", ignoreCase = true)) "" else trimmed
            }
            is Number -> value.toString()
            else -> value.toString()
        }
    }

    @Suppress("UNCHECKED_CAST")
    fun toVehicleConfig(map: Map<String, Any>): VehicleConfiguration {
        val v = VehicleConfiguration()

        // vehicleNumber and axleConfiguration expected as String? in SDK
        // use cleanString so "null" => ""
        v.vehicleNumber = cleanString(map["vehicleNumber"] ?: map["vehicleNo"])
        v.axleConfiguration = cleanString(map["axleConfiguration"])

        // numeric fields: noOfTyres (Int)
        val noOfTyresAny = map["noOfTyres"] ?: map["numberOfTires"]
        v.noOfTyres = when (noOfTyresAny) {
            is Number -> noOfTyresAny.toInt()
            is String -> cleanString(noOfTyresAny).toIntOrNull() ?: 0
            else -> 0
        }

        // tyreConfigurations: be defensive with types
        val tyresRaw = map["tyreConfigurations"]
        val tyresAny = when (tyresRaw) {
            is List<*> -> tyresRaw
            else -> null
        }

        if (tyresAny != null) {
            val tyreList = tyresAny.mapNotNull { item ->
                // item may be Map<*,*>, convert safely to Map<String, Any?>
                val tmap = when (item) {
                    is Map<*, *> -> item as Map<String, Any?>
                    else -> null
                } ?: return@mapNotNull null

                val t = TyreConfigurations()

                // integer fields (defensive)
                val tyreNumberAny = tmap["tyreNumber"] ?: tmap["tireNumber"]
                t.tyreNumber = when (tyreNumberAny) {
                    is Number -> tyreNumberAny.toInt()
                    is String -> cleanString(tyreNumberAny).toIntOrNull() ?: 0
                    else -> 0
                }

                val tyreStatusAny = tmap["tyreStatus"]
                t.tyreStatus = when (tyreStatusAny) {
                    is Number -> tyreStatusAny.toInt()
                    is String -> cleanString(tyreStatusAny).toIntOrNull() ?: 0
                    else -> 0
                }

                // treadCount: clean "null" -> ""
                t.treadCount = cleanString(tmap["treadCount"])

                // tyreSerialNumber expected as String
                t.tyreSerialNumber = cleanString(tmap["tyreSerialNumber"])

                // identifier integer
                val identifierAny = tmap["identifier"]
                t.identifier = when (identifierAny) {
                    is Number -> identifierAny.toInt()
                    is String -> cleanString(identifierAny).toIntOrNull() ?: 0
                    else -> 0
                }

                // pressureValue and temperatureValue: clean to safe string
                t.pressureValue = cleanString(tmap["pressureValue"])
                t.temperatureValue = cleanString(tmap["temperatureValue"])

                t
            }
            v.tyreConfigurations = tyreList
        } else {
            v.tyreConfigurations = listOf()
        }

        return v
    }
}
