import 'dart:io';

import 'package:get_it/get_it.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:lagerverwaltung/model/lagerlistenentry.dart';
import 'package:lagerverwaltung/service/mailsender/templates/inventur_liste_template.dart';
import 'package:lagerverwaltung/service/xlsx_converter_service.dart';
import 'package:lagerverwaltung/service/localstorage_service.dart';
import 'package:lagerverwaltung/service/logger/log_entry.dart';
import 'package:lagerverwaltung/service/logger/logger_service.dart';
import 'package:lagerverwaltung/service/mailsender/templates/abgelaufen_liste_template.dart';
import 'package:lagerverwaltung/service/mailsender/templates/backup_email_template.dart';
import 'package:lagerverwaltung/service/mailsender/templates/html_template_generator.dart';
import 'package:lagerverwaltung/service/mailsender/google_auth_api.dart';
import 'package:lagerverwaltung/service/mailsender/templates/log_entries_template.dart';
import 'package:lagerverwaltung/service/mailsender/templates/mindestmenge_erreicht_template.dart';
import 'package:lagerverwaltung/service/mailsender/templates/mindestmenge_liste_template.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class MailSenderService {
  // Service-Setup:
  MailSenderService._privateConstructor();
  static final MailSenderService _instance =
      MailSenderService._privateConstructor();
  factory MailSenderService() {
    return _instance;
  }

  // INSTANCES
  final loggerService = GetIt.instance<LoggerService>();
  final localStorageService = GetIt.instance<LocalStorageService>();
  final fileConverterService = GetIt.instance<FileConverterService>();

  // CONSTANTS:
  static const String _fromName = "Lagerliste";

  // Methods:
  Future<bool> _sendMessage(
      {required String toMail,
      List<FileAttachment>? attachments,
      required HTMLTemplateGenerator templateGenerator}) async {
    try {
      final user = await GoogleAuthApi.signIn();

      final auth = await user!.authentication;
      final token = auth.accessToken!;
      attachments = attachments ?? [];
      changeFilenames(attachments);

      final mailMessage = Message()
        ..from = Address(user.email, _fromName)
        ..recipients = [
          toMail
        ] // [ toMail,"lukasbrainovic@gmail.com","tobias.nesvadba@gmail.com"]
        ..subject = templateGenerator.getSubject()
        ..attachments = attachments
        ..html = await templateGenerator.getHTML();

      final smtpServer = gmailSaslXoauth2(user.email, token);

      await send(mailMessage, smtpServer);
      return true;
    } catch (e) {
      return false;
    }
  }

  void changeFilenames(List<FileAttachment> attachments) {
    final String timestamp =
        DateFormat("dd.MM.yyyy_HH-mm").format(DateTime.now());

    for (var attachment in attachments) {
      String fileName = attachment.fileName!;
      int lastDotIndex = fileName.lastIndexOf('.');

      if (lastDotIndex != -1) {
        String nameWithoutExtension = fileName.substring(0, lastDotIndex);
        String extension = fileName.substring(lastDotIndex);
        attachment.fileName = "${nameWithoutExtension}_$timestamp$extension";
      } else {
        attachment.fileName = "${fileName}_$timestamp";
      }
    }
  }

  Future<bool> sendLagerListe(
      File file, String toMail, bool isAutomatic) async {
    bool success = await _sendMessage(
      toMail: toMail,
      templateGenerator:
          LagerlisteBackupTemplate(file: file, isAutomatic: isAutomatic),
      attachments: [FileAttachment(file)],
    );
    if (success) {
      loggerService.log(LogEntryModel(
          timestamp: DateTime.now(),
          logReason: LogReason.Backup_Lagerliste_gesendet,
          zusatzInformationen:
              "Empfänger: $toMail | ${isAutomatic ? "Automatisch" : "Manuell"}"));
    }

    return success;
  }

  Future<bool> sendMindestmengeErreicht(
      LagerlistenEntry entry, int amountChange, String toMail) async {
    bool success = await _sendMessage(
        toMail: toMail,
        templateGenerator: MindestmengeErreichtTemplate(
            artikel: entry, amountChange: amountChange));

    if (success) {
      loggerService.log(LogEntryModel(
          timestamp: DateTime.now(),
          logReason: LogReason.Mindestmenge_erreicht_Mail,
          lagerplatzId: entry.lagerplatzId,
          artikelGWID: entry.artikelGWID,
          zusatzInformationen: "Mindestmenge erreicht | EMail gesendet"));
    }

    return success;
  }

  Future<bool> sendAbgelaufen(List<LagerlistenEntry> abgelaufeneArtikel,
      List<LagerlistenEntry> laeuftDemnaestAb, String toMail) async {
    bool success = await _sendMessage(
        toMail: toMail,
        templateGenerator: AbgelaufenListeTemplate(
            abgelaufenListe: abgelaufeneArtikel,
            laeuftDemnaestAb: laeuftDemnaestAb));
    if (success) {
      loggerService.log(
        LogEntryModel(
            timestamp: DateTime.now(),
            logReason: LogReason.Abgelaufen_Artikel_gesendet,
            zusatzInformationen:
                "Empfänger-Email: $toMail | Anzahl abgelaufener Artikel: ${abgelaufeneArtikel.length}"),
      );
      localStorageService.setLastTimeAbgelaufenMailSent();
    }
    return success;
  }

  Future<bool> sendLogs(
      List<LogEntryModel> logEntries, String toMail, bool wasAutomatic) async {
    logEntries.sort((left, right) => left.timestamp.compareTo(right.timestamp));
    File attachment = await fileConverterService.toLogFile(logEntries);

    bool success = await _sendMessage(
        toMail: toMail,
        attachments: [FileAttachment(attachment)],
        templateGenerator: LogsEntriesTemplate(
            entries: logEntries, isAutomatic: wasAutomatic));

    if (success) {
      localStorageService.setLastTimeLogsMailWasSent();

      loggerService.log(
        LogEntryModel(
            timestamp: DateTime.now(),
            logReason: LogReason.Log_Liste_versendet,
            zusatzInformationen: "Empfänger-Email: $toMail"),
      );
    }
    return success;
  }

  Future<bool> sendMindestmengeListe(
      List<LagerlistenEntry> entries, String toMail) async {
    bool success = await _sendMessage(
        toMail: toMail,
        templateGenerator: MindestmengeListeTemplate(artikel: entries));

    if (success) {
      loggerService.log(
        LogEntryModel(
            timestamp: DateTime.now(),
            logReason: LogReason.Alle_abgelaufenen_Artikel_versendet,
            zusatzInformationen:
                "Empfänger-Email: $toMail | Anzahl versendeter Artikel: ${entries.length}"),
      );
    }
    return success;
  }

  Future<bool> sendInventurAbgeschlossen(
      String lagerplatzId, File inventurListe, String toMail) async {
    bool success = await _sendMessage(
        toMail: toMail,
        templateGenerator: InventurListeTemplate(lagerplatzId: lagerplatzId),
        attachments: [FileAttachment(inventurListe)]);

    if (success) {
      loggerService.log(LogEntryModel(
          timestamp: DateTime.now(),
          logReason: LogReason.Inventurliste_gesendet,
          zusatzInformationen: "Empfänger-Email: $toMail"));
    }

    return success;
  }
}
