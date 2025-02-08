import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';

class ColorModeProvider extends ChangeNotifier {
  final LocalSettingsManagerService _localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  bool _isBunt;

  ColorModeProvider()
      : _isBunt = GetIt.instance<LocalSettingsManagerService>().getIstBunt();

  bool get isBunt => _isBunt;

  void change(bool isBunt) {
    _isBunt = isBunt;
    _localSettingsManagerService.setIstBunt(_isBunt);
    notifyListeners();
  }
}
