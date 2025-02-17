import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthApi {
  static final GoogleSignIn _googleSignIn =
      GoogleSignIn(scopes: ["https://mail.google.com/"]);

  static Future<GoogleSignInAccount?> signIn() async {
    if (await _googleSignIn.isSignedIn() && _googleSignIn.currentUser != null) {
      return _googleSignIn.currentUser;
    }
    return await _googleSignIn.signIn();
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  static Future<void> changeUser() async {
    await _googleSignIn.signOut();
    await _googleSignIn.signIn();
  }

  static GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}
