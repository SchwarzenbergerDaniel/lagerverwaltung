import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/provider/colormodeprovider.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/service/theme_changing_service.dart';
import 'package:lagerverwaltung/utils/heading_text.dart';
import 'package:lagerverwaltung/widget/background/animated_background.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';
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
    CupertinoColors.activeBlue,
    CupertinoColors.activeGreen,
    CupertinoColors.activeOrange,
    CupertinoColors.destructiveRed,
    CupertinoColors.systemPink,
    CupertinoColors.systemPurple,
    CupertinoColors.systemYellow,
    CupertinoColors.systemTeal,
    CupertinoColors.systemIndigo,
    CupertinoColors.systemGrey,
  ];

  late ColorModeProvider colorModeProvider;
  late Color selectedBackgroundColor;
  late Color selectedPrimaryColor;
  late bool isBunt;

  @override
  void initState() {
    super.initState();
    selectedBackgroundColor = themeService.backgroundColor;
    selectedPrimaryColor = themeService.primaryColor;
    isBunt = localSettingsManagerService.getIstBunt();
  }

  @override
  Widget build(BuildContext context) {
    colorModeProvider = Provider.of<ColorModeProvider>(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CustomBackButton(),
      ),
      child: AnimatedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HeadingText(text: 'Farbgebung'),
                const SizedBox(height: 30),
                const Text(
                  'Wähle eine Primärfarbe:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: colors.map((color) {
                    final isSelected = color == selectedPrimaryColor;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPrimaryColor = color;
                          themeService.setPrimaryColor(
                              CupertinoDynamicColor.withBrightness(
                            color: color,
                            darkColor: color,
                          ));
                        });
                      },
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
                                  color: color.computeLuminance() > 0.5
                                      ? CupertinoColors.black
                                      : CupertinoColors.white,
                                  size: 20,
                                ),
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
