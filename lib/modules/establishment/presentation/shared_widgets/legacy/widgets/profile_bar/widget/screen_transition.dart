import 'package:flutter/material.dart';

const RouteTransitionDuration = Duration(milliseconds: 500);
const RouteTransitionCurve = Curves.ease;

class RouteTransitions {
  static Route slideTransition({required Widget page}) {
    return PageRouteBuilder(
      transitionDuration: RouteTransitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        var tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: RouteTransitionCurve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
