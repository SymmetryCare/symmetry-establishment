import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/dialogue_template.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';

class BottomsheetPopup extends StatelessWidget {
  const BottomsheetPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
        width: AppSize.s500,
        height: AppSize.s250,
        body: [
          Column(
            children: [

              Row(crossAxisAlignment: CrossAxisAlignment.center,
             mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(children: [
                  Container(
                    height: 25,
                    width: 150,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.transparent,
                    ),
                    child: Center(
                      child: Text(
                        "About to Expire",
                        style: TextStyle(
                          fontSize: FontSize.s12,
                          fontWeight: FontWeight.w700,
                          color:  ColorManager.blueprime,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),

                  Container(width:120,
                    decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),),
                      child: Divider(color: ColorManager.blueprime,height: 4,thickness: 2,)),
                ],),
                const SizedBox(width: 20,),
                Column(children: [
                  Container(
                    height: 25,
                    width: 150,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.transparent,
                    ),
                    child: Center(
                      child: Text(
                        "Expire",
                        style: TextStyle(
                          fontSize: FontSize.s12,
                          fontWeight: FontWeight.w700,
                          color:  ColorManager.blueprime,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                  Container(width:120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),),
                      child: Divider(color: ColorManager.blueprime,height: 4,thickness: 2,)),
                ],),
              ],),
              const SizedBox(height: 5,),
              ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                    child: Container(
                     height: 80,
                      child: ListView.builder(
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                      'Birth Certificate',
                                      style: CustomTextStylesCommon.commonStyle(
                                          color: ColorManager.mediumgrey,
                                          fontSize: FontSize.s12,
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(width: 85,),
                                  Text(
                                    'Driving License',
                                    style: CustomTextStylesCommon.commonStyle(
                                        color: ColorManager.mediumgrey,
                                        fontSize: FontSize.s12,
                                        fontWeight: FontWeight.w500),
                                  )
                                ],
                              ),
                            );
                          }),
                    )),
              )
            ],
          )
        ],
        bottomButtons: const Offstage(),
        title: "Documents");
  }
}
