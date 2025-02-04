// ignore_for_file: use_build_context_synchronously

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/automatisierte_aufgaben/automatisiert_checker.dart';
import 'package:lagerverwaltung/buttons/add_lagerplatz_button.dart';
import 'package:lagerverwaltung/buttons/artikel_amount_change_button.dart';
import 'package:lagerverwaltung/buttons/create_artikel_button.dart';
import 'package:lagerverwaltung/buttons/export_list_button.dart';
import 'package:lagerverwaltung/buttons/import_list_button.dart';
import 'package:lagerverwaltung/buttons/inventur_durchfuehren_button.dart';
import 'package:lagerverwaltung/buttons/logs_ansehen_button.dart';
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
          home: const MyHomePage(title: 'Gradwohl Lagerverwaltung'),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20), // Rand auf beiden Seiten hinzufügen
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // LOGO:
                Image.asset(
                  'assets/logo-gradwohl.png',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 20),

                // BUTTONS IN ROWS OF TWO:
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: ExportListButton()),
                        Expanded(child: ImportListButton()),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: LogsAnsehenButton()),
                        Expanded(child: InventurDurchfuehrenButton()),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: AddLagerplatzButton()),
                        Expanded(child: CreateArtikelButton()),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: ArtikelAmountChangeButton()),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
