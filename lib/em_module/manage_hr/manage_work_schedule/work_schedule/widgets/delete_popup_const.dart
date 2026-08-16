import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/app/resources/establishment_resources/establishment_string_manager.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/button_constant.dart';

import '../../../../../../../app/resources/common_resources/common_theme_const.dart';

class DeletePopup extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final bool? loadingDuration;
  final String title;
  final String? text;
  final String? btnText;
   DeletePopup({super.key, required this.onCancel,
     this.text,
     this.btnText,
    required this.onDelete, this.loadingDuration, required this.title});

  @override
  State<DeletePopup> createState() => _DeletePopupState();


}
//
class _DeletePopupState extends State<DeletePopup> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: AppSize.s400,
        height: AppSize.s181,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: ColorManager.bluebottom,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p15),
                    child: Text(
                      widget.title,
                      style: PopupBlueBarText.customTextStyle(context),
                    ),
                  ),
                  IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close,color: ColorManager.white,size: IconSize.I20,),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSize.s20,),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppPadding.p20,
                horizontal: AppPadding.p20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // ← center in row
                children: [
                  Flexible(
                    child: Text(
                      widget.text ?? 'Do you really want to delete?',
                      style: PopupTextConst.customTextStyle(context),
                      textAlign: TextAlign.center,     // ← center text lines
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: AppPadding.p24),
                  child:  SizedBox(
                    width: AppSize.s100,
                    child: ElevatedButton(
                      onPressed: widget.onCancel,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: ColorManager.bluebottom,
                            width: 1,
                          ),
                        ),),
                      child: Text('Cancel',
                         style: TransparentButtonTextConst.customTextStyle(context),
                      ),),
                  )
                ),
                SizedBox(width: AppSize.s20,),
                Padding(
                padding: const EdgeInsets.only(bottom: AppPadding.p24,right: AppPadding.p10),
                child: widget.loadingDuration == true
                    ? SizedBox(
                  height: AppSize.s25,
                  width: AppSize.s25,
                  child: CircularProgressIndicator(
                    color: ColorManager.blueprime,
                  ),
                )
                    : CustomElevatedButton(
                  width: AppSize.s105,
                  height: AppSize.s30,
                  text: widget.btnText ?? AppStringEM.delete,
                  onPressed: () {
                    widget.onDelete();
                    //Navigator.pop(context);
                  },
                ),
                ),]
            ),
            //
          ],
        ),
      ),
    );
  }
}

/// Do not allow delete
class NotAllowDeletePopup extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final bool? loadingDuration;
  final String title;
  NotAllowDeletePopup({super.key, required this.onCancel,
    required this.onDelete, this.loadingDuration, required this.title});

  @override
  State<NotAllowDeletePopup> createState() => _NotAllowDeletePopup();


}
//
class _NotAllowDeletePopup extends State<NotAllowDeletePopup> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: AppSize.s400,
        height: AppSize.s181,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: ColorManager.bluebottom,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              height: AppSize.s35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p15),
                    child: Text(
                      widget.title,
                      style: PopupBlueBarText.customTextStyle(context),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close,color: ColorManager.white,size: IconSize.I20,),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSize.s20,),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppPadding.p20,
                horizontal: AppPadding.p20,
              ),
              child: Row(
                children: [
                  Text('Not allow to delete county.',
                    style: PopupTextConst.customTextStyle(context)
                  ),
                ],
              ),
            ),
            Spacer(),
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: AppPadding.p24),
                      child:  SizedBox(
                        width: AppSize.s100,
                        child: ElevatedButton(
                          onPressed: widget.onCancel,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: ColorManager.bluebottom,
                                width: 1,
                              ),
                            ),),
                          child: Text('Cancel',
                              style:TransparentButtonTextConst.customTextStyle(context)
                          ),),
                      )
                  ),
                  SizedBox(width: AppSize.s20,),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppPadding.p24,right: AppPadding.p10),
                    child: CustomElevatedButton(
                      width: AppSize.s105,
                      height: AppSize.s30,
                      text: "OK",
                      onPressed: () {
                        widget.onDelete();
                        //Navigator.pop(context);
                      },
                    ),
                  ),]
            ),
            //
          ],
        ),
      ),
    );
  }
}
///
class ReusableLoadingButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color textColor;
  final double borderRadius;
  final double paddingVertical;
  final double paddingHorizontal;
  final double width;
  final double height;
  final int loadingDuration;

  const ReusableLoadingButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.textColor = Colors.white,
    this.borderRadius = 12.0,
    this.paddingVertical = 12.0,
    this.paddingHorizontal = 16.0,
    this.width = 100,
    this.height = 35.0,
    this.loadingDuration = 3,
  }) : super(key: key);

  @override
  _ReusableLoadingButtonState createState() => _ReusableLoadingButtonState();
}

