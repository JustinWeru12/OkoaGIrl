import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<String> signInWithOTP(smsCode, verId);

  Future<User> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> resetPassword(String email);

  Future<void> signOut();

  Future<bool> isEmailVerified();

  Future<String> currentUser() async {
    User user = _firebaseAuth.currentUser;
    return user != null ? user.uid : null;
  }

  Future<String> userEmail() async {
    User user = _firebaseAuth.currentUser;
    //print('USER EMAIL : ' + user.email);
    return user != null ? user.email : null;
  }

  Future<String> signInWithGoogle() async {
    return null;
  }

  void signOutGoogle() async {}
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Stream<String> get onAuthStateChanged => _firebaseAuth.authStateChanges().map(
        (User user) => user?.uid,
      );

  Future<String> signIn(String email, String password) async {
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    if (result.user.emailVerified) {
      return result.user.uid;
    }
    return null;
  }

  Future<String> getCurrentUID() async {
    return (_firebaseAuth.currentUser).uid;
  }

  Future<User> getCurrentUser() async {
    User user = _firebaseAuth.currentUser;
    return user;
  }

  Future<String> currentUser() async {
    User user = _firebaseAuth.currentUser;
    //print('USERID : ' + user.uid);
    return user != null ? user.uid : null;
  }

  Future<String> userEmail() async {
    User user = _firebaseAuth.currentUser;
    //print('USER EMAIL : ' + user.email);
    return user != null ? user.email : null;
  }

  Future<String> signUp(String email, String password) async {
    UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    User user = result.user;
    try {
      await user.sendEmailVerification();
      return result.user.uid;
    } catch (e) {
      print("An error occured while trying to send email verification");
      print(e.message);
    }
    return null;
  }

  Future<void> resetPassword(String email) async {
    _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future updateUserName(String name, User currentUser) async {
    await currentUser.updateProfile();
    await currentUser.reload();
  }

  Future convertUserWithEmail(
      String email, String password, String name) async {
    final currentUser = _firebaseAuth.currentUser;

    final credential =
        EmailAuthProvider.credential(email: email, password: password);
    await currentUser.linkWithCredential(credential);
    await updateUserName(name, currentUser);
  }

  Future<void> signOut() async {
    _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    User user = _firebaseAuth.currentUser;
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    User user = _firebaseAuth.currentUser;
    return user.emailVerified;
  }

  Future<String> signInWithOTP(smsCode, verId) async {
    AuthCredential authCreds = PhoneAuthProvider.credential(
        verificationId: verId, smsCode: smsCode);
    final User user =
        (await _firebaseAuth.signInWithCredential(authCreds)).user;
    return user.uid;
  }

  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    final User user = userCredential.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _firebaseAuth.currentUser;
    assert(user.uid == currentUser.uid);

    return 'signInWithGoogle succeeded: $user';
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();

    print("User Sign Out");
  }
}
