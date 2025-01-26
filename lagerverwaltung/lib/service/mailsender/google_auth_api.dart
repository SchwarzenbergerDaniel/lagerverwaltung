import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthApi {
  static final _googleSignIn = GoogleSignIn(scopes: [
    "https://mail.google.com/"
  ]); // Damit mails gesendet werden könnnen.

  static Future<GoogleSignInAccount?> signIn() async {
    if (await _googleSignIn.isSignedIn() && _googleSignIn.currentUser != null) {
      return _googleSignIn.currentUser;
    }

    return await _googleSignIn.signIn();
  }
}
