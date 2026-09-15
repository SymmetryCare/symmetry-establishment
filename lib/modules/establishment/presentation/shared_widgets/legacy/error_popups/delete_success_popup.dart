import 'dart:async';

import 'package:flutter/material.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';

class DeleteSuccessPopup extends StatefulWidget {
  const DeleteSuccessPopup({super.key});

  @override
  State<DeleteSuccessPopup> createState() => _DeleteSuccessPopupState();
}

class _DeleteSuccessPopupState extends State<DeleteSuccessPopup> {


  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: AppSize.s300,
        height: AppSize.s150,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: ColorManager.blueprime,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              height: AppSize.s40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p10),
                    child: Text(
                      "Success",
                      style:  PopupBlueBarText.customTextStyle(context),
                    ),
                  ),
                  IconButton(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () {},
                    icon: Icon(Icons.close, color: ColorManager.white),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: Container(
                height: AppSize.s50,
                width: AppSize.s210,
                child: Center(
                  child: Text('Deleted Successfully\nThank You.',
                    textAlign: TextAlign.center,
                    style:ConstTextFieldRegister.customTextStyle(context),),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
