/// Conditional export: uses the web implementation when dart:html is available,
/// otherwise falls back to the stub (returns null for all keys).
export 'js_env_stub.dart' if (dart.library.html) 'js_env_web.dart';
