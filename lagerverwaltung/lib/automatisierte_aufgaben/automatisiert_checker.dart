import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/model/lagerlistenentry.dart';
import 'package:lagerverwaltung/service/csv_converter_service.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/service/localstorage_service.dart';
import 'package:lagerverwaltung/service/logger/log_entry.dart';
import 'package:lagerverwaltung/service/logger/logger_service.dart';
import 'package:lagerverwaltung/service/mailsender/mailsender_service.dart';
import 'dart:async';

class AutomatisiertChecker {
  final localStorageService = GetIt.instance<LocalStorageService>();
  final mailSenderService = GetIt.instance<MailSenderService>();
  final fileConverterService = GetIt.instance<FileConverterService>();
  final lagerlistenVerwatlungsService =
      GetIt.instance<LagerlistenVerwaltungsService>();
  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();
  final loggerService = GetIt.instance<LoggerService>();

  //Do not call this method multiple times! The call at the launch of the app is enough.
  void checkTodo() async {
    _checkAbgelaufen();
    _checkBackup();
    await _checkDeleteLogs();
    _checkLogMail();
    scheduleDailyCheck();
  }

  void scheduleDailyCheck() {
    final now = DateTime.now();
    final nextDay = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
    final durationTillNextDay = nextDay.difference(now);
    Timer(durationTillNextDay, () {
      checkTodo();
    });
  }

  // CHECK Abgelaufene Artikel.
  void _checkAbgelaufen() async {
    DateTime lastTime =
        await localStorageService.getLastTimeAbgelaufenMailSent();
    DateTime today = DateTime.now();
    if (lastTime.day != today.day ||
        lastTime.month != today.month ||
        lastTime.year != today.year) {
      // Mail mit abgelaufenen Artikeln schicken!
      List<LagerlistenEntry> abgelaufeneArtikel =
          await lagerlistenVerwatlungsService.getAbgelaufeneArtikel();
      abgelaufeneArtikel = abgelaufeneArtikel
          .where((val) => val.ablaufdatum!
              .isAfter(lastTime)) // Nur jene, die noch nie versendet wurden.
          .toList();
      if (abgelaufeneArtikel.isNotEmpty) {
        mailSenderService.sendAbgelaufen(
            abgelaufeneArtikel, localSettingsManagerService.getMail());
      }
    }
  }

  // CHECK Backup

  void _checkBackup() async {
    DateTime lastBackup = await localStorageService.getLastBackup();
    if (!_isLastBackupInThisCalenderWeek(lastBackup)) {
      mailSenderService.sendLagerListe(
          await fileConverterService
              .toCsv(await lagerlistenVerwatlungsService.artikelEntries),
          localSettingsManagerService.getMail(),
          true);
      localStorageService.setLastBackup();
    }
  }

  bool _isLastBackupInThisCalenderWeek(DateTime lastBackup) {
    DateTime today = DateTime.now();

    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    startOfWeek =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    return lastBackup.isBefore(startOfWeek);
  }

  // LOG MAIL

  void _checkLogMail() async {
    DateTime lastBackup =
        await localStorageService.getLastTimeLogsMailWasSent();
    int neededDifference =
        localSettingsManagerService.getIntervallLogMailDays();

    if (DateTime.now().difference(lastBackup).inDays >= neededDifference) {
      mailSenderService.sendLogs(await loggerService.getLogs(),
          localSettingsManagerService.getMail(), true);
    }
  }

  Future _checkDeleteLogs() async {
    List<LogEntryModel> logs = await loggerService.getLogs();
    int deleteLogsAfterDays =
        localSettingsManagerService.getDeleteLogsAfterDays();
    logs = logs
        .where((element) => element.timestamp.isAfter(
            DateTime.now().subtract(Duration(days: deleteLogsAfterDays))))
        .toList();
    await loggerService.clearLogs();
    await loggerService.setLogs(logs);
  }
}
