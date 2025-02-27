import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';

class BackgroundInfoProvider extends ChangeNotifier {
  final LocalSettingsManagerService _localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  bool _isMoving;
  bool _isBright;

  BackgroundInfoProvider()
      : _isMoving = GetIt.instance<LocalSettingsManagerService>().getIsMoving(),
        _isBright = GetIt.instance<LocalSettingsManagerService>().getIsBright();
  bool get isMoving => _isMoving;
  bool get isBright => _isBright;

  void changeMoving(bool isMoving) {
    _isMoving = isMoving;
    _localSettingsManagerService.setIsMoving(_isMoving);
    notifyListeners();
  }

  void changeIsBright(bool isBright) {
    _isBright = isBright;
    _localSettingsManagerService.setIsBright(_isBright);
    notifyListeners();
  }
}