class _ReusableLoadingButtonState extends State<ReusableLoadingButton> {
  bool _isLoading = false;

  void _handlePress() {
    setState(() {
      _isLoading = true;
    });

    widget.onPressed.call();
    Future.delayed(Duration(seconds: widget.loadingDuration), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? SizedBox(
      width: AppSize.s30,
      height: AppSize.s30,
      child: CircularProgressIndicator(
        color: Colors.blue,

      ),
    )
        : SizedBox(
      width: widget.width,
      height: widget.height,
      child: ElevatedButton(
        onPressed: _handlePress,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1696C8),
          foregroundColor: widget.textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          padding: EdgeInsets.symmetric(
            vertical: widget.paddingVertical,
            horizontal: widget.paddingHorizontal,
          ),
        ),
        child: Text(
          widget.text,
          style: BlueButtonTextConst.customTextStyle(context),
        ),
      ),
    );
  }
}


class ConfirmOasisFormPopup extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final VoidCallback onClickBtn2;
  final bool? loadingDuration;
  final String title;
  final String? text;
  final String? btnText;
  final String? btnText2;
  ConfirmOasisFormPopup({super.key, required this.onCancel,
    this.text,
    this.btnText,
    required this.onDelete, this.loadingDuration, required this.title, this.btnText2, required this.onClickBtn2});

  @override
  State<ConfirmOasisFormPopup> createState() => _ConfirmOasisFormPopupState();


}
//
class _ConfirmOasisFormPopupState extends State<ConfirmOasisFormPopup> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: AppSize.s400,
        height: AppSize.s200,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: ColorManager.bluebottom,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p15),
                    child: Text(
                      widget.title,
                      style: PopupBlueBarText.customTextStyle(context),
                    ),
                  ),
                  IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close,color: ColorManager.white,size: IconSize.I20,),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSize.s20,),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppPadding.p20,
                horizontal: AppPadding.p20,
              ),
              child: Row(
                children: [
                  Text( widget.text ?? 'Do you really want to delete?',
                      style: PopupTextConst.customTextStyle(context)
                  ),
                ],
              ),
            ),
            Spacer(),
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: AppPadding.p24),
                      child:  SizedBox(
                        width: AppSize.s100,
                        child: ElevatedButton(
                          onPressed: widget.onCancel,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: ColorManager.bluebottom,
                                width: 1,
                              ),
                            ),),
                          child: Text('Cancel',
                            style: TransparentButtonTextConst.customTextStyle(context),
                          ),),
                      )
                  ),
                  SizedBox(width: AppSize.s20,),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppPadding.p24,right: AppPadding.p10),
                    child: widget.loadingDuration == true
                        ? SizedBox(
                      height: AppSize.s25,
                      width: AppSize.s25,
                      child: CircularProgressIndicator(
                        color: ColorManager.blueprime,
                      ),
                    )
                        : CustomElevatedButton(
                      width: AppSize.s115,
                      height: AppSize.s30,
                      text: widget.btnText ?? AppStringEM.delete,
                      onPressed: () {
                        widget.onDelete();
                        //Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(width: AppSize.s20,),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppPadding.p24,right: AppPadding.p10),
                    child: widget.loadingDuration == true
                        ? SizedBox(
                      height: AppSize.s25,
                      width: AppSize.s25,
                      child: CircularProgressIndicator(
                        color: ColorManager.blueprime,
                      ),
                    )
                        : CustomElevatedButton(
                      width: AppSize.s110,
                      height: AppSize.s30,
                      text: widget.btnText2 ?? AppStringEM.delete,
                      onPressed: () {
                        widget.onClickBtn2();
                        //Navigator.pop(context);
                      },
                    ),
                  )]
            ),
            //
          ],
        ),
      ),
    );
  }
}

