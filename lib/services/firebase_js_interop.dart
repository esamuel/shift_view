@JS()
library firebase_js_interop;

import 'package:js/js.dart';
import 'package:js/js_util.dart' as js_util;

@JS('Promise')
class PromiseJsImpl<T> {
  external PromiseJsImpl(Function executor);
  external PromiseJsImpl then(Function onFulfilled, [Function? onRejected]);
}

@JS('Object')
class ObjectJsImpl {
  external static List<String> keys(Object obj);
}

Future<T> handleThenable<T>(Object jsPromise) {
  return js_util.promiseToFuture<T>(jsPromise);
}

dynamic jsify(Object? dartObject) {
  return js_util.jsify(dartObject);
}

dynamic dartify(Object? jsObject) {
  return js_util.dartify(jsObject);
}

dynamic callMethod(Object o, String method, List<dynamic> args) {
  return js_util.callMethod(o, method, args);
}

dynamic getProperty(Object o, Object name) {
  return js_util.getProperty(o, name);
}

void setProperty(Object o, Object name, Object? value) {
  js_util.setProperty(o, name, value);
}

bool hasProperty(Object o, Object name) {
  return js_util.hasProperty(o, name);
}

dynamic newObject() {
  return js_util.newObject();
}

extension PromiseJsImplExtension<T> on PromiseJsImpl<T> {
  Future<T> asFuture() => handleThenable<T>(this);
}

extension ObjectJsImplExtension on ObjectJsImpl {
  static List<String> getKeys(Object obj) => ObjectJsImpl.keys(obj);
}

extension HandleThenableExtension on Object {
  Future<T> asThenable<T>() => handleThenable<T>(this);
}

extension JsifyExtension on Object? {
  dynamic toJS() => jsify(this);
}

extension DartifyExtension on Object? {
  dynamic toDart() => dartify(this);
}

@JS('firebase.auth')
class FirebaseAuthWeb {
  external static AuthWeb getAuth();
}

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
}

@JS()
@anonymous
class UserWeb {
  external String get uid;
  external String? get email;
  external String? get displayName;
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
