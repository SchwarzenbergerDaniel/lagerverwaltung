import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/automatisierte_aufgaben/automatisiert_checker.dart';
import 'package:lagerverwaltung/service/codescanner_service.dart';
import 'package:lagerverwaltung/service/csv_converter_service.dart';
import 'package:lagerverwaltung/service/lagerlistenverwatlung_service.dart';
import 'package:lagerverwaltung/service/localstorage_service.dart';
import 'package:lagerverwaltung/service/mailsender_service.dart';

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
    return MaterialApp(
      title: 'Localstorage Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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

  final TextEditingController _controller = TextEditingController();
  String _storedUsername = '';
  String _qrCodeString = "";

  void sendMail() async {
    await mailSenderService.sendMessage(
        toMail: "terrorgans123@gmail.com",
        subject: "CSV-Liste",
        message: "Hallo, dies ist eine Test-Mail!");
  }

  void scanCode() async {
    final result = await codeScannerService.getCodeByScan(context);
    if (result != null) {
      setState(() {
        _qrCodeString = result;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kein Code gefunden!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CupertinoTextField(
              placeholder: "Enter username for LocalStorage",
              controller: _controller,
            ),
            const SizedBox(height: 20),
            Text(
              _storedUsername,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: scanCode,
              child: const Text('QR-CODE SCANNEN'),
            ),
            const SizedBox(height: 20),
            Text(
              _qrCodeString,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendMail,
              child: const Text('Send Mail'),
            ),
          ],
        ),
      ),
    );
  }
}
