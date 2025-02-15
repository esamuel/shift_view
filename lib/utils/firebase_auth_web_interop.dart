library firebase_auth_web_interop;

import 'package:js/js.dart';
import 'js_interop_utils.dart';

@JS('firebase.auth.Auth')
class AuthWeb {
  external AuthWeb();
  external UserWeb? get currentUser;
  external PromiseJsImpl<UserCredentialWeb> signInWithEmailAndPassword(
      String email, String password);
  external PromiseJsImpl<UserCredentialWeb> createUserWithEmailAndPassword(
      String email, String password);
  external PromiseJsImpl<void> signOut();
}

@JS('firebase.auth.UserCredential')
class UserCredentialWeb {
  external UserWeb? get user;
}

@JS('firebase.auth.User')
class UserWeb {
  external String get uid;
  external String? get email;
  external String? get displayName;
  external String? get photoURL;
  external bool get emailVerified;
  external bool get isAnonymous;
  external PromiseJsImpl<void> delete();
  external PromiseJsImpl<String> getIdToken([bool forceRefresh = false]);
  external PromiseJsImpl<void> reload();
  external PromiseJsImpl<void> sendEmailVerification();
  external PromiseJsImpl<void> updateEmail(String newEmail);
  external PromiseJsImpl<void> updatePassword(String newPassword);
  external PromiseJsImpl<void> updateProfile(UserProfileWeb profile);
}

@JS()
@anonymous
class UserProfileWeb {
  external factory UserProfileWeb({String? displayName, String? photoURL});
  external String? get displayName;
  external String? get photoURL;
}

extension AuthWebExtension on AuthWeb {
  Future<UserCredentialWeb> signInWithEmailAndPasswordFuture(
          String email, String password) =>
      signInWithEmailAndPassword(email, password).toFuture();

  Future<UserCredentialWeb> createUserWithEmailAndPasswordFuture(
          String email, String password) =>
      createUserWithEmailAndPassword(email, password).toFuture();

  Future<void> signOutFuture() => signOut().toFuture();
}

extension UserWebExtension on UserWeb {
  Future<void> deleteFuture() => delete().toFuture();
  Future<String> getIdTokenFuture([bool forceRefresh = false]) =>
      getIdToken(forceRefresh).toFuture();
  Future<void> reloadFuture() => reload().toFuture();
  Future<void> sendEmailVerificationFuture() =>
      sendEmailVerification().toFuture();
  Future<void> updateEmailFuture(String newEmail) =>
      updateEmail(newEmail).toFuture();
  Future<void> updatePasswordFuture(String newPassword) =>
      updatePassword(newPassword).toFuture();
  Future<void> updateProfileFuture(UserProfileWeb profile) =>
      updateProfile(profile).toFuture();
}
