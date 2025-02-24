import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lagerverwaltung/utils/showsnackbar.dart';
import 'package:lagerverwaltung/widget/custom_app_bar.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class CodeScannerService {
  CodeScannerService._privateConstructor();
  static final CodeScannerService _instance =
      CodeScannerService._privateConstructor();
  factory CodeScannerService() => _instance;

  Future<String?> getCodeByScan(BuildContext context, String title) async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      return await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => CodeScannerPage(title: title)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte erlauben Sie den Kamerazugriff')),
      );
    }
    return null;
  }
}

class CodeScannerPage extends StatefulWidget {
  final String title;
  const CodeScannerPage({super.key, required this.title});

  @override
  _CodeScannerPageState createState() => _CodeScannerPageState();
}

class _CodeScannerPageState extends State<CodeScannerPage> {
  MobileScannerController controller = MobileScannerController();
  bool isTorchOn = false;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      BarcodeCapture? capture = await controller.analyzeImage(image.path);
      if (capture == null) {
        Showsnackbar.showSnackBar(context, "Kein QR-Code im Bild erkannt!");
        return;
      }
      _onBarcodeCapture(capture);
    }
  }

  void _onBarcodeCapture(BarcodeCapture? barcode) {
    if (barcode == null) return;
    if (barcode.barcodes.isNotEmpty) {
      String? code = barcode.barcodes[0].rawValue;
      if (code != null) {
        controller.dispose();
        Navigator.of(context).pop(code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate scanning area dimensions based on screen size.
    final screenSize = MediaQuery.of(context).size;
    final squareSize = screenSize.width * 0.7;
    final scanTop = (screenSize.height - squareSize) / 2;
    final scanBottom = scanTop + squareSize;

    return CupertinoPageScaffold(
      navigationBar: CustomAppBar(
        title: widget.title,
        trailing: CupertinoButton(
          child: Icon(
            isTorchOn ? Icons.flash_on : Icons.flash_off,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              isTorchOn = !isTorchOn;
              controller.toggleTorch();
            });
          },
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: controller,
              onDetect: (barcode) {
                _onBarcodeCapture(barcode);
              },
            ),
          ),
          const ScannerOverlay(),
          Positioned(
            top: scanBottom + 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Richte die Kamera auf den QR-Code",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.image, color: Colors.white),
                    onPressed: () async => await pickImage(),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Aus Fotos wählen",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: ScannerOverlayPainter(),
        child: Container(),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());

    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.5);
    canvas.drawRect(Offset.zero & size, overlayPaint);

    final squareSize = size.width * 0.7;
    final left = (size.width - squareSize) / 2;
    final top = (size.height - squareSize) / 2;
    final scanRect = Rect.fromLTWH(left, top, squareSize, squareSize);

    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawRect(scanRect, clearPaint);

    canvas.restore();

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    final cornerLength = squareSize * 0.1;

    canvas.drawLine(
        Offset(left, top), Offset(left + cornerLength, top), linePaint);
    canvas.drawLine(
        Offset(left, top), Offset(left, top + cornerLength), linePaint);

    canvas.drawLine(Offset(left + squareSize, top),
        Offset(left + squareSize - cornerLength, top), linePaint);
    canvas.drawLine(Offset(left + squareSize, top),
        Offset(left + squareSize, top + cornerLength), linePaint);

    canvas.drawLine(Offset(left, top + squareSize),
        Offset(left + cornerLength, top + squareSize), linePaint);
    canvas.drawLine(Offset(left, top + squareSize),
        Offset(left, top + squareSize - cornerLength), linePaint);

    canvas.drawLine(Offset(left + squareSize, top + squareSize),
        Offset(left + squareSize - cornerLength, top + squareSize), linePaint);
    canvas.drawLine(Offset(left + squareSize, top + squareSize),
        Offset(left + squareSize, top + squareSize - cornerLength), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
