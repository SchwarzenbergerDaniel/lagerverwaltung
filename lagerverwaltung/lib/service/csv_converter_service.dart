import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/config/constants.dart';
import 'package:lagerverwaltung/model/lagerlistenentry.dart';
import 'package:lagerverwaltung/page/settings/csv_column_order/csv_column_order_changer_page.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/service/logger/log_entry.dart';
import 'package:path_provider/path_provider.dart';

class FileConverterService {
  // Service-Setup:
  FileConverterService._privateConstructor();
  static final FileConverterService _instance =
      FileConverterService._privateConstructor();
  factory FileConverterService() {
    return _instance;
  }

  // INSTANCES:
  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  // METHODEN:

  List<LagerlistenEntry>? convertToList(File csvFile) {
    try {
      final input = csvFile.readAsStringSync();
      final lines = input.split('\n');
      final csvOrder = lines[0]
          .split(Constants.CSV_DELIMITER_VALUE)
          .map((value) =>
              Columns.values.firstWhere((column) => column.name == value))
          .toList();
      return lines.skip(1).where((line) => line.trim().isNotEmpty).map((line) {
        return LagerlistenEntry.convertCSVLine(line, csvOrder);
      }).toList();
    } catch (e) {
      return null; // Falsches Format!
    }
  }

  Future<File> toCsv(List<LagerlistenEntry> entries) async {
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
    return file;
  }

  Future<File> toLogFile(List<LogEntryModel> entries) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/aktivitaet.txt';

    final file = File(filePath);

    final csvContent = StringBuffer()..writeAll(entries, "\n");

    file.writeAsStringSync(csvContent.toString());
    return file;
  }
}
