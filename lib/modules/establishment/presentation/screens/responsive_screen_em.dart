import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:symmetry_establishment/app/resources/screen_route_name.dart';
import 'package:symmetry_establishment/app/router/em_routes.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/em_desktop_screen.dart';

/// The signed-in frame — header, the current [page] as [child], footer — or
/// the tablet placeholder below 850px. Built by the router's ShellRoute around
/// whichever page the URL names (see app/router/em_router.dart).
class ResponsiveScreenEM extends StatelessWidget {
  static const String routeName = RouteStrings.emDesktop;
  ResponsiveScreenEM({super.key, required this.page, required this.child});

  /// The page the URL names; drives the header's highlight.
  final EmPage page;

  /// That page's screen.
  final Widget child;

  final ButtonSelectionController myController = Get.put(
    ButtonSelectionController(),
  );
  @override
  Widget build(BuildContext context) {
    // Browser Back and Forward are the router's now — they move between the
    // pages visited — so there is no pop to intercept here any more.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 850) {
          return Padding(
            padding: MediaQuery.of(context).size.width > 1920
                ? EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 8,
                  )
                : EdgeInsets.all(0.0),
            child: EMDesktopScreen(page: page, child: child),
          );
        } else {
          return Material(
            color: Colors.white,
            child: Center(
              child: SvgPicture.asset(
                'images/tablet.svg',
                fit: BoxFit.contain,
              ),
            ),
          );
        }
      },
    );
  }
}

class SMTablet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tablet Screen')),
      body: Center(
        child: Text('Tablet Screen Content', style: TextStyle(fontSize: 24.0)),
      ),
    );
  }
}
