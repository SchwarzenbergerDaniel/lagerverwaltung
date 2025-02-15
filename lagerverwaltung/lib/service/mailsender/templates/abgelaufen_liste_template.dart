import 'package:lagerverwaltung/model/lagerlistenentry.dart';
import 'package:lagerverwaltung/service/mailsender/templates/html_template_generator.dart';

class AbgelaufenListeTemplate extends HTMLTemplateGenerator {
  late List<LagerlistenEntry> abgelaufenListe;

  AbgelaufenListeTemplate({required this.abgelaufenListe});

  @override
  Future<String> generateContentHTML() async {
    StringBuffer tableRows = _getTableRows();

    return '''
      <p>Hallo!</p>
      <p>Die folgenden Artikel sind abgelaufen oder erreichen heute ihr Mindesthaltbarkeitsdatum:</p>
      <table style="width: 100%; border-collapse: collapse; margin: 20px 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
        <thead style="background-color: #004aad; color: white;">
          <tr>
            <th style="padding: 10px; text-align: left;">Artikel</th>
            <th style="padding: 10px; text-align: center;">Menge</th>
            <th style="padding: 10px; text-align: center;">Mindestmenge</th>
            <th style="padding: 10px; text-align: right;">Ablaufdatum</th>
          </tr>
        </thead>
        <tbody>
          ${tableRows.toString()}
        </tbody>
      </table>
      <p>Bitte prüfen Sie die oben genannten Artikel und ergreifen Sie gegebenenfalls Maßnahmen.</p>
      <p>Vielen Dank und weiterhin eine erfolgreiche Woche!</p>
  ''';
  }

  StringBuffer _getTableRows() {
    StringBuffer tableRows = StringBuffer();
    DateTime today = DateTime.now();

    for (var entry in abgelaufenListe) {
      // Prüfen, ob das Ablaufdatum heute ist
      bool expiresToday = entry.ablaufdatum != null &&
          entry.ablaufdatum!.year == today.year &&
          entry.ablaufdatum!.month == today.month &&
          entry.ablaufdatum!.day == today.day;

      tableRows.write('''
      <tr style="border-bottom: 1px solid #ddd;">
        <td style="padding: 8px; text-align: left;">${entry.beschreibung}</td>
        <td style="padding: 8px; text-align: center;">${entry.menge}</td>
        <td style="padding: 8px; text-align: center;">${entry.mindestMenge}</td>
        <td style="padding: 8px; text-align: right; color: ${expiresToday ? 'orange' : 'red'};">
          ${getMailDateTimeAsReadableString(date: entry.ablaufdatum)}
        </td>
      </tr>
    ''');
    }

    return tableRows;
  }

  @override
  String getTitle() {
    return "Achtung! Abgelaufene Artikel entdeckt 🛒";
  }

  @override
  String getSubject() {
    return "Wichtige Meldung: Abgelaufene Artikel ⚠️";
  }
}
