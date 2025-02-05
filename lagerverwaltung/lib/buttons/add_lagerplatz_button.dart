import 'package:flutter/material.dart';
import 'package:lagerverwaltung/buttons/home_page_button_base.dart';

class AddLagerplatzButton extends StatelessWidget {
  const AddLagerplatzButton({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePageButtonBase(
        title: "Lagerplatz hinzufügen",
        icon: Icons.warehouse,
        backgroundColor: Color.fromRGBO(131, 166, 241, 1),
        onPressed: () => addLagerplatz(context));
  }

  void addLagerplatz(BuildContext context) async {
    // TODO: IMPLEMENT:
  }
}
