import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/screen_route_name.dart';
import 'package:symmetry_establishment/app/services/session/app_session.dart';
import 'package:symmetry_establishment/app/services/shell/shell_link.dart';
import 'package:symmetry_establishment/data/navigator_arguments/screen_arguments.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/email_verification/email_verification.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/forget_pass_verification/forget_pass_verification.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/forget_password/forget_password_screen.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/login/login_screen.dart';

/// The signed-out half of Establishment: the login flow.
///
/// The login screens are Navigator 1.0 code — they `pushNamed` each other
/// with arguments and finish with `pushReplacementNamed(emDesktop)` — so they
/// keep their own `MaterialApp` and the route table main.dart used to hold,
/// rather than being rewritten onto the signed-in screens' go_router. Billing
/// splits its app the same way (its lib/legacy/login_flow_app.dart).
///
/// Reaching [RouteStrings.emDesktop] (or `/home`) means the token is written,
/// so that route starts the [AppSession] and main.dart swaps this whole app
/// for the signed-in one.
///
/// Shell-hosted, the login form belongs to the shell: every route that would
/// render one redirects there instead (see [_loginOrShell]).
class LoginFlowApp extends StatelessWidget {
  const LoginFlowApp({
    super.key,
    required this.navigatorKey,
    required this.theme,
    required this.title,
    required this.builder,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final ThemeData theme;
  final String title;

  /// main.dart's start-up work, run with this app's navigator context.
  final TransitionBuilder builder;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: title,
      debugShowCheckedModeBanner: false,
      theme: theme,
      initialRoute: LoginScreen.routeName,
      onGenerateRoute: _generateRoute,
      onGenerateInitialRoutes: _generateInitialRoutes,
      builder: builder,
    );
  }

  /// The one route the login flow opens on.
  ///
  /// Only that route is pushed — Flutter's default would stack `/` under it.
  /// This app only runs signed out, so whatever the address bar says,
  /// including a signed-in page left over from a session that just ended, it
  /// opens on login, or on Forgot password when that is what was asked for.
  List<Route<dynamic>> _generateInitialRoutes(String initialRoute) {
    final String path = Uri.parse(initialRoute).path;
    final String name = path == ForgetPassword.routeName
        ? ForgetPassword.routeName
        : LoginScreen.routeName;
    return <Route<dynamic>>[_generateRoute(RouteSettings(name: name))];
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    final Widget page;

    switch (settings.name) {
      // The login flow completed, so the token is written by now.
      case RouteStrings.emDesktop:
      case RouteStrings.home:
        WidgetsBinding.instance
            .addPostFrameCallback((_) => AppSession.instance.start());
        page = const SizedBox.shrink();
        break;
      case EmailVerification.routeName:
        final email = _emailFrom(settings.arguments);
        page = email == null
            ? _loginOrShell()
            : EmailVerification(email: email);
        break;
      case ForgetPassword.routeName:
        page = const ForgetPassword();
        break;
      case VerifyPassword.routeName:
        final email = _emailFrom(settings.arguments);
        page =
            email == null ? _loginOrShell() : VerifyPassword(email: email);
        break;
      case LoginScreen.routeName:
      default:
        page = _loginOrShell();
        break;
    }

    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }

  /// This app's own login screen, or a redirect to the shell's when hosted.
  ///
  /// The redirect is synchronous, so the empty widget is on screen only until
  /// the browser navigates. The login screen is this app's root route, so a
  /// browser pop is held there instead of leaving the site.
  Widget _loginOrShell() {
    if (ShellLink.signOutToShell()) return const SizedBox.shrink();
    return const PopScope(canPop: false, child: LoginScreen());
  }

  String? _emailFrom(Object? arguments) {
    if (arguments is ScreenArguments) {
      final email = arguments.title?.trim();
      return email == null || email.isEmpty ? null : email;
    }
    return null;
  }
}
