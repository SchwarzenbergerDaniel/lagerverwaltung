import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:lagerverwaltung/config/constants.dart';
import 'package:lagerverwaltung/model/LagerlistenEntry.dart';
import 'package:lagerverwaltung/service/mailsender/google_auth_api.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

//TODO: Always add to logs => Will do that in the next PR.
class MailSenderService {
  // Service-Setup:
  MailSenderService._privateConstructor();
  static final MailSenderService _instance =
      MailSenderService._privateConstructor();
  factory MailSenderService() {
    return _instance;
  }

  // CONSTANTS:
  static const String _fromName = "Lagerliste";

  // Methods:
  Future<void> sendMessage({
    required String toMail,
    required String subject,
    required String message,
    Map<String, dynamic>? attachment,
  }) async {
    try {
      final user = await GoogleAuthApi.signIn();
      if (user == null) return;

      final auth = await user.authentication;
      final token = auth.accessToken!;

//TODO: Change to html
      final mailMessage = Message()
        ..from = Address(user.email, _fromName)
        ..recipients = [toMail]
        ..subject = subject
        ..text = message;

      final smtpServer = gmailSaslXoauth2(user.email, token);

      await send(mailMessage, smtpServer);
    } catch (e) {}
  }

  // TODO: DONT FORGET TO LOG.
  void sendMindestmengeErreicht(LagerListenEntry entry) {}

  void sendLagerListe(File file, String toMail) async {
    //TODO: Schön machen.
    final user = await GoogleAuthApi.signIn();
    if (user == null) return;

    final auth = await user.authentication;
    final token = auth.accessToken!;

    final mailMessage = Message()
      ..from = Address(user.email, _fromName)
      ..recipients = [toMail]
      ..subject = "Backup"
      ..attachments = [FileAttachment(file)]
      ..html = "<h1>Jippie</h1>";

    final smtpServer = gmailSaslXoauth2(user.email, token);

    await send(mailMessage, smtpServer);
  }

  void sendAbgelaufen(List<LagerListenEntry> abgelaufeneArtikel) {}
}
