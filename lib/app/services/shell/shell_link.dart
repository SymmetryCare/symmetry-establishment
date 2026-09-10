import 'dart:html' as html;

import 'package:flutter/foundation.dart' show VoidCallback;

/// Whether this Establishment build is hosted behind symmetry-shell, and how to get back.
///
/// Establishment runs in two shapes and both have to keep working:
///
/// * **Standalone** — Establishment served at the site root, its own login screen, no
///   module picker. This is what every existing tenant runs today.
/// * **Shell-hosted** — symmetry-shell at `/`, Establishment at `/establishment/`, on one origin. The
///   user signs in once at the shell, picks Establishment Manager, and Establishment opens
///   already signed in because `TokenManager` reads the session out of
///   `localStorage`, which is shared across paths on the same origin.
///
/// Which one is decided at build time by [_shellPath], and it defaults to
/// **empty — standalone**. So nothing here changes how Establishment behaves unless the
/// deployer explicitly opts in with:
///
/// ```
/// flutter build web --base-href=/establishment/ --dart-define=SHELL_PATH=/
/// ```
///
/// That default is the point: a build that forgets the flag degrades to today's
/// behaviour rather than sending users to a page that may not be deployed.
class ShellLink {
  ShellLink._();

  /// Path the shell is served from, e.g. "/". Empty means "no shell".
  static const String _shellPath = String.fromEnvironment(
    'SHELL_PATH',
    defaultValue: '',
  );

  /// True when this build is hosted behind the shell.
  static bool get isHosted => _shellPath.isNotEmpty;

  /// Absolute URL of the shell, or null when standalone.
  static String? get shellUrl =>
      isHosted ? '${Uri.base.origin}$_shellPath' : null;

  /// Send the browser back to the shell's module picker.
  ///
  /// The shell boots straight to the picker when a session exists, so this
  /// needs no route or parameter — it just goes to the shell and the shell
  /// works out that the user is signed in.
  static void backToModules() {
    final String? url = shellUrl;
    if (url == null) return;
    html.window.location.assign(url);
  }

  /// [backToModules] when shell-hosted, otherwise null.
  ///
  /// Shaped for `onTap:` slots so a standalone build leaves the control inert
  /// exactly as it is today, instead of showing a button that goes nowhere.
  static VoidCallback? get backToModulesOrNull =>
      isHosted ? backToModules : null;

  /// Where Establishment should send a user whose session has ended.
  ///
  /// Standalone, that is Establishment's own login screen (unchanged). Shell-hosted, the
  /// login screen lives in the shell — and leaving the user on Establishment's copy would
  /// mean two login screens on one origin, with the shell's module picker never
  /// entered. Returns null when the caller should navigate in-app as before.
  static void signOutRedirect() {
    final String? url = shellUrl;
    if (url == null) return;
    // replace, not assign: a signed-out session must not be reachable by
    // pressing Back.
    html.window.location.replace(url);
  }
}
