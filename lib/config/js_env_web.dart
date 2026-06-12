import 'dart:js_util' as js_util;
import 'dart:html' as html;

/// Web implementation: reads environment variables from window._flutterEnv
/// which is populated by JavaScript in index.html before Flutter boots.
String? getJsEnv(String key) {
  try {
    final env = js_util.getProperty(html.window, '_flutterEnv');
    if (env != null) {
      final value = js_util.getProperty(env, key);
      if (value != null) {
        final str = value.toString();
        if (str.isNotEmpty && str != 'null' && str != 'undefined') {
          return str;
        }
      }
    }
  } catch (_) {
    // Silently fail — fall through to other env sources
  }
  return null;
}
