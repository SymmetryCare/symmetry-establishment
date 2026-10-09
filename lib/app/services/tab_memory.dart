import 'dart:html' as html;

/// Remembers which page of a PageView the user was on, so a browser refresh
/// lands them back on it instead of on page 0.
///
/// Backed by `sessionStorage` rather than SharedPreferences on purpose.
/// SharedPreferences on web is `localStorage`, which is shared by every tab
/// and every module on the origin — two tabs, or Establishment and HR behind
/// the shell, would overwrite each other's page. `sessionStorage` is per
/// browser tab and survives a reload, which is exactly the lifetime wanted.
class TabMemory {
  TabMemory._();

  static const String _prefix = 'tabMemory.';

  /// Key for the Establishment desktop PageView.
  static const String establishment = '${_prefix}establishment';

  /// Saved index for [key], or 0 when missing, unreadable, or outside
  /// `0 ..< pageCount` (e.g. a page was removed since it was saved).
  static int read(String key, {required int pageCount}) {
    try {
      final int? index = int.tryParse(html.window.sessionStorage[key] ?? '');
      if (index == null || index < 0 || index >= pageCount) return 0;
      return index;
    } catch (_) {
      return 0;
    }
  }

  static void write(String key, int index) {
    try {
      html.window.sessionStorage[key] = '$index';
    } catch (_) {
      // Storage blocked (privacy mode, sandboxed iframe) — refresh just
      // falls back to page 0.
    }
  }

  /// Forget every remembered page. Call when the session ends so the next
  /// sign-in starts on the first page.
  static void clearAll() {
    try {
      final storage = html.window.sessionStorage;
      storage.keys
          .where((k) => k.startsWith(_prefix))
          .toList()
          .forEach(storage.remove);
    } catch (_) {}
  }
}
