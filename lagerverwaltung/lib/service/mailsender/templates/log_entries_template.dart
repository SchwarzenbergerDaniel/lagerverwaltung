import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/service/jokegenerator_service.dart';
import 'package:lagerverwaltung/service/logger/log_entry.dart';
import 'package:lagerverwaltung/service/mailsender/templates/html_template_generator.dart';

class LogsEntriesTemplate extends HTMLTemplateGenerator {
  // Instances
  late List<LogEntryModel> entries;
  late bool isAutomatic;
  LogsEntriesTemplate({required this.entries, required this.isAutomatic});
  final jokeService = GetIt.instance<JokegeneratorService>();

  // METHODS:
  @override
  Future<String> generateContentHTML() async {
    if (isAutomatic) {
      return generateAutomaticLogs();
    }
    return generateManuellLogs();
  }

  String generateManuellLogs() {
    return '''
      <p>Hallo!</p>
      <p>
          Ihr manuell ausgelöste Aktivitäts-Liste wurde erfolgreich erstellt und liegt dieser E-Mail als TXT-Datei bei.  
      </p>
     <p>
          Zeitpunkt der Aktivitäts-Versendung: ${getMailDateTimeAsReadableString()}      </p>
      <p>Noch einen schönen Tag!</p>
    ''';
  }

  Future<String> generateAutomaticLogs() async {
    return '''
      <p>Hallo!</p>
      <p>
        Ein automatische Versendung der Aktivität wird durchgeführt und als TXT-Datei
        an diese E-Mail angehängt.
      </p>
      <p>
        Zeitpunkt der Aktivitäts-Versendung: ${getMailDateTimeAsReadableString()}     
      <p>
      <p>
        Automatisierte Aktivitäts-Listen kommen mit einem Witz:<br />
        <i>${await jokeService.generateJoke()} </i>
      </p>
      <p>Noch eine gute Woche!</p>
      ''';
  }

  @override
  String getTitle() {
    return isAutomatic
        ? "Automatisiert generierte Aktivitäts-Liste! 🚀"
        : "Aktivitäts-Liste erfolgreich versendet! ✅";
  }

  @override
  String getSubject() {
    return isAutomatic
        ? "Ihre Aktivität: Liegt in dieser automatisch generierten Mail bei 🚀"
        : "Erfolg: Ihr manuelles Backup wurde erstellt ✅";
  }
}
