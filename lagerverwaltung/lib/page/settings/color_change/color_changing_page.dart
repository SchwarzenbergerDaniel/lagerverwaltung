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

class ColorCombination {
  final Color primary;
  final Color background;

  ColorCombination({required this.primary, required this.background});
}

class ColorChangingPage extends StatefulWidget {
  const ColorChangingPage({super.key});

  @override
  _ColorChangingPageState createState() => _ColorChangingPageState();
}

class _ColorChangingPageState extends State<ColorChangingPage> {
  final themeService = GetIt.instance<ThemeChangingService>();
  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  final List<ColorCombination> colorCombinations = [
    ColorCombination(
        primary: CupertinoColors.systemTeal,
        background: Color(0xFF4F4F4F)), // Teal + Dunkelgrau

    ColorCombination(
        primary: CupertinoColors.systemOrange,
        background: Color(0xFF2E2E2E)), // Orange + Schwarzgrau

    ColorCombination(
        primary: CupertinoColors.systemIndigo,
        background: Color(0xFF1F1F3D)), // Indigo + Dunkelblau

    ColorCombination(
        primary: CupertinoColors.systemPink,
        background: Color(0xFF3B3B3B)), // Pink + Mittelgrau

    ColorCombination(
        primary: CupertinoColors.systemGreen,
        background: Color(0xFF252525)), // Grün + Sehr dunkles Grau

    ColorCombination(
        primary: CupertinoColors.systemPurple,
        background: Color(0xFF2A1A40)), // Lila + Dunkellila

    ColorCombination(
        primary: CupertinoColors.systemYellow,
        background: Color(0xFF303030)), // Gelb + Dunkelgrau

    ColorCombination(
        primary: CupertinoColors.systemRed,
        background: Color(0xFF0D0D30)), // Rot + Dunkelblau
  ];

  int selectedCombinationIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedCombinationIndex = 0;
  }

  Widget _buildCombinationGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: colorCombinations.length,
      itemBuilder: (context, index) {
        final combination = colorCombinations[index];
        final primaryColor = Theme.of(context).primaryColor;
        final isSelected = combination.primary.r == primaryColor.r &&
            combination.primary.g == primaryColor.g &&
            combination.primary.b == primaryColor.b;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCombinationIndex = index;
              themeService.setPrimaryColor(
                CupertinoDynamicColor.withBrightness(
                  color: combination.primary,
                  darkColor: combination.primary,
                ),
              );
              themeService.setBackgroundColor(
                CupertinoDynamicColor.withBrightness(
                  color: combination.background,
                  darkColor: combination.background,
                ),
              );
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey2,
                    width: isSelected ? 3.0 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: combination.background,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8.0)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: combination.primary,
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(8.0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check,
                  color: CupertinoColors.white,
                  size: 30,
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final movingBlobsProvider = Provider.of<BackgroundInfoProvider>(context);
    final colorProvider = Provider.of<ThemeChangingService>(context);

    return CupertinoPageScaffold(
      navigationBar: CustomAppBar(
        title: 'Farbkombination wählen',
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
                    HeadingText(text: 'Farbkombination'),
                    const SizedBox(height: 10),
                    _buildCombinationGrid(),
                    const SizedBox(height: 30),
                    _buildSwitchRow(
                      label: 'Bewegender Hintergrund',
                      value: movingBlobsProvider.isMoving,
                      onChanged: movingBlobsProvider.changeMoving,
                    ),
                    const SizedBox(height: 10),
                    _buildSwitchRow(
                      label: 'Heller Hintergrund',
                      value: movingBlobsProvider.isBright,
                      onChanged: movingBlobsProvider.changeIsBright,
                    ),
                    const SizedBox(height: 10),
                    _buildSwitchRow(
                      label: 'Bunter Modus',
                      value: colorProvider.istBunt,
                      onChanged: themeService.setIstBunt,
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

  Widget _buildSwitchRow({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorCombinations[selectedCombinationIndex].primary,
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 10),
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
