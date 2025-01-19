import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/model/LagerlistenEntry.dart';
import 'package:lagerverwaltung/service/csv_converter_service.dart';
import 'package:lagerverwaltung/service/lagerlistenverwatlung_service.dart';
import 'package:lagerverwaltung/service/localstorage_service.dart';
import 'package:lagerverwaltung/service/mailsender_service.dart';

class AutomatisiertChecker {
  final localStorageService = GetIt.instance<LocalStorageService>();
  final mailSenderService = GetIt.instance<MailSenderService>();
  final csvConverterService = GetIt.instance<CsvConverterService>();
  final lagerlistenVerwatlungsService =
      GetIt.instance<LagerlistenVerwatlungsService>();

  void checkTodo() {
    _checkAbgelaufen();
    _checkBackup();
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
      List<LagerListenEntry> abgelaufeneArtikel = _getAbgelaufeneArtikel();
      abgelaufeneArtikel = abgelaufeneArtikel
          .where((val) => val.ablaufdatum!
              .isAfter(lastTime)) // Nur jene, die noch nie versendet wurden.
          .toList();
      if (abgelaufeneArtikel.isNotEmpty) {
        mailSenderService.sendAbgelaufen(abgelaufeneArtikel);
        localStorageService.setLastTimeAbgelaufenMailSent();
      }
    }
  }

  List<LagerListenEntry> _getAbgelaufeneArtikel() {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    return lagerlistenVerwatlungsService.lagerlistenEntries.where((val) {
      if (val.ablaufdatum != null) {
        DateTime ablaufDate = DateTime(
          val.ablaufdatum!.year,
          val.ablaufdatum!.month,
          val.ablaufdatum!.day,
        );
        return ablaufDate.isBefore(today) || ablaufDate.isAtSameMomentAs(today);
      }
      return false;
    }).toList();
  }

  // CHECK Backup

  void _checkBackup() async {
    DateTime lastBackup = await localStorageService.getLastBackup();
    if (!_isLastBackupInThisCalenderWeek(lastBackup)) {
      mailSenderService.sendLagerListe(csvConverterService
          .toCsv(lagerlistenVerwatlungsService.lagerlistenEntries));
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
}
