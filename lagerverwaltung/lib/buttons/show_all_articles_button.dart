import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:lagerverwaltung/buttons/base/base_button.dart';
import 'package:lagerverwaltung/page/lagerliste_page.dart';
import 'package:lagerverwaltung/service/lagerlistenverwaltung_service.dart';

class ShowAllArticlesButton extends StatelessWidget {
  ShowAllArticlesButton({super.key});
  final lagerListenVerwaltungsService =
      GetIt.instance<LagerlistenVerwaltungsService>();

  @override
  Widget build(BuildContext context) {
    final double containerWidth = MediaQuery.of(context).size.width * 0.5;
    return SizedBox(
      width: containerWidth,
      child: BaseButton(
        title: "Artikel anzeigen",
        accentColor: Color.fromRGBO(164, 38, 147, 1),
        onPressed: () => show_all_articles(context),
        isPrimary: false,
      ),
    );
  }

  void show_all_articles(BuildContext context) async {
    final articles = await lagerListenVerwaltungsService.artikelEntries;
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => LagerlistePage(
          lagerlistenEntries: articles,
        ),
      ),
    );
  }
}
