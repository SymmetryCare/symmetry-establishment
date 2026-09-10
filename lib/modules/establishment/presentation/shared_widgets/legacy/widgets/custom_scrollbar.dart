import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';

class CustomScrollbar extends StatelessWidget {
  final ScrollController controller;
  final Widget child;
  final Axis scrollDirection;
  final bool thumbVisibility;
  final bool interactive;

  const CustomScrollbar({
    super.key,
    required this.controller,
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.thumbVisibility = true,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(ColorManager.blueprime),
        ),
      ),
      child: Scrollbar(
        controller: controller,
        thumbVisibility: thumbVisibility,
        interactive: interactive,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            overscroll: false,
          ),
          child: child,
        ),
      ),
    );
  }
}


























// import 'package:flutter/material.dart';
// import 'package:prohealth/app/resources/color.dart';
//
// class CustomScrollbar extends StatelessWidget {
//   final ScrollController controller;
//   final Widget child;
//   final Axis scrollDirection;
//   final bool thumbVisibility;
//   final bool interactive;
//
//   const CustomScrollbar({
//     super.key,
//     required this.controller,
//     required this.child,
//     this.scrollDirection = Axis.vertical,
//     this.thumbVisibility = true,
//     this.interactive = true,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Theme(
//       data: Theme.of(context).copyWith(
//         scrollbarTheme: ScrollbarThemeData(
//           thumbColor: WidgetStateProperty.all(ColorManager.bluebottom),
//         ),
//       ),
//       child: Scrollbar(
//         controller: controller,
//         thumbVisibility: thumbVisibility,
//         interactive: interactive,
//         child: child,
//       ),
//     );
//   }
// }
