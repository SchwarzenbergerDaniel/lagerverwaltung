import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/service/theme_changing_service.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';

class ColorChangingPage extends StatefulWidget {
  const ColorChangingPage({super.key});

  @override
  _ColorChangingPageState createState() => _ColorChangingPageState();
}

class _ColorChangingPageState extends State<ColorChangingPage> {
  final themeService = GetIt.instance<ThemeChangingService>();

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

  late Color selectedBackgroundColor;
  late Color selectedPrimaryColor;

  @override
  void initState() {
    super.initState();
    selectedBackgroundColor = themeService.backgroundColor;
    selectedPrimaryColor = themeService.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColors = {
      'Weiß': CupertinoColors.white,
      'Schwarz': CupertinoColors.black,
    };

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Anpassung der Farben',
          style: CupertinoTheme.of(context).textTheme.textStyle,
        ),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: CustomBackButton(),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Hintergrundfarbe ändern:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10.0,
                children: backgroundColors.keys.map((label) {
                  final color = backgroundColors[label]!;
                  final isSelected = color == selectedBackgroundColor;

                  return CupertinoButton(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: isSelected
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey,
                    borderRadius: BorderRadius.circular(8),
                    onPressed: () {
                      setState(() {
                        selectedBackgroundColor = color;
                        themeService.setBackgroundColor(
                            CupertinoDynamicColor.withBrightness(
                          color: selectedBackgroundColor,
                          darkColor: selectedBackgroundColor,
                        ));
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: isSelected
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isSelected)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.check,
                              color: CupertinoColors.white,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
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
    );
  }
}
