import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeChangingService with ChangeNotifier {
  CupertinoDynamicColor _primaryColor = CupertinoColors.activeBlue;
  CupertinoDynamicColor _backgroundColor = CupertinoColors.systemBackground;

  CupertinoDynamicColor get primaryColor => _primaryColor;
  CupertinoDynamicColor get backgroundColor =>
      _backgroundColor; // Fixed this line

  /// Load the primary color from SharedPreferences
  Future<void> loadPrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue =
        prefs.getInt('primaryColor') ?? CupertinoColors.activeBlue.value;

    _primaryColor = CupertinoDynamicColor.withBrightness(
      color: Color(colorValue),
      darkColor: Color(colorValue),
    );
    notifyListeners(); // Update UI
  }

  /// Save and set the primary color
  Future<void> setPrimaryColor(CupertinoDynamicColor color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', color.color.value);
    notifyListeners(); // Update UI
  }

  /// Load the background color from SharedPreferences
  Future<void> loadBackgroundColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt('backgroundColor') ??
        CupertinoColors.systemBackground.value;

    _backgroundColor = CupertinoDynamicColor.withBrightness(
      color: Color(colorValue),
      darkColor: Color(colorValue),
    );
    notifyListeners(); // Update UI
  }

  /// Save and set the background color
  Future<void> setBackgroundColor(CupertinoDynamicColor color) async {
    _backgroundColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('backgroundColor', color.color.value);
    notifyListeners(); // Update UI
  }
}
