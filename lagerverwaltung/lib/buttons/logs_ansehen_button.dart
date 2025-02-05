import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lagerverwaltung/buttons/home_page_button_base.dart';
import 'package:lagerverwaltung/page/logs/log_page.dart';

class LogsAnsehenButton extends StatelessWidget {
  LogsAnsehenButton({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePageButtonBase(
        title: "Logs ansehen",
        icon: Icons.list_alt,
        backgroundColor: Color.fromRGBO(210, 237, 142, 1),
        onPressed: () => logsAnsehen(context));
  }

  void logsAnsehen(BuildContext context) async {
    Navigator.push(
        context, CupertinoPageRoute(builder: (context) => LogPage()));
  }
}
