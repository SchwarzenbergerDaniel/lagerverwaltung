// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/automatisierte_aufgaben/automatisiert_checker.dart';
import 'package:lagerverwaltung/config/constants.dart';
import 'package:lagerverwaltung/model/LagerlistenEntry.dart';
import 'package:lagerverwaltung/page/artikel_page.dart';
import 'package:lagerverwaltung/page/lagerliste_page.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/service/theme_changing_service.dart';
import 'package:lagerverwaltung/testhelper/testhelper.dart';
import 'package:lagerverwaltung/widget/lagerplatz_code_scanned_modal.dart';
import 'package:lagerverwaltung/service/logger/logger_service.dart';
import 'package:lagerverwaltung/service/codescanner_service.dart';
import 'package:lagerverwaltung/service/csv_converter_service.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/service/localstorage_service.dart';
import 'package:lagerverwaltung/service/mailsender/mailsender_service.dart';
import 'package:lagerverwaltung/page/settings/settings/settings_page.dart';
import 'package:lagerverwaltung/widget/showsnackbar.dart';
import 'package:lagerverwaltung/utils/scan_artikel_code_after_lagerplatz.dart';
import 'package:provider/provider.dart';

final getIt = GetIt.instance;
AutomatisiertChecker checker = AutomatisiertChecker();
void setUpServices() {
  getIt.registerLazySingleton<LocalStorageService>(() => LocalStorageService());
  getIt.registerLazySingleton<CodeScannerService>(() => CodeScannerService());
  getIt.registerLazySingleton<MailSenderService>(() => MailSenderService());
  getIt.registerLazySingleton<LagerlistenVerwaltungsService>(
      () => LagerlistenVerwaltungsService());
  getIt.registerLazySingleton<CsvConverterService>(() => CsvConverterService());
  getIt.registerLazySingleton<LoggerService>(() => LoggerService());
  getIt.registerLazySingleton<LocalSettingsManagerService>(
      () => LocalSettingsManagerService());
  getIt.registerLazySingleton<ThemeChangingService>(() => ThemeChangingService());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Testhelper
      .clearLocalStorage(); // TODO: REMOVE WHEN FINISHED, JUST FOR TESTING!
  setUpServices();
  checker.checkTodo();
  final themeService = getIt<ThemeChangingService>();
  await themeService.loadPrimaryColor();
  runApp(
    ChangeNotifierProvider(
      create: (_) => themeService,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeChangingService>(
      builder: (context, themeService, child) {
        return CupertinoApp(
          theme: CupertinoThemeData(
            primaryColor: themeService.primaryColor.color, // Aktualisierte Farbe
            barBackgroundColor: CupertinoColors.systemBackground,
            scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
            textTheme: CupertinoTextThemeData(
              textStyle: TextStyle(
                fontSize: 16,
                color: CupertinoColors.label,
              ),
              actionTextStyle: TextStyle(
                color: themeService.primaryColor.color,
              ),
            ),
          ),
          debugShowCheckedModeBanner: false,
          home: const MyHomePage(title: 'Service-Tests'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final localStorageService = GetIt.instance<LocalStorageService>();
  final codeScannerService = GetIt.instance<CodeScannerService>();
  final mailSenderService = GetIt.instance<MailSenderService>();
  final csvConverterService = GetIt.instance<CsvConverterService>();
  final lagerListenVerwaltungsService =
      GetIt.instance<LagerlistenVerwaltungsService>();
  final loggerService = GetIt.instance<LoggerService>();
  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  void sendMail() async {
    // TESTEN: csvConverter, files senden
    List<Map<String, dynamic>> jsonArray = [
      {
        "fach": "A1",
        "regal": "R1",
        "lagerplatzId": "101",
        "artikelGWID": "G123",
        "arikelFirmenId": "F456",
        "beschreibung": "Artikelbeschreibung 1",
        "kunde": "Kunde 1",
        "ablaufdatum": "2025-12-31",
        "menge": 5,
        "mindestMenge": 10,
      }
    ];
    List<LagerListenEntry> entries =
        jsonArray.map((json) => LagerListenEntry.fromJson(json)).toList();
    mailSenderService.sendLagerListe(await csvConverterService.toCsv(entries),
        localSettingsManagerService.getMail(), false);
    mailSenderService.sendLagerListe(await csvConverterService.toCsv(entries),
        localSettingsManagerService.getMail(), true);

    mailSenderService.sendMindestmengeErreicht(
        entries[0], 1, localSettingsManagerService.getMail());

    mailSenderService.sendMindestmengeErreicht(
        entries[0], -1, localSettingsManagerService.getMail());
    mailSenderService.sendAbgelaufen(
        entries + entries, localSettingsManagerService.getMail());
  }

  void scanLagerplatzCode() async {
    final scannedID = await codeScannerService.getCodeByScan(context);
    if (scannedID != null) {
      if (scannedID == Constants.EXIT_RETURN_VALUE) {
        //Wenn man durch den Backarrow zurück will, das kein Error kommt
        return;
      }
      if (lagerListenVerwaltungsService.lagerplatzExist(scannedID)) {
        List<LagerListenEntry> artikelListe =
            lagerListenVerwaltungsService.getLagerlisteByLagerplatz(scannedID);
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => LagerlistePage(
                      entries: artikelListe,
                      lagerplatzId: scannedID,
                    )));
      } else {
        final result = await LagerplatzCodeScannedModal.showActionSheet(
            context, scannedID);
        //True = Neuer Artikel
        //False = Neuer Lagerplatz
        //Null = Exit
        if (result == true) {
          lagerListenVerwaltungsService.addEmptyLagerplatz(scannedID);
          scanArtikelCodeAfterLagerplatz(context, scannedID);
        } else if (result == false) {
          lagerListenVerwaltungsService.addEmptyLagerplatz(scannedID);
          Showsnackbar.showSnackBar(context, "Lagerliste wurde erstellt");
        }
      }
    } else {
      Showsnackbar.showSnackBar(context, "kein Code gefunden!");
    }
  }

  void scanArtikelCode() async {
    final scannedID = await codeScannerService.getCodeByScan(context);
    if (scannedID != null) {
      if (scannedID == Constants.EXIT_RETURN_VALUE) {
        //Wenn man durch den Backarrow zurück will, das kein Error kommt
        return;
      }
      if (lagerListenVerwaltungsService.artikelGWIDExist(scannedID)) {
        LagerListenEntry artikel =
            lagerListenVerwaltungsService.getArtikelByGWID(scannedID);
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => ArtikelPage(entry: artikel)));
      } else {
        Showsnackbar.showSnackBar(
            context, "kein Artikel mit dieser ID gefunden!");
      }
    } else {
      Showsnackbar.showSnackBar(context, "kein Code gefunden!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
        trailing: CupertinoButton(
            child: Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(context,
                  CupertinoPageRoute(builder: (context) => SettingsPage()));
            }),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CupertinoButton.filled(
              onPressed: scanLagerplatzCode,
              child: const Text('Lagerplatz Scannen'),
            ),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              onPressed: scanArtikelCode,
              child: const Text('Artikel Scannen'),
            ),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              onPressed: sendMail,
              child: const Text('Send Mail'),
            ),

            //TEST
            const SizedBox(height: 20),
            CupertinoButton.filled(
              onPressed: () {
                LagerListenEntry exampleEntry = LagerListenEntry(
                  fach: 'A1',
                  regal: 'R1',
                  lagerplatzId: "12345",
                  artikelGWID: 'GW12345',
                  arikelFirmenId: 'Firma123',
                  beschreibung: 'Beispielartikel',
                  kunde: 'Max Mustermann',
                  ablaufdatum: DateTime.now()
                      .add(Duration(days: 30)), // Ablaufdatum in 30 Tagen
                  menge: 10,
                  mindestMenge: 5,
                );

                lagerListenVerwaltungsService.addToLagerliste(exampleEntry);
              },
              child: const Text('Create Artikel'),
            ),
          ],
        ),
      ),
    );
  }
}