class ActionNeededPopup extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final bool? loadingDuration;
  final String title;
  final String? text;
  final String? btnText;
  ActionNeededPopup({super.key, required this.onCancel,
    this.text,
    this.btnText,
    required this.onDelete, this.loadingDuration, required this.title});

  @override
  State<ActionNeededPopup> createState() => _ActionNeededPopupState();


}
//
class _ActionNeededPopupState extends State<ActionNeededPopup> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: AppSize.s400,
        height: AppSize.s240,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: ColorManager.bluebottom,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p15),
                    child: Text(
                      widget.title,
                      style: PopupBlueBarText.customTextStyle(context),
                    ),
                  ),
                  IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close,color: ColorManager.white,size: IconSize.I20,),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSize.s20,),
            Image.asset('assets/png/action_needed.png',width: AppSize.s50,height: AppSize.s50,),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppPadding.p20,
                horizontal: AppPadding.p20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // ← center in row
                children: [
                  Flexible(
                    child: Text(
                      widget.text ?? 'Do you really want to delete?',
                      style: PopupTextConst.customTextStyle(context),
                      textAlign: TextAlign.center,     // ← center text lines
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: AppPadding.p24),
                      child:  SizedBox(
                        width: AppSize.s100,
                        child: ElevatedButton(
                          onPressed: widget.onCancel,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: ColorManager.bluebottom,
                                width: 1,
                              ),
                            ),),
                          child: Text('Cancel',
                            style: TransparentButtonTextConst.customTextStyle(context),
                          ),),
                      )
                  ),
                  SizedBox(width: AppSize.s20,),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppPadding.p24,right: AppPadding.p10),
                    child: widget.loadingDuration == true
                        ? SizedBox(
                      height: AppSize.s25,
                      width: AppSize.s25,
                      child: CircularProgressIndicator(
                        color: ColorManager.blueprime,
                      ),
                    )
                        : CustomElevatedButton(
                      width: AppSize.s105,
                      height: AppSize.s30,
                      text: widget.btnText ?? AppStringEM.yes,
                      onPressed: () {
                        widget.onDelete();
                        //Navigator.pop(context);
                      },
                    ),
                  ),]
            ),
            //
          ],
        ),
      ),
    );
  }
}


class FormChangePopup extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final bool? loadingDuration;
  final String title;
  final String? text;
  final String? btnText;
  FormChangePopup({super.key, required this.onCancel,
    this.text,
    this.btnText,
    required this.onDelete, this.loadingDuration, required this.title});

  @override
  State<FormChangePopup> createState() => _FormChangePopupState();


}
//
class _FormChangePopupState extends State<FormChangePopup> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: AppSize.s370,
        height: AppSize.s200,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: ColorManager.bluebottom,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              height: 37,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p15),
                    child: Text(
                      widget.title,
                      style: PopupBlueBarText.customTextStyle(context),
                    ),
                  ),
                  IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close,color: ColorManager.white,size: IconSize.I20,),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSize.s20,),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppPadding.p20,
                horizontal: AppPadding.p20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // ← center in row
                children: [
                  Flexible(
                    child: Text(
                      widget.text ?? 'Do you really want to delete?',
                      style: PopupTextConst.customTextStyle(context),
                      textAlign: TextAlign.center,     // ← center text lines
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: AppPadding.p24),
                      child:  SizedBox(
                        width: AppSize.s100,
                        child: ElevatedButton(
                          onPressed: widget.onCancel,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: ColorManager.bluebottom,
                                width: 1,
                              ),
                            ),),
                          child: Text('Cancel',
                            style: TransparentButtonTextConst.customTextStyle(context),
                          ),),
                      )
                  ),
                  SizedBox(width: AppSize.s20,),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppPadding.p24,right: AppPadding.p10),
                    child: widget.loadingDuration == true
                        ? SizedBox(
                      height: AppSize.s25,
                      width: AppSize.s25,
                      child: CircularProgressIndicator(
                        color: ColorManager.blueprime,
                      ),
                    )
                        : CustomElevatedButton(
                      width: AppSize.s105,
                      height: AppSize.s30,
                      text: widget.btnText ?? AppStringEM.yes,
                      onPressed: () {
                        widget.onDelete();
                        //Navigator.pop(context);
                      },
                    ),
                  ),]
            ),
            //
          ],
        ),
      ),
    );
  }
}


