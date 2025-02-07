import 'package:flutter/cupertino.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';

class ChangeLogoPage extends StatelessWidget {
  const ChangeLogoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Gradwohl Logo ändern',
          style: CupertinoTheme.of(context).textTheme.textStyle,
        ),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: CustomBackButton(),
      ),
      child: SafeArea(
        child: Center(),
      ),
    );
  }
}
