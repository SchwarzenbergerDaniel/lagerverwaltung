import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/provider/backgroundinfoprovider.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/service/theme_changing_service.dart';
import 'package:lagerverwaltung/utils/heading_text.dart';
import 'package:lagerverwaltung/widget/background/animated_background.dart';
import 'package:lagerverwaltung/widget/custom_app_bar.dart';
import 'package:provider/provider.dart';

class ColorChangingPage extends StatefulWidget {
  const ColorChangingPage({super.key});

  @override
  _ColorChangingPageState createState() => _ColorChangingPageState();
}

class _ColorChangingPageState extends State<ColorChangingPage> {
  final themeService = GetIt.instance<ThemeChangingService>();
  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  final colors = [
    Color(0xFF4F4F4F), // Dark Grey
    CupertinoColors.systemGrey,
    Color(0xFFD3D3D3), // Light Grey

    CupertinoColors.systemIndigo,

    CupertinoColors.activeBlue,
    CupertinoColors.systemTeal,

    Color(0xFF006400), // Dark Green
    CupertinoColors.activeGreen,
    Color(0xFF90EE90), // Light Green

    Color(0xFF8B0000), // Dark Red
    CupertinoColors.destructiveRed,
    Color(0xFFFFA07A), // Light Red
  ];

  late Color selectedBackgroundColor;
  late Color selectedPrimaryColor;

  @override
  void initState() {
    super.initState();
    selectedBackgroundColor = themeService.backgroundColor;
    selectedPrimaryColor = themeService.primaryColor;
  }

  /// Helper method to build a grid for color selection.
  Widget _buildColorGrid({
    required Color selectedColor,
    required void Function(Color) onColorSelected,
  }) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
          horizontal: 80.0), // space on the outside of the grid
      children: colors.map((color) {
        final isSelected = color.green == selectedColor.green &&
            color.red == selectedColor.red &&
            color.blue == selectedColor.blue;
        return Center(
          child: GestureDetector(
            onTap: () => onColorSelected(color),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? CupertinoColors.black
                      : CupertinoColors.systemGrey2,
                  width: isSelected ? 3.0 : 1.0,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Icon(
                        Icons.check,
                        color: CupertinoColors.white,
                        size: 20,
                      ),
                    )
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movingBlobsProvider = Provider.of<BackgroundInfoProvider>(context);

    return CupertinoPageScaffold(
      navigationBar: CustomAppBar(
        title: 'Farbgebung',
      ),
      child: AnimatedBackground(
        child: Center(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Section for Primary Color
                    HeadingText(text: 'Primärfarbe'),
                    const SizedBox(height: 10),
                    _buildColorGrid(
                      selectedColor: selectedPrimaryColor,
                      onColorSelected: (color) {
                        setState(() {
                          selectedPrimaryColor = color;
                          themeService.setPrimaryColor(
                            CupertinoDynamicColor.withBrightness(
                              color: color,
                              darkColor: color,
                            ),
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    // Section for Background Color
                    HeadingText(text: 'Hintergrundfarbe'),
                    const SizedBox(height: 10),
                    _buildColorGrid(
                      selectedColor: selectedBackgroundColor,
                      onColorSelected: (color) {
                        setState(() {
                          selectedBackgroundColor = color;
                          themeService.setBackgroundColor(
                            CupertinoDynamicColor.withBrightness(
                              color: color,
                              darkColor: color,
                            ),
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    // "Bewegende Blobs" checkmark at the bottom.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Bewegender Hintergrund',
                          style: TextStyle(
                            color: selectedPrimaryColor,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        CupertinoSwitch(
                          value: movingBlobsProvider.isMoving,
                          onChanged: (bool value) {
                            movingBlobsProvider.changeMoving(value);
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Heller Hintergrund',
                          style: TextStyle(
                            color: selectedPrimaryColor,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        CupertinoSwitch(
                          value: movingBlobsProvider.isBright,
                          onChanged: (bool value) {
                            movingBlobsProvider.changeIsBright(value);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
