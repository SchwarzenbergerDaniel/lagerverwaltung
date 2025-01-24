import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:lagerverwaltung/config/constants.dart';
import 'package:lagerverwaltung/model/LagerlistenEntry.dart';

//TODO: Always add to logs => Will do that in the next PR.
class MailSenderService {
  // Service-Setup:
  MailSenderService._privateConstructor();
  static final MailSenderService _instance =
      MailSenderService._privateConstructor();
  factory MailSenderService() {
    return _instance;
  }

  // constants:
  static const _serviceId = "service_fx0i5yx";
  static const _userId = "0d-DwwgVU61_viH3T";

  static const String _templateIdMessage =
      "template_ba9crli"; // For text-based mails.

  // Methods:
  Future<void> sendMessage({
    required String toMail,
    required String subject,
    required String message,
    Map<String, dynamic>? attachment,
  }) async {
    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
    await http.post(url,
        headers: {
          "origin": "http://localhost",
          "Content-Type": "application/json"
        },
        body: json.encode({
          "service_id": _serviceId,
          "template_id": _templateIdMessage,
          "user_id": _userId,
          "template_params": {
            "to_email": toMail,
            "subject": subject,
            "message": message,
            "attachment": attachment != null ? [attachment] : null,
          }
        }));
  }

  // TODO:
  void sendMindestmengeErreicht(LagerListenEntry entry) {}

  void sendLagerListe(File file) async {
    try {
      final fileBytes = await file.readAsBytes();
      final base64File = base64Encode(fileBytes);

      final attachment = {
        "name": file.uri.pathSegments.last,
        "data": base64File,
      };

      await sendMessage(
        toMail: Constants.TO_MAIL_DEFAULT,
        subject: "LagerListe",
        message: "Moin moin",
        attachment: attachment,
      );
    } catch (e) {}
  }

  void sendAbgelaufen(List<LagerListenEntry> abgelaufeneArtikel) {}
}
