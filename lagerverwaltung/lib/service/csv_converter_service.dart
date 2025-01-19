import 'dart:io';

import 'package:lagerverwaltung/model/LagerlistenEntry.dart';

class CsvConverterService {
  // Service-Setup:
  CsvConverterService._privateConstructor();
  static final CsvConverterService _instance =
      CsvConverterService._privateConstructor();
  factory CsvConverterService() {
    return _instance;
  }

// TODO: Wie soll die CSV aussehen?
  List<LagerListenEntry>? convertToList(File csvFile) {
    return [];
  }

  File toCsv(List<LagerListenEntry> entries) {
    return File("null!");
  }
}
