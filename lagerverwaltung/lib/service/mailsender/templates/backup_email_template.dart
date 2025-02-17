import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/service/jokegenerator_service.dart';
import 'package:lagerverwaltung/service/mailsender/templates/html_template_generator.dart';

class LagerlisteBackupTemplate extends HTMLTemplateGenerator {
  // INSTANCES:
  late File file;
  late bool isAutomatic;
  final jokeService = GetIt.instance<JokegeneratorService>();

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
          Ihr manuell ausgelöstes Backup wurde erfolgreich erstellt und liegt dieser E-Mail als XLSX-Datei bei.  
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
        Ein automatisches Backup der Lagerliste wurde erstellt und als XLSX-Datei
        an diese E-Mail angehängt.
      </p>
      <p>
        Zeitpunkt der Backup-Erstellung: ${getMailDateTimeAsReadableString()}     
      <p>
      <p>
        Automatisierte Backups kommen mit einem Witz der Woche:<br />
        <i>${await jokeService.generateJoke()} </i>
      </p>
      <p>Noch eine gute Woche!</p>
      ''';
  }

  @override
  String getTitle() {
    return isAutomatic
        ? "Automatisiertes Backup erstellt! 🚀"
        : "Backup erfolgreich erstellt! ✅";
  }

  @override
  String getSubject() {
    return isAutomatic
        ? "Gute Neuigkeiten: Ihr automatisches Backup wurde erstellt 🚀"
        : "Erfolg: Ihr manuelles Backup wurde erstellt ✅";
  }
}
