import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';

class EMailEmpfaengerAendernPage extends StatelessWidget {
  EMailEmpfaengerAendernPage({super.key});

  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  @override
  Widget build(BuildContext context) {
    String toMail = localSettingsManagerService.getMail();

    final TextEditingController _textController = TextEditingController(
      text: toMail,
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('EMail-Empfänger ändern'),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: CustomBackButton(), // Assume this is defined elsewhere
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: _textController,
                  placeholder: localSettingsManagerService.getMail(),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                onPressed: () {
                  localSettingsManagerService.setMail(_textController.text);
                  Navigator.pop(context);
                },
                child: const Icon(Icons.check), // Using a Material icon
              ),
            ],
          ),
        ),
      ),
    );
  }
}
