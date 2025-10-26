import 'package:dgauge_flutter_example/bloc/dgauge_cubit.dart';
import 'package:dgauge_flutter_example/screens/qr_code_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_colors.dart';
import '../app_formatters.dart';
import '../bloc/dgauge_state.dart';
import '../custom_functions.dart';
import '../models/device_model.dart';
import '../screen_navigation.dart';

class AddDgaugeDevice extends StatefulWidget {
  const AddDgaugeDevice({super.key});

  @override
  State<AddDgaugeDevice> createState() => _AddDgaugeDeviceState();
}

class _AddDgaugeDeviceState extends State<AddDgaugeDevice> {
  final TextEditingController deviceNameController = TextEditingController();

  final TextEditingController macAddController = TextEditingController();

  @override
  void initState() {
    context.read<DGaugeCubit>().getDgaugeDevices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Add DGauge Device",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: _buildBody(context),
    );
  }

  String formatAsMacAddress(String input) {
    // Remove all non-hexadecimal characters from the input
    String sanitizedInput = input.replaceAll(RegExp(r'[^A-Fa-f0-9]'), '');

    // Ensure the sanitized string has exactly 12 characters
    if (sanitizedInput.length != 12) {
      throw const FormatException(
        "Input must contain exactly 12 hexadecimal characters",
      );
    }

    // Insert colons every 2 characters
    return sanitizedInput
        .toUpperCase()
        .replaceAllMapped(RegExp(r'.{2}'), (match) => '${match.group(0)}:')
        .substring(0, 17); // Remove the trailing colon
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<DGaugeCubit, DGaugeState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _CommonTextField(
                controller: deviceNameController,
                hintText: "Enter Device Name",
                labelText: "Device Name",
              ),
              const SizedBox(height: 16),
              _CommonTextField(
                controller: macAddController,
                hintText: "Enter device MAC ID",
                labelText: "Device MAC ID",
                inputFormatters: [
                  MacAddressInputFormatter(),
                  UppercaseTextFormatter(),
                ],
                suffixIcon: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        createRoute(
                          const QRCodeScannerScreen(),
                        )).then(
                      (value) {
                        if (value != null) {
                          String macAddress = value.split(' ').last;
                          macAddController.text =
                              formatAsMacAddress(macAddress);
                        }
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  var formError = _validateForm();
                  if (formError != null) {
                    showSnackBar(context, formError);
                    return;
                  }

                  FocusManager.instance.primaryFocus?.unfocus();

                  // Perform async operation
                  var error =
                      await context.read<DGaugeCubit>().saveDgaugeDevice(
                            DGaugeDeviceModel(
                              name: deviceNameController.text.trim(),
                              macAddress: macAddController.text,
                            ),
                          );

                  // ✅ Check if widget is still mounted before using context
                  if (!context.mounted) return;

                  if (error == null) {
                    showSnackBar(context, "DGauge Device added successfully!");
                    deviceNameController.clear();
                    macAddController.clear();
                    setState(() {});
                  } else {
                    showSnackBar(context, error);
                  }
                },
                child: const Text("Save"),
              ),
              const SizedBox(height: 16),
              if (state.dgaugeDevices.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  color: AppColors.inDarkGrey,
                  child: const Center(
                    child: Text(
                      "Saved devices",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: state.dgaugeDevices.length,
                    itemBuilder: (context, index) {
                      var device = state.dgaugeDevices[index];
                      return Card(
                        child: ListTile(
                          title: Text(device.name ?? "NA"),
                          subtitle: Text(device.macAddress ?? "NA"),
                          trailing: InkWell(
                            child: const Icon(Icons.delete),
                            onTap: () async {
                              await context
                                  .read<DGaugeCubit>()
                                  .deleteDevice(device);

                              // ✅ Check if the widget is still mounted before using context
                              if (!context.mounted) return;

                              setState(() {});

                              showSnackBar(
                                context,
                                "Device deleted successfully!",
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String? _validateForm() {
    if (deviceNameController.text.trim().isEmpty) {
      deviceNameController.clear();
      return "Please enter valid device name";
    }
    if (macAddController.text.isEmpty) {
      return "Please enter device mac address";
    }
    return null;
  }
}

class _CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;

  const _CommonTextField({
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.inputFormatters,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontStyle: FontStyle.normal,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(color: Colors.grey[600]),
          textCapitalization: TextCapitalization.words,
          inputFormatters: inputFormatters,
          decoration: _getTextFieldDecoration(),
        ),
      ],
    );
  }

  InputDecoration _getTextFieldDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 12),
      suffixIcon: suffixIcon,
      isDense: true,
      isCollapsed: true,
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      border: _getOutlinedBorder(),
      enabledBorder: _getOutlinedBorder(),
      focusedBorder: _getOutlinedBorder(),
    );
  }

  OutlineInputBorder _getOutlinedBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFE6E8E7)),
    );
  }
}
