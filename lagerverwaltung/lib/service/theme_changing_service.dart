// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeChangingService with ChangeNotifier {
  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  CupertinoDynamicColor _primaryColor = CupertinoColors.activeBlue;
  CupertinoDynamicColor _backgroundColor = CupertinoColors.systemBackground;

  CupertinoDynamicColor get primaryColor => _primaryColor;
  CupertinoDynamicColor get backgroundColor =>
      _backgroundColor; // Fixed this line

  bool get istBunt => localSettingsManagerService.getIstBunt();

  Future setIstBunt(bool istBunt) async {
    await localSettingsManagerService.setIstBunt(istBunt);
    notifyListeners();
  }

  Future<void> loadPrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue =
        prefs.getInt('primaryColor') ?? CupertinoColors.activeBlue.value;

    _primaryColor = CupertinoDynamicColor.withBrightness(
      color: Color(colorValue),
      darkColor: Color(colorValue),
    );
    notifyListeners();
  }

  Future<void> setPrimaryColor(CupertinoDynamicColor color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', color.color.value);
    notifyListeners();
  }

  Future<void> loadBackgroundColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue =
        prefs.getInt('backgroundColor') ?? CupertinoColors.systemGrey.value;

    _backgroundColor = CupertinoDynamicColor.withBrightness(
      color: Color(colorValue),
      darkColor: Color(colorValue),
    );
    notifyListeners();
  }

  Future<void> setBackgroundColor(CupertinoDynamicColor color) async {
    _backgroundColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('backgroundColor', color.color.value);
    notifyListeners(); // Update UI
  }
}
