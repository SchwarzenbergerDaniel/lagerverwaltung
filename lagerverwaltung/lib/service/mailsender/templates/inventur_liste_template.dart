import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/service/jokegenerator_service.dart';
import 'package:lagerverwaltung/service/mailsender/templates/html_template_generator.dart';

class InventurListeTemplate extends HTMLTemplateGenerator {
  late String lagerplatzId;
  InventurListeTemplate({required this.lagerplatzId});
  final jokeService = GetIt.instance<JokegeneratorService>();

  @override
  Future<String> generateContentHTML() async {
    return '''
   <p>Hallo!</p>

<p>
    Ihre Inventurliste wurde erfolgreich erstellt und ist dieser E-Mail als XLSX-Datei beigefügt. 📊
</p>

<h3>Inhalt der Datei:</h3>

<p><strong>📋 Bestandsübersicht:</strong> Alle Artikel mit Soll/Ist-Mengen und Differenzen.</p>
<p><strong>⚠️ Mindestmengen unterschritten:</strong> Artikel, bei denen die Mindestmenge nicht erreicht wurde.</p>
<p><strong>⏳ Ablaufkritische Bestände:</strong> Sortierte Liste bald ablaufender Artikel.</p>

<p><strong>📅 Zeitpunkt der Versendung:</strong> ${getMailDateTimeAsReadableString()}</p>

<p>
    Inventuren kommen mit Witzen:<br />
    <i>${await jokeService.generateJoke()}</i>
</p>

<p><strong>Schönen Tag noch!</strong></p>


  ''';
  }

  @override
  String getTitle() {
    return "Erfolgreiche Inventur – Ihre Bestandsdaten sind aktualisiert 📋";
  }

  @override
  String getSubject() {
    return "Inventur abgeschlossen: Übersicht Ihrer aktuellen Bestände";
  }
}
