import 'package:flutter/material.dart';
import 'package:lagerverwaltung/buttons/home_page_button_base.dart';

class ArtikelAmountChangeButton extends StatelessWidget {
  const ArtikelAmountChangeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePageButtonBase(
        title: "Menge erhöhen / vermindern",
        icon: Icons.exposure,
        backgroundColor: Color.fromRGBO(247, 119, 162, 1),
        onPressed: () => changeAmount(context));
  }

  void changeAmount(BuildContext context) async {
    // TODO: IMPLEMENT:
  }
}
