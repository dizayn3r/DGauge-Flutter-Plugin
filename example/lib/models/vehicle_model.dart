// To parse this JSON data, do
//
//     final vehicle = vehicleFromJson(jsonString);

import 'dart:convert';

import 'application_type.dart';
import 'body_type.dart';
import 'configuration.dart';
import 'contract_type.dart';
import 'fleet.dart';
import 'hub.dart';
import 'make.dart';
import 'mechanical_condition.dart';
import 'model.dart';
import 'tyre.dart';

Vehicle vehicleFromJson(String str) => Vehicle.fromJson(json.decode(str));

String vehicleToJson(Vehicle data) => json.encode(data.toJson());

class Vehicle {
  String? id;
  String? registrationNumber;
  ContractType? contractType;
  String? fitmentDate;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? inspectionNo;
  String? lastInspectionDate;
  String? lastInspectionHub;
  List<Tyre>? tyres;
  String? gvw;
  String? registrationYear;
  String? vehicleCc;
  String? engineNumber;
  int? averageRunKmPerDay;
  bool? enableReplacementWithoutInspection;
  List<dynamic>? agreementsInfo;
  Fleet? fleet;
  Hub? hub;
  Make? vehicleMake;
  Configuration? configuration;
  Model? model;
  DateTime? lastInspectionDateFromInspection;
  String? odometerReading;
  String? kilometerTravelled;
  BodyType? bodyType;
  ApplicationType? applicationType;
  MechanicalCondition? mechanicalCondition;
  DateTime? firstInspectionDate;

  Vehicle({
    this.id,
    this.registrationNumber,
    this.contractType,
    this.fitmentDate,
    this.createdAt,
    this.updatedAt,
    this.inspectionNo,
    this.lastInspectionDate,
    this.lastInspectionHub,
    this.tyres,
    this.gvw,
    this.registrationYear,
    this.vehicleCc,
    this.engineNumber,
    this.averageRunKmPerDay,
    this.enableReplacementWithoutInspection,
    this.agreementsInfo,
    this.fleet,
    this.hub,
    this.vehicleMake,
    this.configuration,
    this.model,
    this.lastInspectionDateFromInspection,
    this.odometerReading,
    this.kilometerTravelled,
    this.bodyType,
    this.applicationType,
    this.mechanicalCondition,
    this.firstInspectionDate,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      Vehicle(
        id: json["_id"],
        registrationNumber: json["registrationNumber"],
        contractType: json["contractType"] == null ? null : ContractType
            .fromJson(json["contractType"]),
        fitmentDate: json["fitmentDate"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(
            json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(
            json["updatedAt"]),
        inspectionNo: json["inspectionNo"],
        lastInspectionDate: json["lastInspectionDate"],
        lastInspectionHub: json["lastInspectionHub"],
        tyres: json["tyres"] == null ? [] : List<Tyre>.from(
            json["tyres"]!.map((x) => Tyre.fromJson(x))),
        gvw: json["GVW"],
        registrationYear: json["registrationYear"],
        vehicleCc: json["vehicleCC"],
        engineNumber: json["engineNumber"],
        averageRunKmPerDay: json["averageRunKmPerDay"],
        enableReplacementWithoutInspection: json["enableReplacementWithoutInspection"],
        agreementsInfo: json["agreementsInfo"] == null ? [] : List<
            dynamic>.from(json["agreementsInfo"]!.map((x) => x)),
        fleet: json["fleet"] == null ? null : Fleet.fromJson(json["fleet"]),
        hub: json["hub"] == null ? null : Hub.fromJson(json["hub"]),
        vehicleMake: json["vehicleMake"] == null ? null : Make.fromJson(
            json["vehicleMake"]),
        configuration: json["configuration"] == null ? null : Configuration
            .fromJson(json["configuration"]),
        model: json["model"] == null ? null : Model.fromJson(json["model"]),
        lastInspectionDateFromInspection: json["lastInspectionDateFromInspection"] ==
            null ? null : DateTime.parse(
            json["lastInspectionDateFromInspection"]),
        odometerReading: json["odometerReading"],
        kilometerTravelled: json["killometerTravelled"],
        bodyType: json["bodyType"] == null ? null : BodyType.fromJson(
            json["bodyType"]),
        applicationType: json["applicationType"] == null
            ? null
            : ApplicationType.fromJson(json["applicationType"]),
        mechanicalCondition: json["mechanicalCondition"] == null
            ? null
            : MechanicalCondition.fromJson(json["mechanicalCondition"]),
        firstInspectionDate: json["firstInspectionDate"] == null
            ? null
            : DateTime.parse(json["firstInspectionDate"]),
      );

  Map<String, dynamic> toJson() =>
      {
        "_id": id,
        "registrationNumber": registrationNumber,
        "contractType": contractType?.toJson(),
        "fitmentDate": fitmentDate,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "inspectionNo": inspectionNo,
        "lastInspectionDate": lastInspectionDate,
        "lastInspectionHub": lastInspectionHub,
        "tyres": tyres == null ? [] : List<dynamic>.from(
            tyres!.map((x) => x.toJson())),
        "GVW": gvw,
        "registrationYear": registrationYear,
        "vehicleCC": vehicleCc,
        "engineNumber": engineNumber,
        "averageRunKmPerDay": averageRunKmPerDay,
        "enableReplacementWithoutInspection": enableReplacementWithoutInspection,
        "agreementsInfo": agreementsInfo == null ? [] : List<dynamic>.from(
            agreementsInfo!.map((x) => x)),
        "fleet": fleet?.toJson(),
        "hub": hub?.toJson(),
        "vehicleMake": vehicleMake?.toJson(),
        "configuration": configuration?.toJson(),
        "model": model?.toJson(),
        "lastInspectionDateFromInspection": lastInspectionDateFromInspection
            ?.toIso8601String(),
        "odometerReading": odometerReading,
        "killometerTravelled": kilometerTravelled,
        "bodyType": bodyType?.toJson(),
        "applicationType": applicationType?.toJson(),
        "mechanicalCondition": mechanicalCondition?.toJson(),
        "firstInspectionDate": firstInspectionDate?.toIso8601String(),
      };
}


