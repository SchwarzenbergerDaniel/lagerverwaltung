import 'package:flutter/cupertino.dart';

class ShowDialogTwoOptions {
  static Future<bool> isFirstOptionClicked(BuildContext context, String title,
      String content, String option1, String option2,
      {bool isFirstDefaultAction = true}) async {
    return await showCupertinoDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: isFirstDefaultAction,
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(option1),
                ),
                CupertinoDialogAction(
                  isDefaultAction: !isFirstDefaultAction,
                  child: Text(option2),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
