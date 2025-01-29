import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/service/theme_changing_service.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';
import 'package:provider/provider.dart';

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

  void _openColorPicker(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: const Text('Wähle eine Farbe'),
        content: SizedBox(
          height: 200,
          child: SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.center, 
              spacing: 8.0,
              runSpacing: 8.0,
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    Provider.of<ThemeChangingService>(context, listen: false)
                        .setPrimaryColor(CupertinoDynamicColor.withBrightness(
                      color: color,
                      darkColor: color,
                    ));
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(color: CupertinoColors.systemGrey2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Primärfarbe ändern'),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: CustomBackButton(),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              CupertinoButton.filled(
                onPressed: () => _openColorPicker(context),
                child: const Text('Farbe auswählen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
