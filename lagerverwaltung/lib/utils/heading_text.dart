import 'package:flutter/cupertino.dart';

class HeadingText extends StatelessWidget {
  String text;
  bool addSizedBox;
  HeadingText({super.key, required this.text, this.addSizedBox = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white, // Adjust color as needed
          ),
        ),
        SizedBox(height: addSizedBox ? 25 : 0),
      ],
    );
  }
}
