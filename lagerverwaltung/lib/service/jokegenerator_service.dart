import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class JokegeneratorService {
  // Service-Setup:
  JokegeneratorService._privateConstructor();
  static final JokegeneratorService _instance =
      JokegeneratorService._privateConstructor();
  factory JokegeneratorService() {
    return _instance;
  }

// INSTANCES:
  List<String> preDefinedJokes = [
    "Was ist ein Keks unter einem Baum? – Ein schattiges Plätzchen!",
    "Warum können Skelette so schlecht lügen? – Weil sie nichts auf dem Herzen haben!",
    "Warum gehen Ameisen nicht in die Kirche? – Weil sie In-Sekten sind!",
    "Was ist der Unterschied zwischen einem Krokodil und einem Alligator? – Das eine kommt später, das andere ein bisschen alligator.",
    "Warum können Elefanten nicht fliegen? – Weil sie keine Meilen sammeln!",
    "Was macht ein Clown im Büro? – Faxen!",
    "Warum haben Kühe Glocken? – Weil ihre Hörner nicht funktionieren!",
    "Was macht eine Wolke mit Juckreiz? – Sie wird gewittrig!",
    "Warum war der Mathematiker schlecht im Tanzen? – Weil er immer nur den Winkel misst!",
    "Warum sind Seeräuber so schlechte Sänger? – Weil sie immer die Hook vergessen!",
    "Was macht ein Pirat im Fitnessstudio? – Er trainiert sein Bizeps-Leg!",
    "Warum durfte der Pilz nicht auf die Party? – Weil er aus dem Boden gestampft wurde!",
    "Warum sind Giraffen schlechte Geheimagenten? – Weil sie immer aus der Reihe tanzen!",
    "Was sagt ein Hammer zu einem Nagel? – Schlag ein!",
    "Warum sind Geister so schlechte Komiker? – Weil ihre Witze durchsichtig sind!",
    "Warum sind Skelette so ruhig? – Weil sie nichts auf dem Herzen haben!",
    "Was macht ein DJ in der Küche? – Er legt auf!",
    "Warum hat die Tomate keine Freunde? – Weil sie immer aus der Dose kommt!",
    "Warum sind Glühwürmchen so schlechte Verbrecher? – Weil sie immer unter Beobachtung stehen!",
    "Warum darfst du keinem Papagei ein Geheimnis erzählen? – Weil er alles nachplappert!",
    "Was macht ein Pessimist nach dem Sport? – Er schwitzt pessimistisch!",
    "Warum sind Fische so schlecht im Tennis? – Weil sie immer ins Netz gehen!",
    "Was sagt der große Stift zum kleinen Stift? – Wachs mal über dich hinaus!",
    "Warum stehen Pflanzen so gerne am Fenster? – Weil sie Photosynthese brauchen!",
    "Warum haben Vampire immer so gute Laune? – Weil sie den ganzen Tag rumhängen können!",
    "Warum tragen Golfer zwei Paar Hosen? – Falls sie ein Hole-in-One haben!"
  ];

  // METHODS:

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
      "Warum können Geister so schlecht lügen? – Weil man durch sie hindurchsehen kann!",
      "Warum hat der Pilz gute Laune? – Weil er aus der Erde springt!",
      "Was macht ein Pirat am Computer? – Er drückt die Enter-Taste!"
    ];
    final random = Random();
    return preDefinedJokes[random.nextInt(preDefinedJokes.length)];
  }
}
