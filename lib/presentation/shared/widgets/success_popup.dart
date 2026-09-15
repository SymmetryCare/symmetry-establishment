///success popup
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'dart:async';

class CCSuccessPopup extends StatefulWidget {
  const CCSuccessPopup({super.key});

  @override
  State<CCSuccessPopup> createState() => _CCSuccessPopupState();
}

class _CCSuccessPopupState extends State<CCSuccessPopup> {
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();

    _autoDismissTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
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
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p15),
                    child: Text(
                      "Success",
                      style:PopupBlueBarText.customTextStyle(context),

                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: Container(
                height: AppSize.s50,
                width: AppSize.s210,
                child: Text('Save Successfully \nThank You.',textAlign: TextAlign.center,
                  style:CustomTextStylesCommon.commonStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: FontSize.s14,
                      color: ColorManager.mediumgrey
                  ),),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class EditSuccessPopup extends StatefulWidget {
  final String message;

  const EditSuccessPopup({super.key, required this.message});

  @override
  State<EditSuccessPopup> createState() => _EditSuccessPopupState();
}

class _EditSuccessPopupState extends State<EditSuccessPopup> {
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();

    _autoDismissTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
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
              height: AppSize.s35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p10),
                    child: Text(
                      "Success",
                      style: PopupBlueBarText.customTextStyle(context),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: Container(
                height: AppSize.s50,
                width: AppSize.s210,
                child: Text('Submitted Successfully \nThank You.',textAlign: TextAlign.center,
                  style:ConstTextFieldRegister.customTextStyle(context),),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class VendorSelectNoti extends StatefulWidget {
  final String message;
  const VendorSelectNoti({super.key, required this.message});

  @override
  State<VendorSelectNoti> createState() => _VendorSelectNotiState();
}

class _VendorSelectNotiState extends State<VendorSelectNoti> {
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();

    _autoDismissTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
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
              height: AppSize.s35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p10),
                    child: Text(
                      "Required",
                      style:  PopupBlueBarText.customTextStyle(context),
                    ),
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
                  child: Text(widget.message == ""?'Added Successfully \nThank You.':widget.message,textAlign: TextAlign.center,
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

//////

class AddSuccessPopup extends StatefulWidget {
  final String message;
  final String? title;
  const AddSuccessPopup({super.key, this.title,required this.message});

  @override
  State<AddSuccessPopup> createState() => _AddSuccessPopupState();
}

class _AddSuccessPopupState extends State<AddSuccessPopup> {
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();

    _autoDismissTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
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
              height: AppSize.s35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: widget.title != null ? Text(
                      widget.title!,
                      style:  PopupBlueBarText.customTextStyle(context),
                    ) : Text(
                      "Success",
                      style:  PopupBlueBarText.customTextStyle(context),
                    ),
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
                  child: Text(widget.message == ""?'Added Successfully \nThank You.':widget.message,textAlign: TextAlign.center,
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


class CountySuccessPopup extends StatefulWidget {
  final String message;

  const CountySuccessPopup({super.key, required this.message});

  @override
  State<CountySuccessPopup> createState() => _CountySuccessPopupState();
}

class _CountySuccessPopupState extends State<CountySuccessPopup> {
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();

    _autoDismissTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
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
              height: AppSize.s35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      "Success",
                      style:  PopupBlueBarText.customTextStyle(context),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: Container(
                height: AppSize.s50,
                width: AppSize.s210,
                child: Text('Save Successfully \nThank You.',textAlign: TextAlign.center,
                  style:CustomTextStylesCommon.commonStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: FontSize.s14,
                      color: ColorManager.mediumgrey
                  ),),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}


class AddErrorPopup extends StatefulWidget {
  final String message;
  const AddErrorPopup({super.key, required this.message});

  @override
  State<AddErrorPopup> createState() => _AddErrorPopupState();
}

class _AddErrorPopupState extends State<AddErrorPopup> {
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();

    _autoDismissTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      "Error",
                      style:  PopupBlueBarText.customTextStyle(context),
                    ),
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
                  child: Text(widget.message == ""?'Something went wrong!':widget.message,textAlign: TextAlign.center,
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

///Add Fail Popup
class AddFailePopup extends StatefulWidget {
  final String message;

  const AddFailePopup({super.key, required this.message});

  @override
  State<AddFailePopup> createState() => _AddFailePopupState();
}

class _AddFailePopupState extends State<AddFailePopup> {
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();

    _autoDismissTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      "Failed",
                      style:  PopupBlueBarText.customTextStyle(context),
                    ),
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
                  child: Text(widget.message == ""?'Added Successfully \nThank You.':widget.message,textAlign: TextAlign.center,
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




class offerSuccessPopup extends StatefulWidget {
  final String message;

  const offerSuccessPopup({super.key, required this.message});

  @override
  State<offerSuccessPopup> createState() => _offerSuccessPopupState();
}

class _offerSuccessPopupState extends State<offerSuccessPopup> {

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
              height: AppSize.s35,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "Success",
                        style:  PopupBlueBarText.customTextStyle(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: Container(
                height: AppSize.s50,
                width: AppSize.s210,
                child: Center(
                  child: Text(widget.message == ""?'Added Successfully \nThank You.':widget.message,textAlign: TextAlign.center,
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
