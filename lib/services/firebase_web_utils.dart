@JS()
library firebase_web_utils;

import 'package:js/js.dart';
import 'js_utils.dart';

@JS()
@anonymous
class ActionCodeInfo {
  external factory ActionCodeInfo();
}

@JS()
@anonymous
class AuthJsImpl {
  external factory AuthJsImpl();
  external PromiseJsImpl<void> signOut();
  external PromiseJsImpl<UserCredentialJsImpl> signInWithEmailAndPassword(
      String email, String password);
  external PromiseJsImpl<UserCredentialJsImpl> createUserWithEmailAndPassword(
      String email, String password);
  external PromiseJsImpl<void> sendPasswordResetEmail(String email);
}

@JS()
@anonymous
class UserCredentialJsImpl {
  external factory UserCredentialJsImpl();
  external UserJsImpl get user;
}

@JS()
@anonymous
class UserJsImpl {
  external factory UserJsImpl();
  external String get uid;
  external String? get email;
  external String? get displayName;
  external bool get emailVerified;
  external PromiseJsImpl<void> delete();
  external PromiseJsImpl<String> getIdToken([bool? forceRefresh]);
  external PromiseJsImpl<void> reload();
}

@JS()
@anonymous
class ConfirmationResultJsImpl {
  external factory ConfirmationResultJsImpl();
  external PromiseJsImpl<UserCredentialJsImpl> confirm(String verificationCode);
}

@JS()
@anonymous
class MultiFactorSessionJsImpl {
  external factory MultiFactorSessionJsImpl();
}

@JS()
@anonymous
class TotpSecretJsImpl {
  external factory TotpSecretJsImpl();
}

@JS()
@anonymous
class IdTokenResultImpl {
  external factory IdTokenResultImpl();
  external String get token;
  external DateTime get expirationTime;
  external DateTime get authTime;
  external DateTime get issuedAtTime;
  external String get signInProvider;
}

@JS()
@anonymous
class AuthError {
  external String get code;
  external String get message;
  external factory AuthError();
}

Future<T> handleFirebasePromise<T>(Object jsPromise) async {
  try {
    return await handleThenable<T>(jsPromise);
  } catch (e) {
    if (e is AuthError) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message,
      );
    }
    rethrow;
  }
}

class FirebaseAuthException implements Exception {
  final String code;
  final String message;

  FirebaseAuthException({required this.code, required this.message});

  @override
  String toString() => 'FirebaseAuthException: $message (code: $code)';
}
