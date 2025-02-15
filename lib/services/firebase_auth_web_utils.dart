@JS()
library firebase_auth_web_utils;

import 'package:js/js.dart';
import 'js_utils.dart';

@JS('firebase.auth')
class FirebaseAuthWeb {
  external static AuthWeb getAuth();
}

@JS()
@anonymous
class AuthWeb {
  external factory AuthWeb();
  external Promise<UserCredentialWeb> signInWithEmailAndPassword(
      String email, String password);
  external Promise<UserCredentialWeb> createUserWithEmailAndPassword(
      String email, String password);
  external Promise<void> signOut();
  external UserWeb? get currentUser;
}

@JS()
@anonymous
class UserWeb {
  external String get uid;
  external String? get email;
  external String? get displayName;
  external Promise<void> delete();
  external Promise<String> getIdToken([bool forceRefresh]);
  external Promise<void> sendEmailVerification();
  external Promise<void> updateEmail(String newEmail);
  external Promise<void> updatePassword(String newPassword);
  external Promise<void> updateProfile(UserProfileWeb profile);
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

@JS('Promise')
class Promise<T> {
  external Promise(
      void Function(void Function(T) resolve, void Function(Object) reject)
          executor);
  external Promise then(void Function(T) onFulfilled,
      [void Function(Object) onRejected]);
}

extension AuthWebExtension on AuthWeb {
  Future<UserCredentialWeb> signInWithEmailAndPasswordFuture(
      String email, String password) {
    return signInWithEmailAndPassword(email, password)
        .asThenable<UserCredentialWeb>();
  }

  Future<UserCredentialWeb> createUserWithEmailAndPasswordFuture(
      String email, String password) {
    return createUserWithEmailAndPassword(email, password)
        .asThenable<UserCredentialWeb>();
  }

  Future<void> signOutFuture() {
    return signOut().asThenable<void>();
  }
}

extension UserWebExtension on UserWeb {
  Future<void> deleteFuture() {
    return delete().asThenable<void>();
  }

  Future<String> getIdTokenFuture([bool forceRefresh = false]) {
    return getIdToken(forceRefresh).asThenable<String>();
  }

  Future<void> sendEmailVerificationFuture() {
    return sendEmailVerification().asThenable<void>();
  }

  Future<void> updateEmailFuture(String newEmail) {
    return updateEmail(newEmail).asThenable<void>();
  }

  Future<void> updatePasswordFuture(String newPassword) {
    return updatePassword(newPassword).asThenable<void>();
  }

  Future<void> updateProfileFuture(UserProfileWeb profile) {
    return updateProfile(profile).asThenable<void>();
  }
}
