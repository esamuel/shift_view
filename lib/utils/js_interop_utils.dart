@JS()
library js_interop_utils;

import 'dart:async';
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

extension PromiseJsExtension<T> on PromiseJsImpl<T> {
  Future<S> toFuture<S>() {
    final completer = Completer<S>();
    then(allowInterop((value) => completer.complete(value)),
        allowInterop((error) => completer.completeError(error)));
    return completer.future;
  }
}

T dartify<T>(dynamic jsObject) => js_util.dartify(jsObject) as T;
dynamic jsify(Object dartObject) => js_util.jsify(dartObject);

extension ObjectJsExtension on Object {
  bool hasProperty(String name) => js_util.hasProperty(this, name);
  dynamic getProperty(String name) => js_util.getProperty(this, name);
  void setProperty(String name, dynamic value) =>
      js_util.setProperty(this, name, value);
  dynamic callMethod(String method, List<dynamic> args) =>
      js_util.callMethod(this, method, args);
}

Future<T> handleThenable<T>(dynamic thenable) {
  if (thenable is Future) {
    return thenable as Future<T>;
  }
  if (thenable is PromiseJsImpl) {
    return thenable.toFuture<T>();
  }
  final promise = js_util.promiseToFuture<T>(thenable);
  return promise;
}

dynamic callMethod(dynamic object, String method, [List<dynamic>? args]) =>
    js_util.callMethod(object, method, args ?? []);

dynamic getProperty(dynamic object, String property) =>
    js_util.getProperty(object, property);

void setProperty(dynamic object, String property, dynamic value) =>
    js_util.setProperty(object, property, value);

bool hasProperty(dynamic object, String property) =>
    js_util.hasProperty(object, property);

dynamic newObject() => js_util.newObject();

T Function(List<dynamic>) allowFunction<T>(
        T Function(List<dynamic>) function) =>
    allowInterop(function);

extension FutureExtension<T> on Future<T> {
  PromiseJsImpl<S> asPromise<S>() {
    return PromiseJsImpl<S>((resolve, reject) {
      then(
        (value) => resolve(value as S),
        onError: (error) => reject(error),
      );
    });
  }
}
