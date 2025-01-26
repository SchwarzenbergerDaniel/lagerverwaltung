import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/automatisierte_aufgaben/automatisiert_checker.dart';
import 'package:lagerverwaltung/config/constants.dart';
import 'package:lagerverwaltung/model/LagerlistenEntry.dart';
import 'package:lagerverwaltung/widget/qr_code_scanned_modal.dart';
import 'package:lagerverwaltung/service/codescanner_service.dart';
import 'package:lagerverwaltung/service/csv_converter_service.dart';
import 'package:lagerverwaltung/service/lagerlistenverwatlung_service.dart';
import 'package:lagerverwaltung/service/localstorage_service.dart';
import 'package:lagerverwaltung/service/mailsender/mailsender_service.dart';
import 'package:lagerverwaltung/page/settings_page.dart';
import 'package:lagerverwaltung/widget/showsnackbar.dart';

final getIt = GetIt.instance;
AutomatisiertChecker checker = AutomatisiertChecker();
void setUpServices() {
  getIt.registerLazySingleton<LocalStorageService>(() => LocalStorageService());
  getIt.registerLazySingleton<CodeScannerService>(() => CodeScannerService());
  getIt.registerLazySingleton<MailSenderService>(() => MailSenderService());
  getIt.registerLazySingleton<LagerlistenVerwatlungsService>(
      () => LagerlistenVerwatlungsService());
  getIt.registerLazySingleton<CsvConverterService>(() => CsvConverterService());
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setUpServices();
  checker.checkTodo();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.activeBlue,
        barBackgroundColor: CupertinoColors.systemGrey,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontSize: 16,
            color: CupertinoColors.white,
          ),
          actionTextStyle: TextStyle(
            color: CupertinoColors.white,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Service-Tests'),
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

  final TextEditingController _controller = TextEditingController();
  final String _storedUsername = '';
  String _qrCodeString = "No code";

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
        Constants.TO_MAIL_DEFAULT, false);
    mailSenderService.sendLagerListe(await csvConverterService.toCsv(entries),
        Constants.TO_MAIL_DEFAULT, true);

    mailSenderService.sendMindestmengeErreicht(
        entries[0], 1, Constants.TO_MAIL_DEFAULT);

    mailSenderService.sendMindestmengeErreicht(
        entries[0], -1, Constants.TO_MAIL_DEFAULT);
    mailSenderService.sendAbgelaufen(
        entries +
            entries +
            entries +
            entries +
            entries +
            entries +
            entries +
            entries +
            entries,
        Constants.TO_MAIL_DEFAULT);
  }

  void scanCode() async {
    final result = await codeScannerService.getCodeByScan(context);
    if (result != null) {
      if (result == Constants.EXIT_RETURN_VALUE) {
        //Wenn man durch den Backarrow zurück will, das kein Error kommt
        return;
      }
      setState(() {
        _qrCodeString = result;
      });
      QrCodeScannedModal.showActionSheet(context, result);
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
            CupertinoTextField(
              placeholder: "Enter username for LocalStorage",
              controller: _controller,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            const SizedBox(height: 20),
            Text(
              _storedUsername,
              style: CupertinoTheme.of(context).textTheme.actionTextStyle,
            ),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              onPressed: scanCode,
              child: const Text('QR-CODE SCANNEN'),
            ),
            const SizedBox(height: 20),
            Text(
              _qrCodeString,
              style: CupertinoTheme.of(context).textTheme.actionTextStyle,
            ),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              onPressed: sendMail,
              child: const Text('Send Mail'),
            ),

            // TEST
            const SizedBox(
              height: 20,
            ),
            CupertinoButton.filled(
              onPressed: () =>
                  {QrCodeScannedModal.showActionSheet(context, "ScannedID")},
              child: const Text('Alr Scanned PopUp Button'),
            ),
          ],
        ),
      ),
    );
  }
}
