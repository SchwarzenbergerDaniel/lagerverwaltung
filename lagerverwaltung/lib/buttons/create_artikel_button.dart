import 'package:flutter/material.dart';
import 'package:lagerverwaltung/buttons/home_page_button_base.dart';

class CreateArtikelButton extends StatelessWidget {
  const CreateArtikelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePageButtonBase(
        title: "Artikel erstellen",
        icon: Icons.add_box,
        backgroundColor: Color.fromRGBO(211, 153, 241, 1),
        onPressed: () => createArtikel(context));
  }

  void createArtikel(BuildContext context) async {
    // TODO: IMPLEMENT:
  }
}
