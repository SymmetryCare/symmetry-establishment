import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/controller/controller.dart';

class ResponsiveScreen extends StatelessWidget {
  ResponsiveScreen(
      {super.key,
      required this.mobile,
      required this.web,
      required this.tablet});
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final Widget mobile, web, tablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        controller.checkScreenType(screenWidth);
        if (controller.isTabletScreen.value) {
          return tablet;
        } else if (controller.isMobileScreen.value) {
          return mobile;
        } else if (controller.isDesktopScreen.value) {
          //print("Resolution ${MediaQuery.of(context).size.width}");
          return Padding(
            padding: MediaQuery.of(context).size.width > 1920
                ? EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 8)
                : const EdgeInsets.all(0.0),
            child: web,
          );
        } else {
          return const Scaffold();
          // return SingleChildScrollView(
          // scrollDirection: Axis.vertical, child: HomeScreen());
        }
      },
    );
  }
}
