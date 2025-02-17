import 'package:google_sign_in/google_sign_in.dart';

class AuthManager {
  final GoogleSignIn _googleSignIn;

  AuthManager(this._googleSignIn);

  Future<GoogleSignInAccount?> signIn() async {
    if (await _googleSignIn.isSignedIn() && _googleSignIn.currentUser != null) {
      return _googleSignIn.currentUser;
    }
    return await _googleSignIn.signIn();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}
