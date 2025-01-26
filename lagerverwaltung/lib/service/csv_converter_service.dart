import 'dart:io';

import 'package:lagerverwaltung/config/constants.dart';
import 'package:lagerverwaltung/model/LagerlistenEntry.dart';
import 'package:path_provider/path_provider.dart';

// CSV FILE Looks like this:
//lagerplatzId,fach,regal,artikelGWID,arikelFirmenId,beschreibung,kunde,ablaufdatum,menge,mindestMenge

class CsvConverterService {
  // Service-Setup:
  CsvConverterService._privateConstructor();
  static final CsvConverterService _instance =
      CsvConverterService._privateConstructor();
  factory CsvConverterService() {
    return _instance;
  }

  // METHODEN:

  List<LagerListenEntry>? convertToList(File csvFile) {
    try {
      final input = csvFile.readAsStringSync();
      final lines = input.split('\n');

      return lines.skip(1).where((line) => line.trim().isNotEmpty).map((line) {
        return LagerListenEntry.convertCSVLine(line);
      }).toList();
    } catch (e) {
      return null; // Falsches Format!
    }
  }

  Future<File> toCsv(List<LagerListenEntry> entries) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/lagerlisten.csv';

    // Create the file
    final file = File(filePath);
    final csvContent = StringBuffer()
      ..writeln(Constants.CSV_HEADER_VALUE)
      ..writeAll(entries.map((entry) => entry.toCsvRow()), "\n");

    file.writeAsStringSync(csvContent.toString());

    return file;
  }
}
