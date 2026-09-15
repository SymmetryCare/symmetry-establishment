import 'package:flutter/material.dart';

typedef OnClickableTap = Function();
typedef OnClickableHover = Function(bool val);

class AppClickableWidget extends StatelessWidget {
  const AppClickableWidget(
      {super.key,
      required this.onTap,
      required this.child,
      required this.onHover});
  final OnClickableTap onTap;
  final OnClickableHover onHover;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          onTap();
        },
        onHover: (value) {
          onHover(value);
        },
        focusColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: child);
  }
}
