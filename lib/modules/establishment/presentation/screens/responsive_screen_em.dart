import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:symmetry_establishment/app/resources/screen_route_name.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/em_desktop_screen.dart';

class ResponsiveScreenEM extends StatelessWidget {
  static const String routeName = RouteStrings.emDesktop;
  ResponsiveScreenEM({super.key});
  final ButtonSelectionController myController =
      Get.put(ButtonSelectionController());
  @override
  Widget build(BuildContext context) {
    myController.selectButton(0);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 850) {
          return Padding(
            padding: MediaQuery.of(context).size.width > 1920
                ? EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 8)
                : EdgeInsets.all(0.0),
            child: EMDesktopScreen(),
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
      appBar: AppBar(
        title: Text('Tablet Screen'),
      ),
      body: Center(
        child: Text(
          'Tablet Screen Content',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
