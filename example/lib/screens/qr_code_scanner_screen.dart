import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QRCodeScannerScreen extends StatefulWidget {
  const QRCodeScannerScreen({super.key});

  @override
  QRCodeScannerScreenState createState() => QRCodeScannerScreenState();
}

class QRCodeScannerScreenState extends State<QRCodeScannerScreen> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // Handle camera reinitialization during hot reload
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanner')),
      body: _buildQrView(context),
    );
  }

  Widget _buildQrView(BuildContext context) {
    final scanArea = MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400
        ? 250.0
        : 300.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.blue,
        borderRadius: 10,
        borderLength: 20,
        borderWidth: 5,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, permissionGranted) =>
          _onPermissionSet(context, permissionGranted),
    );
  }

  void _onQRViewCreated(QRViewController qrController) {
    setState(() {
      controller = qrController;
    });
    qrController.scannedDataStream.listen((scanData) {
      controller?.pauseCamera(); // Stop scanning further
      if(mounted) {
        Navigator.pop(context, scanData.code); // Return the result
      }
    });
  }

  void _onPermissionSet(BuildContext context, bool permissionGranted) {
    if (!permissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission not granted!')),
      );
      Navigator.pop(context, null); // Return null if no permission
    }
  }
}
