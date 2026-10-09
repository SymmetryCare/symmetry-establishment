import 'package:flutter/foundation.dart';

/// Whether Establishment is showing its signed-in screens or its login flow.
///
/// The two are separate apps (see `main.dart`): the login screens are
/// Navigator 1.0 code that `pushNamed` each other, while the signed-in screens
/// live on go_router with one URL per page. This is the switch between them —
/// the same split symmetry-Billing makes with its SessionProvider.
///
/// A singleton, because session expiry is noticed in `Api`'s interceptor,
/// which has no widget tree to look a provider up in.
class AppSession extends ChangeNotifier {
  AppSession._();

  static final AppSession instance = AppSession._();

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  /// The login flow finished and wrote the token, or the app booted with one.
  void start() {
    if (_isSignedIn) return;
    _isSignedIn = true;
    notifyListeners();
  }

  /// The session is over (sign-out or expiry); the token is already cleared.
  ///
  /// Returns whether this swapped the signed-in screens for the login flow.
  /// When it returns false the login flow is already up, and the caller
  /// navigates within it the way it always has.
  bool end() {
    if (!_isSignedIn) return false;
    _isSignedIn = false;
    notifyListeners();
    return true;
  }
}
