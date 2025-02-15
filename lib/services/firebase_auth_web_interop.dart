@JS()
library firebase_auth_web_interop;

import 'package:js/js.dart';
import '../utils/js_interop_utils.dart';

@JS('firebase.auth')
external AuthWeb auth();

@JS()
@anonymous
class AuthWeb {
  external factory AuthWeb();
  external PromiseJsImpl<UserCredentialWeb> signInWithEmailAndPassword(
      String email, String password);
  external PromiseJsImpl<UserCredentialWeb> createUserWithEmailAndPassword(
      String email, String password);
  external PromiseJsImpl<void> signOut();
  external UserWeb? get currentUser;
  external PromiseJsImpl<void> sendPasswordResetEmail(String email);
}

@JS()
@anonymous
class UserWeb {
  external String get uid;
  external String? get email;
  external String? get displayName;
  external String? get photoURL;
  external bool get emailVerified;
  external bool get isAnonymous;
  external PromiseJsImpl<void> delete();
  external PromiseJsImpl<String> getIdToken([bool forceRefresh]);
  external PromiseJsImpl<void> sendEmailVerification();
  external PromiseJsImpl<void> updateEmail(String newEmail);
  external PromiseJsImpl<void> updatePassword(String newPassword);
  external PromiseJsImpl<void> updateProfile(UserProfileWeb profile);
}

@JS()
@anonymous
class UserCredentialWeb {
  external UserWeb get user;
}

@JS()
@anonymous
class UserProfileWeb {
  external factory UserProfileWeb({String? displayName, String? photoURL});
}

extension AuthWebExtension on AuthWeb {
  Future<UserCredentialWeb> signInWithEmailAndPasswordFuture(
      String email, String password) {
    return signInWithEmailAndPassword(email, password).toFuture();
  }

  Future<UserCredentialWeb> createUserWithEmailAndPasswordFuture(
      String email, String password) {
    return createUserWithEmailAndPassword(email, password).toFuture();
  }

  Future<void> signOutFuture() {
    return signOut().toFuture();
  }

  Future<void> sendPasswordResetEmailFuture(String email) {
    return sendPasswordResetEmail(email).toFuture();
  }
}

extension UserWebExtension on UserWeb {
  Future<void> deleteFuture() {
    return delete().toFuture();
  }

  Future<String> getIdTokenFuture([bool forceRefresh = false]) {
    return getIdToken(forceRefresh).toFuture();
  }

  Future<void> sendEmailVerificationFuture() {
    return sendEmailVerification().toFuture();
  }

  Future<void> updateEmailFuture(String newEmail) {
    return updateEmail(newEmail).toFuture();
  }

  Future<void> updatePasswordFuture(String newPassword) {
    return updatePassword(newPassword).toFuture();
  }

  Future<void> updateProfileFuture(UserProfileWeb profile) {
    return updateProfile(profile).toFuture();
  }
}
