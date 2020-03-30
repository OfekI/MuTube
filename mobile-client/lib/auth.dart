import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final AuthService _instance = new AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static final StreamController<bool> _isLoading =
      StreamController<bool>.broadcast();

  static final Stream<FirebaseUser> user = _auth.onAuthStateChanged;
  static Stream<bool> get isLoading => _isLoading.stream;

  static Future<FirebaseUser> googleSignIn() async {
    _isLoading.add(true);

    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    AuthResult authResult = await _auth.signInWithCredential(
      GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      ),
    );

    _isLoading.add(false);
    return authResult.user;
  }

  static void signOut() {
    _auth.signOut();
  }
}
