import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/login_resources/login_flow_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';

import 'package:symmetry_establishment/app/resources/color.dart';

/// new code
class LoginBaseConstant extends StatelessWidget {
  LoginBaseConstant(
      {Key? key,
      required this.child,
      required this.onTap,
      required this.titleText,
      required this.textAction,
      this.textActionPadding,
      this.containerHeight,
      this.containerWidth})
      : super(key: key);
  final Widget child;
  final String titleText;
  final VoidCallback onTap;
  final String textAction;
  final double? containerHeight;
  final double? containerWidth;
  final EdgeInsetsGeometry? textActionPadding;
  final SvgPicture backImg = SvgPicture.asset(
    "images/background.svg",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(children: [
          Container(
              width: double.maxFinite,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.bottomRight,
                        child: SvgPicture.asset(
                          key: UniqueKey(),
                          placeholderBuilder: (BuildContext context) =>
                              Container(
                            width: 25,
                            height: 25,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: ColorManager.blueprime,
                              ),
                            ),
                          ),
                          'images/vector.svg',
                          height: MediaQuery.of(context).size.height / 1.25,
                          // width: MediaQuery.of(context).size.width / 1,
                        ),
                      ),
                    ],
                  ),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: SvgPicture.asset(
                              key: UniqueKey(),
                              'images/vector1.svg',
                              height: MediaQuery.of(context).size.height / 1,
                              width: MediaQuery.of(context).size.width),
                        ),
                      ]),
                ],
              )),
          Padding(
            padding: const EdgeInsets.all(AppPadding.p30),
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 9, sigmaY: 5),
                child: Container(
                  // height: MediaQuery.of(context).size.height,
                  // width: MediaQuery.of(context).size.width,
                  height: containerHeight ?? MediaQuery.of(context).size.height,
                  width: containerWidth ?? MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.045),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(1, 4),
                      ),
                    ],
                    color: ColorManager.white.withOpacity(0.35),
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Container(
                            decoration: const BoxDecoration(
                              // color: Colors.green,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(25),
                                  topLeft: Radius.circular(25)),
                            ),
                            padding: const EdgeInsets.only(left: 20, top: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  titleText,
                                  style:
                                      LoginFlowHeading.customTextStyle(context),
                                ),
                                const SizedBox(height: 20),
                                child,
                                const SizedBox(height: 20),

                                ///bottom text
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding:
                                            const EdgeInsets.only(right: 35),
                                        //color: ColorManager.red,
                                        alignment: Alignment.centerRight,
                                        child: InkWell(
                                          onTap: onTap,
                                          child: Text(
                                            textAction,
                                            textAlign: TextAlign.center,
                                            style:
                                                LoginFlowBase.customTextStyle(
                                                    context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),

                      ///logo, amico image
                      Expanded(
                        flex: 2,
                        child: Container(
                            decoration: const BoxDecoration(
                              // color: Colors.red,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(25),
                                  bottomRight: Radius.circular(25)),
                            ),
                            // color: Colors.yellow,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                  key: UniqueKey(),
                                  'images/logo_login.png',
                                  width: MediaQuery.of(context).size.width / 5,
                                  height:
                                      MediaQuery.of(context).size.height / 5,
                                ),
                                Expanded(
                                  child: SvgPicture.asset(
                                    key: UniqueKey(),
                                    'images/amico.svg',
                                    // fit: BoxFit.fill,
                                  ),
                                  // Image.asset(
                                  //   'images/amico.png',
                                  // ),
                                ),
                              ],
                            )),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: AppSize.s2,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppString.poweredby,
                  style: LoginFlowBottomBar.customTextStyle(context),
                ),
                const SizedBox(
                  width: AppSize.s2,
                ),
                Image.asset('images/powered_logo.png',
                    width: AppSize.s25, height: AppSize.s25)
              ],
            ),
          )
        ]),
      ),
    );
  }
}
