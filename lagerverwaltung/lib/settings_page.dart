import 'package:flutter/cupertino.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Settings'),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        
      ),
      child: Text("nothing here yet"),
    );
  }
}
