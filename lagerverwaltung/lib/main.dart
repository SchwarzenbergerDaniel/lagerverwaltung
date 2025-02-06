// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/automatisierte_aufgaben/automatisiert_checker.dart';
import 'package:lagerverwaltung/buttons/scan_lagerplatz.dart';
import 'package:lagerverwaltung/buttons/artikel_amount_change_button.dart';
import 'package:lagerverwaltung/buttons/scan_artikel.dart';
import 'package:lagerverwaltung/buttons/export_list_button.dart';
import 'package:lagerverwaltung/buttons/import_list_button.dart';
import 'package:lagerverwaltung/buttons/inventur_durchfuehren_button.dart';
import 'package:lagerverwaltung/buttons/logs_ansehen_button.dart';
import 'package:lagerverwaltung/service/jokegenerator_service.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/service/theme_changing_service.dart';
import 'package:lagerverwaltung/service/logger/logger_service.dart';
import 'package:lagerverwaltung/service/codescanner_service.dart';
import 'package:lagerverwaltung/service/csv_converter_service.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/service/localstorage_service.dart';
import 'package:lagerverwaltung/service/mailsender/mailsender_service.dart';
import 'package:lagerverwaltung/page/settings/settings/settings_page.dart';
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

  // await Testhelper.clearLocalStorage();
  await setUpServices();

  checker.checkTodo();
  final themeService = getIt<ThemeChangingService>();
  await themeService.loadPrimaryColor();
  await themeService.loadBackgroundColor();
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
        // Determine appropriate text color based on background brightness
        final Color textColor =
            themeService.backgroundColor.color.computeLuminance() > 0.5
                ? CupertinoColors.black // Light background → Dark text
                : CupertinoColors.white; // Dark background → Light text

        return CupertinoApp(
          localizationsDelegates: [DefaultMaterialLocalizations.delegate],
          theme: CupertinoThemeData(
            primaryColor: CupertinoDynamicColor.withBrightness(
              color:
                  themeService.primaryColor.color, // Light mode primary color
              darkColor: themeService
                  .primaryColor.darkColor, // Dark mode primary color
            ),
            barBackgroundColor: themeService.backgroundColor,
            scaffoldBackgroundColor: themeService.backgroundColor,
            textTheme: CupertinoTextThemeData(
              textStyle: TextStyle(
                fontSize: 16,
                color: textColor, // Dynamically adjusted text color
              ),
              actionTextStyle: TextStyle(
                color:
                    textColor, // Also apply the contrast rule for action texts
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          widget.title,
          style: CupertinoTheme.of(context).textTheme.textStyle,
        ),
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
                      Expanded(child: ScanLagerplatzButton()),
                      Expanded(child: ScanArtikelButton()),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: ArtikelAmountChangeButton()),
                      Expanded(child: InventurDurchfuehrenButton()),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: ExportListButton()),
                      Expanded(child: ImportListButton()),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: LogsAnsehenButton()),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
