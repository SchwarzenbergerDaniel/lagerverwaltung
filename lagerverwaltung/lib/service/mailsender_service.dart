import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:lagerverwaltung/model/LagerlistenEntry.dart';

class MailSenderService {
  // Service-Setup:
  MailSenderService._privateConstructor();
  static final MailSenderService _instance =
      MailSenderService._privateConstructor();
  factory MailSenderService() {
    return _instance;
  }

  // constants:
  static const serviceId = "service_fx0i5yx";
  static const userId = "0d-DwwgVU61_viH3T";

  static const String templateId_message =
      "template_ba9crli"; // For text-based mails.

  // Methods:
  Future sendMessage(
      {required String toMail,
      required String subject,
      required String message}) async {
    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
    await http.post(url,
        headers: {
          "origin": "http://localhost",
          "Content-Type": "application/json"
        },
        body: json.encode({
          "service_id": serviceId,
          "template_id": templateId_message,
          "user_id": userId,
          "template_params": {
            "to_email": toMail,
            "subject": subject,
            "message": message
          }
        }));
  }

  // TODO:
  void sendMindestmengeErreicht(LagerListenEntry entry) {}

  void sendLagerListe(File file) {}

  void sendAbgelaufen(List<LagerListenEntry> abgelaufeneArtikel) {}
}
