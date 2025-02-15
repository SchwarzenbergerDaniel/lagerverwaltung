import 'package:flutter/cupertino.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';

class CustomAppBar extends CupertinoNavigationBar {
  CustomAppBar({
    super.key,
    required String title,
    Widget? leading,
    CupertinoButton? trailing,
  }) : super(
          middle: Builder(
            builder: (context) => Text(
              title,
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
          ),
          leading: leading ?? const CustomBackButton(),
          backgroundColor: CupertinoColors.transparent,
          enableBackgroundFilterBlur: false,
          automaticBackgroundVisibility: false,
          border: null,
          trailing: trailing,
        );
}