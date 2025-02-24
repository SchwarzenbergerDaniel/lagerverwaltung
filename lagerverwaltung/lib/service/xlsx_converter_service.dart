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
          .value = TextCellValue(csvOrder[colIndex].name);
    }

    for (int rowIndex = 0; rowIndex < entries.length; rowIndex++) {
      final entry = entries[rowIndex];
      List<String> rowValues = entry.toCsvRow(csvOrder).split(',');
      for (int colIndex = 0; colIndex < rowValues.length; colIndex++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex + 1)).value =
            TextCellValue(rowValues[colIndex].replaceAll(
                Constants
                    .XLSX_DELIMITER_REPLACER, // Dirty as fuck aber egal das funktioniert. NICHT ANFASSEN!
                Constants.XLSX_DELIMITER_VALUE));
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

  Future<File> convertToInventurListe(
      List<LagerlistenEntry> sollListe, List<LagerlistenEntry> istListe) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/inventur-listes.xlsx';
    Excel excel = Excel.createExcel();

    // Sheet 1: Regal	Fach	Lagerplatz	Artikel GWID	Artikel Firmen-ID	Beschreibung	Soll-Menge	Ist-Menge	Differenz(Fehlmengen=Rot, Übermengen=gelb, korrekt=Grün)	Mindestmenge	Kunde	Ablaufdatum	Kommentar(Fehlmenge/Überbestand)
    createArtikelSheet(excel, sollListe, istListe);

    // Sheet 2: Artikel deren Mindestmenge unterschritten ist. Regal	Fach	Lagerplatz	Artikel GWID	Artikel Firmen-ID	Beschreibung	Ist-Menge	Mindestmenge	Fehlmenge
    createMindestMengeUnterschrittenSheet(excel, sollListe, istListe);

    // Sheet 3 Ablaufkritische Bestände. Sortiert nach Ablaufdatum
    int reminderBeforeDays =
        localSettingsManagerService.getAbgelaufenReminderInDays();
    createAblaufKritischeBestaendeSheet(
        excel, sollListe, istListe, reminderBeforeDays);
    excel.delete('Sheet1');

    List<int>? fileBytes = excel.encode();
    final file = File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);
    return file;
  }

  // SHEETS:
  void createArtikelSheet(Excel excel, List<LagerlistenEntry> sollListe,
      List<LagerlistenEntry> istListe) {
    Sheet artikelSheet = excel['Artikelübersicht'];

    // Header definieren
    List<String> headers = [
      'Regal',
      'Fach',
      'Lagerplatz',
      'Artikel GWID',
      'Artikel Firmen-ID',
      'Beschreibung',
      'Soll-Menge',
      'Ist-Menge',
      'Differenz',
      'Mindestmenge',
      'Kunde',
      'Ablaufdatum',
      'Kommentar'
    ];

    for (int i = 0; i < headers.length; i++) {
      artikelSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(headers[i]);
    }

    // Daten einfügen
    Map<String, LagerlistenEntry> istMap = {
      for (var entry in istListe) entry.artikelGWID ?? '': entry
    };

    for (int i = 0; i < sollListe.length; i++) {
      var sollEntry = sollListe[i];
      var istEntry =
          istMap[sollEntry.artikelGWID] ?? LagerlistenEntry(menge: 0);
      int differenz = (istEntry.menge ?? 0) - (sollEntry.menge ?? 0);

      // Werte setzen
      artikelSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = TextCellValue(sollEntry.regal ?? '');
      artikelSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          .value = TextCellValue(sollEntry.fach ?? '');
      artikelSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          .value = TextCellValue(sollEntry.lagerplatzId ?? '');
      artikelSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
          .value = TextCellValue(sollEntry.artikelGWID ?? '');
      artikelSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
          .value = TextCellValue(sollEntry.arikelFirmenId ?? '');
      artikelSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
          .value = TextCellValue(sollEntry.beschreibung ?? '');
      artikelSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1))
          .value = IntCellValue(sollEntry.menge ?? 0);
      artikelSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 1))
          .value = IntCellValue(istEntry.menge ?? 0);
      artikelSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: i + 1))
          .value = IntCellValue(differenz);
      artikelSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: i + 1))
          .value = IntCellValue(sollEntry.mindestMenge ?? 0);
      artikelSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: i + 1))
          .value = TextCellValue(sollEntry.kunde ?? '');
      artikelSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: i + 1))
          .value = sollEntry.ablaufdatum !=
              null
          ? DateCellValue(
              year: sollEntry.ablaufdatum!.year,
              month: sollEntry.ablaufdatum!.month,
              day: sollEntry.ablaufdatum!.day)
          : TextCellValue('');

      // Kommentar
      String kommentar = differenz < 0
          ? "Fehlmenge"
          : (differenz > 0 ? "Überbestand" : "Keine Bestandsänderung!");

      artikelSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: i + 1));

      artikelSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: i + 1))
          .value = TextCellValue(kommentar);
    }
  }

  void createMindestMengeUnterschrittenSheet(Excel excel,
      List<LagerlistenEntry> sollListe, List<LagerlistenEntry> istListe) {
    Sheet mindestMengeSheet = excel['Mindestmenge unterschritten'];

    // Header definieren
    List<String> headers = [
      'Regal',
      'Fach',
      'Lagerplatz',
      'Artikel GWID',
      'Artikel Firmen-ID',
      'Beschreibung',
      'Ist-Menge',
      'Mindestmenge',
      'Fehlmenge'
    ];

    for (int i = 0; i < headers.length; i++) {
      mindestMengeSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(headers[i]);
    }

    // Daten filtern und einfügen
    Map<String, LagerlistenEntry> istMap = {
      for (var entry in istListe) entry.artikelGWID ?? '': entry
    };

    int rowIndex = 1;
    for (var sollEntry in sollListe) {
      var istEntry =
          istMap[sollEntry.artikelGWID] ?? LagerlistenEntry(menge: 0);
      int istMenge = istEntry.menge ?? 0;
      int mindestMenge = sollEntry.mindestMenge ?? 0;
      int fehlmenge = mindestMenge - istMenge;

      if (fehlmenge > 0) {
        mindestMengeSheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = TextCellValue(sollEntry.regal ?? '');
        mindestMengeSheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = TextCellValue(sollEntry.fach ?? '');
        mindestMengeSheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = TextCellValue(sollEntry.lagerplatzId ?? '');
        mindestMengeSheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = TextCellValue(sollEntry.artikelGWID ?? '');
        mindestMengeSheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = TextCellValue(sollEntry.arikelFirmenId ?? '');
        mindestMengeSheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = TextCellValue(sollEntry.beschreibung ?? '');
        mindestMengeSheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            .value = IntCellValue(istMenge);
        mindestMengeSheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
            .value = IntCellValue(mindestMenge);
        mindestMengeSheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
            .value = IntCellValue(fehlmenge);

        // Fehlmenge farblich markieren
        mindestMengeSheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex));

        rowIndex++;
      }
    }
  }

  void createAblaufKritischeBestaendeSheet(
      Excel excel,
      List<LagerlistenEntry> sollListe,
      List<LagerlistenEntry> istListe,
      int reminderBeforeDays) {
    Sheet ablaufkritischeSheet = excel['Ablaufkritische Bestände'];

    // Header definieren
    List<String> headers = [
      'Regal',
      'Fach',
      'Lagerplatz',
      'Artikel GWID',
      'Artikel Firmen-ID',
      'Beschreibung',
      'Ist-Menge',
      'Ablaufdatum',
      'Tage bis Ablauf'
    ];

    for (int i = 0; i < headers.length; i++) {
      ablaufkritischeSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(headers[i]);
    }

    DateTime today = DateTime.now();
    int rowIndex = 1;
    sollListe.sort((left, right) {
      // Sortieren nach "in wie vielen tagen läuft es ab"
      var istEntry1 = istListe.firstWhere(
        (entry) => entry.artikelGWID == left.artikelGWID,
        orElse: () => LagerlistenEntry(menge: 0, ablaufdatum: null),
      );
      var istEntry2 = istListe.firstWhere(
        (entry) => entry.artikelGWID == right.artikelGWID,
        orElse: () => LagerlistenEntry(menge: 0, ablaufdatum: null),
      );

      DateTime ablaufdatum1 = istEntry1.ablaufdatum ?? DateTime(2100);
      DateTime ablaufdatum2 = istEntry2.ablaufdatum ?? DateTime(2100);

      int tageBisAblauf1 = ablaufdatum1.difference(today).inDays;
      int tageBisAblauf2 = ablaufdatum2.difference(today).inDays;

      return tageBisAblauf1.compareTo(tageBisAblauf2);
    });

    for (var sollEntry in sollListe) {
      var istEntry = istListe.firstWhere(
          (entry) => entry.artikelGWID == sollEntry.artikelGWID,
          orElse: () => LagerlistenEntry(menge: 0, ablaufdatum: null));

      DateTime? ablaufdatum = istEntry.ablaufdatum;
      if (ablaufdatum != null) {
        int tageBisAblauf = ablaufdatum.difference(today).inDays;

        if (tageBisAblauf <= reminderBeforeDays) {
          ablaufkritischeSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 0, rowIndex: rowIndex))
              .value = TextCellValue(sollEntry.regal ?? '');
          ablaufkritischeSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 1, rowIndex: rowIndex))
              .value = TextCellValue(sollEntry.fach ?? '');
          ablaufkritischeSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 2, rowIndex: rowIndex))
              .value = TextCellValue(sollEntry.lagerplatzId ?? '');
          ablaufkritischeSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 3, rowIndex: rowIndex))
              .value = TextCellValue(sollEntry.artikelGWID ?? '');
          ablaufkritischeSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 4, rowIndex: rowIndex))
              .value = TextCellValue(sollEntry.arikelFirmenId ?? '');
          ablaufkritischeSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 5, rowIndex: rowIndex))
              .value = TextCellValue(sollEntry.beschreibung ?? '');
          ablaufkritischeSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 6, rowIndex: rowIndex))
              .value = IntCellValue(istEntry.menge ?? 0);
          ablaufkritischeSheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: 7, rowIndex: rowIndex))
                  .value =
              DateCellValue(
                  year: ablaufdatum.year,
                  month: ablaufdatum.month,
                  day: ablaufdatum.day);
          ablaufkritischeSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 8, rowIndex: rowIndex))
              .value = IntCellValue(tageBisAblauf);
          rowIndex++;
        }
      }
    }
  }
}
