import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/model/LagerlistenEntry.dart';
import 'package:lagerverwaltung/service/logger/log_entry.dart';
import 'package:lagerverwaltung/service/logger/logger_service.dart';
import 'package:lagerverwaltung/service/mailsender/templates/abgelaufen_liste_template.dart';
import 'package:lagerverwaltung/service/mailsender/templates/backup_email_template.dart';
import 'package:lagerverwaltung/service/mailsender/templates/html_template_generator.dart';
import 'package:lagerverwaltung/service/mailsender/google_auth_api.dart';
import 'package:lagerverwaltung/service/mailsender/templates/mindestmenge_erreicht_template.dart';
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

  // CONSTANTS:
  static const String _fromName = "Lagerliste";

  // Methods:
  Future<void> _sendMessage(
      {required String toMail,
      List<FileAttachment>? attachments,
      required HTMLTemplateGenerator templateGenerator}) async {
    try {
      final user = await GoogleAuthApi.signIn();

      final auth = await user!.authentication;
      final token = auth.accessToken!;
      attachments = attachments ?? [];

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
    } catch (e) {}
  }

  void sendLagerListe(File file, String toMail, bool isAutomatic) {
    _sendMessage(
      toMail: toMail,
      templateGenerator:
          LagerlisteBackupTemplate(file: file, isAutomatic: isAutomatic),
      attachments: [FileAttachment(file)],
    );
    loggerService.log(LogEntryModel(
        timestamp: DateTime.now(),
        logReason: LogReason.Backup_Lagerliste_gesendet,
        zusatzInformationen:
            "Empfänger: $toMail | Manuell getriggered: ${isAutomatic ? "Ja" : "Nein"}"));
  }

  void sendMindestmengeErreicht(
      LagerListenEntry entry, int amountChange, String toMail) {
    _sendMessage(
        toMail: toMail,
        templateGenerator: MindestmengeErreichtTemplate(
            artikel: entry, amountChange: amountChange));
    loggerService.log(LogEntryModel(
        timestamp: DateTime.now(),
        logReason:
            amountChange > 0 ? LogReason.Einlagerung : LogReason.Auslagerung,
        lagerplatzId: entry.lagerplatzId,
        artikelGWID: entry.artikelGWID,
        zusatzInformationen: "Mindestmenge erreicht, EMail gesendet"));
  }

  void sendAbgelaufen(
      List<LagerListenEntry> abgelaufeneArtikel, String toMail) {
    _sendMessage(
        toMail: toMail,
        templateGenerator:
            AbgelaufenListeTemplate(abgelaufenListe: abgelaufeneArtikel));
    loggerService.log(
      LogEntryModel(
          timestamp: DateTime.now(),
          logReason: LogReason.Abgelaufen_Artikel_gesendet,
          zusatzInformationen:
              "Empfänger-Email: $toMail | Anzahl abgelaufener Artikel: ${abgelaufeneArtikel.length}"),
    );
  }
}
