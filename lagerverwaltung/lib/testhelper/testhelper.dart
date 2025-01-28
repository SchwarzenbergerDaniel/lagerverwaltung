import 'package:shared_preferences/shared_preferences.dart';

class Testhelper {
  static Future clearLocalStorage() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
  }
}
