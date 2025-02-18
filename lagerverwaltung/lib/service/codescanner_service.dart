import 'package:flutter/material.dart';
import 'package:lagerverwaltung/utils/showsnackbar.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
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
      qrCodeResult = await showDialog<String?>(
        context: context,
        barrierDismissible: false,
        builder: (context) => CodeScannerPopup(title: title),
      );
    } else {
      Showsnackbar.showSnackBar(
          context, 'Bitte erlauben Sie den Kamerazugriff');
    }
    return qrCodeResult;
  }
}

class CodeScannerPopup extends StatefulWidget {
  final String title;
  const CodeScannerPopup({super.key, required this.title});

  @override
  _CodeScannerPopupState createState() => _CodeScannerPopupState();
}

class _CodeScannerPopupState extends State<CodeScannerPopup> {
  MobileScannerController controller = MobileScannerController();
  bool isTorchOn = false;

  @override
  Widget build(BuildContext context) {
    // Determine a size for the popup based on screen size.
    final popupWidth = MediaQuery.of(context).size.width * 0.8;
    final popupHeight = MediaQuery.of(context).size.height * 0.5;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: popupWidth,
            height: popupHeight,
            color: Colors.black,
            child: Stack(
              children: [
                // Camera preview fills the container.
                Positioned.fill(
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
                ),
                // Overlay with scanning guide (clear square with corner markers)
                const ScannerOverlay(),
                // Header bar with back button and title.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      color: Colors.black.withOpacity(0.3),
                      child: Row(
                        children: [
                          // Back button (or replace with your CustomBackButton if desired)
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(Constants.EXIT_RETURN_VALUE);
                            },
                          ),
                          Expanded(
                            child: Text(widget.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18)),
                          ),
                          // Empty space to balance the layout.
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 32,
                        icon: Icon(
                          isTorchOn ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            isTorchOn = !isTorchOn;
                            controller.toggleTorch();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop(Constants.EXIT_RETURN_VALUE);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          'Abbrechen',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
      // Ensures touches pass through the overlay to the MobileScanner.
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
    // Save the current canvas state.
    canvas.saveLayer(Offset.zero & size, Paint());

    // Draw a semi-transparent overlay over the entire container.
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.5);
    canvas.drawRect(Offset.zero & size, overlayPaint);

    // Define the scanning square (70% of container's width).
    final squareSize = size.width * 0.7;
    final left = (size.width - squareSize) / 2;
    final top = (size.height - squareSize) / 2;
    final scanRect = Rect.fromLTWH(left, top, squareSize, squareSize);

    // Clear the scanning square area so the camera preview is visible.
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawRect(scanRect, clearPaint);

    // Set up the paint for drawing the corner lines.
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square;

    // Define the length of each corner line (10% of the square's size).
    final cornerLength = squareSize * 0.1;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      linePaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left, top + cornerLength),
      linePaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(left + squareSize, top),
      Offset(left + squareSize - cornerLength, top),
      linePaint,
    );
    canvas.drawLine(
      Offset(left + squareSize, top),
      Offset(left + squareSize, top + cornerLength),
      linePaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, top + squareSize),
      Offset(left + cornerLength, top + squareSize),
      linePaint,
    );
    canvas.drawLine(
      Offset(left, top + squareSize),
      Offset(left, top + squareSize - cornerLength),
      linePaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + squareSize, top + squareSize),
      Offset(left + squareSize - cornerLength, top + squareSize),
      linePaint,
    );
    canvas.drawLine(
      Offset(left + squareSize, top + squareSize),
      Offset(left + squareSize, top + squareSize - cornerLength),
      linePaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
