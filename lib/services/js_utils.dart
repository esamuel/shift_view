@JS()
library js_utils;

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
