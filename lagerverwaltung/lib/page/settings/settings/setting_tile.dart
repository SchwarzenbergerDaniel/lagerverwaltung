import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  final String bezeichnung;
  final Icon icon;
  Widget? page;
  VoidCallback? onTap;

  SettingTile(
      {super.key,
      required this.bezeichnung,
      required this.icon,
      this.page,
      this.onTap});

  void onGesture(BuildContext context) {
    if (page != null) {
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => page!),
      );
    } else {
      onTap!.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onGesture(context);
      },
      onHorizontalDragEnd: (details) {
        onGesture(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                bezeichnung,
                style: CupertinoTheme.of(context).textTheme.textStyle,
              ),
            ),
            Icon(
              Icons.arrow_right,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }
}
