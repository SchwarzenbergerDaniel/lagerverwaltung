import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/config/constants.dart';
import 'package:lagerverwaltung/model/LagerlistenEntry.dart';
import 'package:lagerverwaltung/page/settings/csv_column_order/csv_column_order_changer_page.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:path_provider/path_provider.dart';

class CsvConverterService {
  // Service-Setup:
  CsvConverterService._privateConstructor();
  static final CsvConverterService _instance =
      CsvConverterService._privateConstructor();
  factory CsvConverterService() {
    return _instance;
  }

  // INSTANCES:
  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  // METHODEN:

  List<LagerListenEntry>? convertToList(File csvFile) {
    try {
      final input = csvFile.readAsStringSync();
      final lines = input.split('\n');
      final csvOrder = lines[0]
          .split(Constants.CSV_DELIMITER_VALUE)
          .map((value) =>
              Columns.values.firstWhere((column) => column.name == value))
          .toList();
      return lines.skip(1).where((line) => line.trim().isNotEmpty).map((line) {
        return LagerListenEntry.convertCSVLine(line, csvOrder);
      }).toList();
    } catch (e) {
      return null; // Falsches Format!
    }
  }

  Future<File> toCsv(List<LagerListenEntry> entries) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/lagerlisten.csv';

    List<Columns> csvOrder = localSettingsManagerService.getCsvOrder();
    // Create the file
    final file = File(filePath);
    String firstLine = csvOrder.map((column) => column.name).join(",");

    final csvContent = StringBuffer()
      ..writeln(firstLine)
      ..writeAll(entries.map((entry) => entry.toCsvRow(csvOrder)), "\n");

    file.writeAsStringSync(csvContent.toString());

    print(csvContent.toString());
    return file;
  }
}
