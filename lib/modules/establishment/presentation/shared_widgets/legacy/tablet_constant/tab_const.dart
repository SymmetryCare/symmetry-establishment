import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/login_resources/login_flow_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';

class LoginBaseConstTab extends StatelessWidget {
  final Widget childTab;
  final String titleText;
  final VoidCallback onTap;
  final String textAction;
  final EdgeInsetsGeometry? textActionPadding;

  const LoginBaseConstTab(
      {required this.childTab,
      required this.titleText,
      required this.onTap,
      required this.textAction,
      this.textActionPadding});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ///bg images
          Container(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ///left bg
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: SvgPicture.asset(
                          'images/tab_images/tab_bg_left.svg',
                          height: MediaQuery.of(context).size.height / 1.5,
                          //width: MediaQuery.of(context).size.width/1,
                        ),
                      )
                    ]),

                ///right bg
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: SvgPicture.asset(
                        'images/tab_images/tab_bg_right.svg',
                        height: MediaQuery.of(context).size.height / 2.3,
                        // width: MediaQuery.of(context).size.width / 1,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.p20, vertical: AppPadding.p30),
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 9, sigmaY: 5),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff000000).withOpacity(0.045),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(1, 4),
                      ),
                    ],
                    color: ColorManager.white.withOpacity(0.35),
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Image.asset(
                          'images/logo_login.png',
                          width: MediaQuery.of(context).size.width / 3.3,
                          height: MediaQuery.of(context).size.height / 10,
                        ),
                      ),
                      Expanded(
                          flex: 3,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width / 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ///title text
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      titleText,
                                      textAlign: TextAlign.start,
                                      style: LoginFlowHeading.customTextStyle(
                                        context,
                                        fontSize: FontSize.s24,
                                      ),
                                    ),
                                  ],
                                ),
                                childTab,
                                ///bottom text
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: onTap,
                                      child: Text(
                                        textAction,
                                        textAlign: TextAlign.end,
                                        style: LoginFlowBase.customTextStyle(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                      Expanded(
                        flex: 2,
                        child: Image.asset(
                          'images/amico.png',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          ///powered by
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
                    width: AppSize.s24, height: AppSize.s20),
                // SizedBox(
                //   height: AppSize.s20,
                // ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
