import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthApi {
  static final _googleSignIn = GoogleSignIn(scopes: [
    "https://mail.google.com/"
  ]); // Damit mails gesendet werden könnnen.

  static Future<GoogleSignInAccount?> signIn() async {
 try {
   
    if (await _googleSignIn.isSignedIn() && _googleSignIn.currentUser != null) {
      return _googleSignIn.currentUser;
    }

    final a =  await _googleSignIn.signIn();
    return a;

 } catch (e) {
   print(e);
 }


  }

  static Future changeUser() async {
    await _googleSignIn.signOut();
    await _googleSignIn.signIn();
  }
}
