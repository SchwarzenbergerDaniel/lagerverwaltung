import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:lagerverwaltung/service/mailsender/templates/html_template_generator.dart';
import 'package:http/http.dart' as http;

class LagerlisteBackupTemplate extends HTMLTemplateGenerator {
  // INSTANCES:
  late File file;
  late bool isAutomatic;

  LagerlisteBackupTemplate({required this.file, required this.isAutomatic});

  // METHODS:
  @override
  Future<String> generateContentHTML() async {
    if (isAutomatic) {
      return generateAutomaticBackupContent();
    }
    return generateManuellBackupContent();
  }

  String generateManuellBackupContent() {
    return '''
      <p>Hallo!</p>
      <p>
          Ihr manuell ausgelöstes Backup wurde erfolgreich erstellt und liegt dieser E-Mail als CSV-Datei bei.  
      </p>
     <p>
          Zeitpunkt der Backup-Erstellung: ${getMailDateTimeAsReadableString()}      </p>
      <p>Noch einen schönen Tag!</p>
    ''';
  }

  Future<String> generateAutomaticBackupContent() async {
    return '''
      <p>Hallo!</p>
      <p>
        Ein automatisches Backup der Lagerliste wurde erstellt und als CSV-Datei
        an diese E-Mail angehängt.
      </p>
      <p>
        Zeitpunkt der Backup-Erstellung: ${getMailDateTimeAsReadableString()}     
      <p>
      <p>
        Automatisierte Backups kommen mit einem Witz der Woche:<br />
        <i>${await generateJoke()} </i>
      </p>
      <p>Noch eine gute Woche!</p>
      ''';
  }

  @override
  String getTitle() {
    return isAutomatic
        ? "Automatisches Backup erfolgreich erstellt! 🚀"
        : "Ihr Backup wurde erfolgreich erstellt ✅";
  }

  @override
  String getSubject() {
    return isAutomatic
        ? "Automatisches Backup erfolgreich erstellt! 🚀"
        : "Ihr Backup wurde erfolgreich erstellt ✅";
  }

  Future<String> generateJoke() async {
    try {
      final response = await http.get(
        Uri.parse("https://witzapi.de/api/joke/?limit=1&language=de"),
      );
      final decodedResponse = json.decode(response.body);
      return decodedResponse[0]['text'];
    } catch (e) {
      return getRandomPreDefinedJoke();
    }
  }

  String getRandomPreDefinedJoke() {
    List<String> preDefinedJokes = [
      // TODO: HAUTS BANGER WITZE REIN.
      "Warum können Geister so schlecht lügen? – Weil man durch sie hindurchsehen kann!",
      "Warum hat der Pilz gute Laune? – Weil er aus der Erde springt!",
      "Was macht ein Pirat am Computer? – Er drückt die Enter-Taste!"
    ];
    final random = Random();
    return preDefinedJokes[random.nextInt(preDefinedJokes.length)];
  }
}
