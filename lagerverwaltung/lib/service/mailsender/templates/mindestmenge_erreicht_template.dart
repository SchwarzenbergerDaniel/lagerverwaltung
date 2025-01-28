import 'package:lagerverwaltung/model/LagerlistenEntry.dart';
import 'package:lagerverwaltung/service/mailsender/templates/html_template_generator.dart';

class MindestmengeErreichtTemplate extends HTMLTemplateGenerator {
  // Instances
  late LagerListenEntry artikel;
  late int amountChange;

  MindestmengeErreichtTemplate(
      {required this.artikel, required this.amountChange});

  @override
  String getTitle() {
    return "Mindestmenge erreicht für Artikel: ${artikel.beschreibung!}";
  }

  @override
  Future<String> generateContentHTML() async {
    if (amountChange > 0) {
      return getWasNachfuellen();
    }
    return getWasEntnahme();
  }

  String getWasNachfuellen() {
    return '''
    <p>Hallo!</p>
    <p>
      Für den Artikel <b style="color: #007bff">${artikel.beschreibung!}</b> wurde soeben eine Nachfüllung durchgeführt. Die Menge wurde um <b style="color: #28a745">${amountChange.toString()} erhöht</b>.
    </p>
   <p>
      Der verbleibende <b>Lagerbestand</b> beträgt nun <b style="color: #dc3545">${artikel.menge!.toString()}/${artikel.mindestMenge!.toString()}</b>.
    </p>
    <p>
      Zeitpunkt der Information: <b style="color: #6c757d">${getMailDateTimeAsReadableString()}</b>.
    </p>
    <p>Weiterhin eine erfolgreiche Woche!</p>
  ''';
  }

  String getWasEntnahme() {
    return '''
    <p>Hallo!</p>
    <p>
      Beim Artikel <b style="color: #007bff">${artikel.beschreibung!}</b> wurde soeben eine Entnahme durchgeführt. Die Menge wurde um <b style="color: #dc3545">${(-amountChange).toString()} reduziert</b>.
    </p>
    <p>
      Der verbleibende <b>Lagerbestand</b> beträgt nun <b style="color: #dc3545">${artikel.menge!.toString()}/${artikel.mindestMenge!.toString()}</b>.
    </p>
    <p>
      Zeitpunkt der Information: <b style="color: #6c757d">${getMailDateTimeAsReadableString()}</b>.
    </p>
    <p>Weiterhin eine erfolgreiche Woche!</p>
  ''';
  }

  @override
  String getSubject() {
    return "Mindestmenge erreicht für Artikel: ${artikel.beschreibung!}";
  }
}
