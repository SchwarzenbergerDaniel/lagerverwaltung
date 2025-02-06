import 'package:flutter/material.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';
import 'package:lagerverwaltung/utils/showsnackbar.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:lagerverwaltung/config/constants.dart';

class CodeScannerService {
  // Service-Setup:
  CodeScannerService._privateConstructor();
  static final CodeScannerService _instance =
      CodeScannerService._privateConstructor();
  factory CodeScannerService() {
    return _instance;
  }

  // Methods:
  Future<String?> getCodeByScan(BuildContext context, String title) async {
    String? qrCodeResult;

    var status = await Permission.camera.request();
    if (status.isGranted) {
      qrCodeResult = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CodeScannerScreen(
            title: title,
          ),
        ),
      );
    } else {
      Showsnackbar.showSnackBar(
          context, 'Bitte erlauben Sie den Kamerazugriff');
    }
    return qrCodeResult;
  }
}

// ignore: must_be_immutable
class CodeScannerScreen extends StatefulWidget {
  String title;
  CodeScannerScreen({super.key, required this.title});

  @override
  _CodeScannerScreenState createState() => _CodeScannerScreenState();
}

class _CodeScannerScreenState extends State<CodeScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  bool isTorchOn = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          widget.title,
          style: CupertinoTheme.of(context).textTheme.textStyle,
        ),
        leading: CustomBackButton(onPressed: () {
          Navigator.of(context).pop(Constants.EXIT_RETURN_VALUE);
        }),
        trailing: CupertinoButton(
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.all(12),
          borderRadius: BorderRadius.circular(20),
          onPressed: () {
            setState(() {
              isTorchOn = !isTorchOn;
              controller.toggleTorch();
            });
          },
          child: Icon(
            isTorchOn ? Icons.lightbulb_sharp : Icons.lightbulb_outline,
            color: CupertinoTheme.of(context).primaryColor,
          ),
        ),
      ),
      child: MobileScanner(
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
