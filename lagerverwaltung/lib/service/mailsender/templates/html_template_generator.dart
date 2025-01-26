import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lagerverwaltung/service/mailsender/templates/template_file_constants.dart';

abstract class HTMLTemplateGenerator {
// PUBLIC:
  Future<String> getHTML() async {
    return '''<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Lagerliste-Backup</title>
    <style>
      ${_getCSS()}    </style>
  </head>
  <body>
    <!-- Header -->
    <div class="header">
      <img
        src="${FileConstants.gradwohl_logo_src}" alt="Firmenlogo"
      />
      <h1>${getTitle()}</h1>
    </div>

    <!-- Content -->
    <div
      class="content"
      style="font-family: Arial, sans-serif; line-height: 1.6; color: #333"
    >
      ${await generateContentHTML()}    </div>

    <!-- Footer -->
    <div class="footer">
      <p>
        Diese E-Mail wurde automatisch generiert. Bitte antworten Sie nicht
        direkt auf diese Nachricht.
      </p>
      <p>${_getYear()} © Gradwohl GmbH</p>
    </div>
  </body>
</html>
''';
  }

  // Protected:
  @protected
  String getTitle();

  @protected
  Future<String> generateContentHTML();

  @protected
  String getMailDateTimeAsReadableString({DateTime? date}) {
    date = date ?? DateTime.now();
    final months = [
      "Januar",
      "Februar",
      "März",
      "April",
      "Mai",
      "Juni",
      "Juli",
      "August",
      "September",
      "Oktober",
      "November",
      "Dezember"
    ];
    final formattedDate =
        "${date.day}. ${months[date.month - 1]} ${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    return formattedDate;
  }

  // Private:
  String _getYear() {
    return DateTime.now().year.toString();
  }

  String _getCSS() {
    return '''
 body {
        font-family: Arial, sans-serif;
        margin: 0;
        padding: 0;
        background-color: #f9f9f9;
        color: #333;
      }
      .header {
        background-color: #004aad;
        color: white;
        text-align: center;
        padding: 20px;
      }
      .header img {
        max-width: 75px;
      }
      .header h1 {
        margin: 10px 0 0;
        font-size: 24px;
      }
      .content {
        padding: 30px;
        background: white;
        margin: 20px auto;
        border-radius: 8px;
        max-width: 600px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      }
      .content p {
        margin: 15px 0;
      }
      .footer {
        background-color: #f1f1f1;
        color: #555;
        text-align: center;
        font-size: 14px;
        padding: 10px;
        border-top: 2px solid #004aad;
      }
      .footer p {
        margin: 5px 0;
      }
      .footer a {
        color: #004aad;
        text-decoration: none;
      }
''';
  }
}
