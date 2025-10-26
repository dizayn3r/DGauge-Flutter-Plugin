
import 'tyre_configuration.dart';

class VehicleConfiguration {
  final String vehicleNumber;
  final String axleConfiguration;
  final int numberOfTyres;
  final List<TyreConfiguration> tyreConfigurations;


  VehicleConfiguration({
    required this.vehicleNumber,
    required this.axleConfiguration,
    required this.numberOfTyres,
    required this.tyreConfigurations,
  });

  Map<String, dynamic> toMap() {
    return {
      'vehicleNumber': vehicleNumber,
      'axleConfiguration': axleConfiguration,
      'noOfTyres': numberOfTyres,
      'tyreConfigurations': tyreConfigurations.map((e) => e.toMap()).toList(),
    };
  }
}