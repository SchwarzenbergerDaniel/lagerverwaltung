import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/config/constants.dart';
import 'package:lagerverwaltung/model/lagerlistenentry.dart';
import 'package:lagerverwaltung/page/settings/xlsx_column_order/xlsx_column_order_changer_page.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/service/logger/log_entry.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';

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

  List<LagerlistenEntry>? convertToList(File xlsxFile) {
    try {
      final bytes = xlsxFile.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName];

      if (sheet == null || sheet.rows.isEmpty) {
        return null;
      }

      final headerRow = sheet.rows.first;
      final csvOrder = headerRow.map((cell) {
        final value = cell?.value.toString() ?? '';
        return Columns.values.firstWhere((column) => column.name == value);
      }).toList();

      return sheet.rows
          .skip(1)
          .where((row) => row.any((cell) =>
              cell != null && cell.value.toString().trim().isNotEmpty))
          .map((row) {
        final rowString = row
            .map((cell) =>
                cell?.value?.toString().replaceAll(
                    Constants.XLSX_DELIMITER_VALUE,
                    Constants.XLSX_DELIMITER_REPLACER) ??
                '')
            .join(Constants.XLSX_DELIMITER_VALUE);
        return LagerlistenEntry.convertCSVLine(rowString, csvOrder);
      }).toList();
    } catch (e) {
      return null;
    }
  }

  Future<File> toXlsx(List<LagerlistenEntry> entries) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/lagerlisten.xlsx';

    List<Columns> csvOrder = localSettingsManagerService.getXlsxOrder();

    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    for (int colIndex = 0; colIndex < csvOrder.length; colIndex++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 0))
          .value = csvOrder[colIndex].name;
    }

    for (int rowIndex = 0; rowIndex < entries.length; rowIndex++) {
      final entry = entries[rowIndex];
      List<String> rowValues = entry.toCsvRow(csvOrder).split(',');
      for (int colIndex = 0; colIndex < rowValues.length; colIndex++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex + 1)).value =
            rowValues[colIndex].replaceAll(
                Constants
                    .XLSX_DELIMITER_REPLACER, // Dirty as fuck aber egal das funktioniert. NICHT ANFASSEN!
                Constants.XLSX_DELIMITER_VALUE);
      }
    }

    List<int>? fileBytes = excel.encode();
    final file = File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);

    return file;
  }

  Future<File> toLogFile(List<LogEntryModel> entries) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/aktivitaet.txt';

    final file = File(filePath);

    final xlsxContent = StringBuffer()..writeAll(entries, "\n");

    file.writeAsStringSync(xlsxContent.toString());
    return file;
  }
}
