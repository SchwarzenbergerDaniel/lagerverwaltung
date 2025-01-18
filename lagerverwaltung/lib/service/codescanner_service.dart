import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class CodeScannerService {
  // Service-Setup:
  CodeScannerService._privateConstructor();
  static final CodeScannerService _instance =
      CodeScannerService._privateConstructor();
  factory CodeScannerService() {
    return _instance;
  }

  // Methods:
  Future<String?> getCodeByScan(BuildContext context) async {
    String? qrCodeResult;

    var status = await Permission.camera.request();
    if (status.isGranted) {
      qrCodeResult = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CodeScannerScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bitte erlauben Sie den Kamerazugriff')),
      );
    }
    return qrCodeResult;
  }
}

class CodeScannerScreen extends StatefulWidget {
  @override
  _CodeScannerScreenState createState() => _CodeScannerScreenState();
}

class _CodeScannerScreenState extends State<CodeScannerScreen> {
  MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR Code Scanner')),
      body: MobileScanner(
        controller: controller,
        onDetect: (barcode) {
          if (barcode.barcodes.isNotEmpty) {
            String? code = barcode.barcodes[0].rawValue;
            if (code != null) {
              controller.dispose();
              Navigator.of(context).pop(code);
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
