// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/automatisierte_aufgaben/automatisiert_checker.dart';
import 'package:lagerverwaltung/buttons/scan_lagerplatz.dart';
import 'package:lagerverwaltung/buttons/artikel_amount_change_button.dart';
import 'package:lagerverwaltung/buttons/scan_artikel.dart';
import 'package:lagerverwaltung/buttons/export_list_button.dart';
import 'package:lagerverwaltung/buttons/import_list_button.dart';
import 'package:lagerverwaltung/buttons/inventur_durchfuehren_button.dart';
import 'package:lagerverwaltung/provider/colormodeprovider.dart';
import 'package:lagerverwaltung/service/jokegenerator_service.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/service/theme_changing_service.dart';
import 'package:lagerverwaltung/service/logger/logger_service.dart';
import 'package:lagerverwaltung/service/codescanner_service.dart';
import 'package:lagerverwaltung/service/csv_converter_service.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';
import 'package:lagerverwaltung/service/localstorage_service.dart';
import 'package:lagerverwaltung/service/mailsender/mailsender_service.dart';
import 'package:lagerverwaltung/page/settings/settings_page.dart';
import 'package:lagerverwaltung/testhelper/testhelper.dart';
import 'package:lagerverwaltung/utils/heading_text.dart';
import 'package:lagerverwaltung/widget/background/animated_background.dart';
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

//TODO: Appbar schaut Arsch aus => Text weg und transparent, nur backbutton links oben.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    // Nur Hochformat
    DeviceOrientation.portraitUp,
  ]);

  // await Testhelper.clearLocalStorage();
  await setUpServices();

  await Testhelper.add_default_values();

  checker.checkTodo();
  final themeService = getIt<ThemeChangingService>();
  await themeService.loadPrimaryColor();
  await themeService.loadBackgroundColor();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => themeService,
        ),
        ChangeNotifierProvider(create: (_) => ColorModeProvider()),
      ],
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
            barBackgroundColor: CupertinoColors.transparent,
            // scaffoldBackgroundColor: CupertinoColors.transparent,
            textTheme: CupertinoTextThemeData(
              textStyle: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
              actionTextStyle: TextStyle(
                color: textColor,
              ),
            ),
          ),
          debugShowCheckedModeBanner: false,
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
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
      child: Stack(
        children: [
          AnimatedBackground(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HeadingText(text: "Lagerverwaltung"),
                      const SizedBox(height: 20),

                      // Zeile 1: Standort & Artikel Scannen
                      _buildHeading("Standort & Artikel Scannen"),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: ScanLagerplatzButton()),
                          const SizedBox(width: 10),
                          Expanded(child: ScanArtikelButton()),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Zeile 2: Bestandsänderungen & Inventur
                      _buildHeading("Bestandsänderungen & Inventur"),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: ArtikelAmountChangeButton()),
                          const SizedBox(width: 10),
                          Expanded(child: InventurDurchfuehrenButton()),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Zeile 3: Datenimport & -export
                      _buildHeading("Datenimport & -export"),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: ExportListButton()),
                          const SizedBox(width: 10),
                          Expanded(child: ImportListButton()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Positionierter Settings-Button oben rechts
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(Icons.settings_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeading(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 8.0),
              height: 1,
              color: CupertinoColors.inactiveGray,
            ),
          ),
        ],
      ),
    );
  }
}
