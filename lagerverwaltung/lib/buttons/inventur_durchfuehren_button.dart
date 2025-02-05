import 'package:flutter/material.dart';
import 'package:lagerverwaltung/buttons/home_page_button_base.dart';

class InventurDurchfuehrenButton extends StatelessWidget {
  const InventurDurchfuehrenButton({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePageButtonBase(
        title: "Inventur durchführen",
        icon: Icons.assignment,
        backgroundColor: Color.fromRGBO(135, 241, 211, 1),
        onPressed: () => inventurDurchfuehren(context));
  }

  void inventurDurchfuehren(BuildContext context) async {
    // TODO: IMPLEMENT:
  }
}
