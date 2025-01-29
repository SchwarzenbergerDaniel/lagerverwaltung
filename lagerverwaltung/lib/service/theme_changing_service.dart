import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeChangingService with ChangeNotifier {
  CupertinoDynamicColor _primaryColor = CupertinoColors.activeBlue;

  CupertinoDynamicColor get primaryColor => _primaryColor;

  Future<void> loadPrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt('primaryColor') ?? CupertinoColors.activeBlue.value;

    _primaryColor = CupertinoDynamicColor.withBrightness(
      color: Color(colorValue),
      darkColor: Color(colorValue),
    );
    notifyListeners(); // UI aktualisieren
  }

  Future<void> setPrimaryColor(CupertinoDynamicColor color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', color.color.value);
    notifyListeners(); // UI aktualisieren
  }
}