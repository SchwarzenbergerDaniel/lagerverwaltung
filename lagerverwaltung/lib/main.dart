// ignore_for_file: use_build_context_synchronously

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/automatisierte_aufgaben/automatisiert_checker.dart';
import 'package:lagerverwaltung/config/constants.dart';
import 'package:lagerverwaltung/model/LagerlistenEntry.dart';
import 'package:lagerverwaltung/page/artikel_page.dart';
import 'package:lagerverwaltung/page/lagerliste_page.dart';
import 'package:lagerverwaltung/page/logs/log_page.dart';
import 'package:lagerverwaltung/service/jokegenerator_service.dart';
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
Future setUpServices() async {
  getIt.registerLazySingleton<LocalStorageService>(() => LocalStorageService());
  getIt.registerLazySingleton<CodeScannerService>(() => CodeScannerService());
  getIt.registerLazySingleton<MailSenderService>(() => MailSenderService());
  getIt.registerLazySingleton<LagerlistenVerwaltungsService>(
      () => LagerlistenVerwaltungsService());
  getIt.registerLazySingleton<FileConverterService>(
      () => FileConverterService());
  getIt.registerLazySingleton<LoggerService>(() => LoggerService());
  getIt.registerLazySingleton<LocalSettingsManagerService>(
      () => LocalSettingsManagerService());
  getIt.registerLazySingleton<ThemeChangingService>(
      () => ThemeChangingService());
  getIt.registerLazySingleton<JokegeneratorService>(
      () => JokegeneratorService());

  final localSettingsManager = GetIt.instance<LocalSettingsManagerService>();
  await localSettingsManager.ensureInitialized();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Testhelper.clearLocalStorage(); //TODO: REMOVE BEFORE PUBLISHING
  await setUpServices();

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
          localizationsDelegates: [DefaultMaterialLocalizations.delegate],
          theme: CupertinoThemeData(
            primaryColor: CupertinoDynamicColor.withBrightness(
              color: themeService.primaryColor.color, // Default (light mode)
              darkColor: CupertinoDynamicColor.withBrightness(
                color: themeService.primaryColor.color,
                darkColor: themeService.primaryColor.color, // Adjust if needed
              ), // Adjusted for dark mode
            ),
            barBackgroundColor: CupertinoColors.systemBackground,
            scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
            textTheme: CupertinoTextThemeData(
              textStyle: TextStyle(
                fontSize: 16,
                color: CupertinoColors.label, // Adapts automatically to theme
              ),
              actionTextStyle: TextStyle(
                color: CupertinoDynamicColor.withBrightness(
                  color: themeService.primaryColor.color,
                  darkColor: CupertinoDynamicColor.withBrightness(
                    color: themeService.primaryColor.color,
                    darkColor:
                        themeService.primaryColor.color, // Adjust if needed
                  ),
                ),
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
  final codeScannerService = GetIt.instance<CodeScannerService>();
  final mailSenderService = GetIt.instance<MailSenderService>();
  final fileConverterService = GetIt.instance<FileConverterService>();
  final lagerListenVerwaltungsService =
      GetIt.instance<LagerlistenVerwaltungsService>();
  final loggerService = GetIt.instance<LoggerService>();
  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  void export() async {
    mailSenderService.sendLagerListe(
        await fileConverterService
            .toCsv(await lagerListenVerwaltungsService.artikelEntries),
        localSettingsManagerService.getMail(),
        false);
    Showsnackbar.showSnackBar(context,
        "Lagerliste exportiert an ${localSettingsManagerService.getMail()}");
  }

  void import() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      String importMessage =
          lagerListenVerwaltungsService.importFromFile(filePath);
      Showsnackbar.showSnackBar(context, importMessage);
    } else {
      Showsnackbar.showSnackBar(context, "Es wurde keine File ausgewählt.");
    }
  }

  void scanLagerplatzCode() async {
    final scannedID = await codeScannerService.getCodeByScan(context);
    if (scannedID != null) {
      if (scannedID == Constants.EXIT_RETURN_VALUE) {
        //Wenn man durch den Backarrow zurück will, das kein Error kommt
        return;
      }
      if (await lagerListenVerwaltungsService.lagerplatzExist(scannedID)) {
        List<LagerListenEntry> artikelListe =
            await lagerListenVerwaltungsService
                .getLagerlisteByLagerplatz(scannedID);
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
      if (await lagerListenVerwaltungsService.artikelGWIDExist(scannedID)) {
        LagerListenEntry artikel =
            await lagerListenVerwaltungsService.getArtikelByGWID(scannedID);
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
              onPressed: export,
              child: const Text('Lagerliste Exportieren'),
            ),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              onPressed: import,
              child: const Text('Lagerliste Importieren'),
            ),

            const SizedBox(height: 20),
            CupertinoButton.filled(
              onPressed: () => {
                Navigator.push(context,
                    CupertinoPageRoute(builder: (context) => LogPage()))
              },
              child: const Text('Logs'),
            ),

            //TEST
            const SizedBox(height: 20),
            CupertinoButton.filled(
              onPressed: () {
                LagerListenEntry exampleEntry = LagerListenEntry(
                  fach: 'A2',
                  regal: 'R2',
                  lagerplatzId: "1",
                  artikelGWID: 'GW12345',
                  arikelFirmenId: '12',
                  beschreibung: 'beschreibung',
                  kunde: 'Daniel Schwarzenberger',
                  ablaufdatum: DateTime.now()
                      .add(Duration(days: 50)), // Ablaufdatum in 30 Tagen
                  menge: 10,
                  mindestMenge: 5,
                );

                lagerListenVerwaltungsService
                    .addArtikelToLagerliste(exampleEntry);
              },
              child: const Text('Create Artikel'),
            ),
          ],
        ),
      ),
    );
  }
}
