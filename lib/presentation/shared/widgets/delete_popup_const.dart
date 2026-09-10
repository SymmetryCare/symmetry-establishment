import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';

import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';

class DeletePopup extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final bool? loadingDuration;
  final String title;
  final String? text;
  final String? btnText;
   const DeletePopup({super.key, required this.onCancel,
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
                color: ColorManager.blueprime,
                borderRadius: const BorderRadius.only(
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
            const SizedBox(height: AppSize.s20,),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppPadding.p20,
                horizontal: AppPadding.p20,
              ),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      widget.text ?? 'Do you really want to delete?',
                      style: PopupTextConst.customTextStyle(context),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: AppPadding.p24),
                    child: SizedBox(
                      width: AppSize.s100,
                      child: OutlinedButton(
                        onPressed: widget.onCancel,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          overlayColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          side: BorderSide(
                            color: ColorManager.blueprime,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TransparentButtonTextConst.customTextStyle(context),
                        ),
                      ),
                    )
                ),
                const SizedBox(width: AppSize.s20,),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppPadding.p24,
                    right: AppPadding.p10,
                  ),
                  child: CustomElevatedButton(
                    width: AppSize.s105,
                    height: AppSize.s30,
                    text: widget.btnText ?? AppStringEM.delete,
                    isLoading: widget.loadingDuration == true,
                    onPressed: widget.onDelete,
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
  const NotAllowDeletePopup({super.key, required this.onCancel,
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
                color: ColorManager.blueprime,
                borderRadius: const BorderRadius.only(
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
            const SizedBox(height: AppSize.s20,),
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
            const Spacer(),
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: AppPadding.p24),
                      child:  SizedBox(
                        width: AppSize.s100,
                        child: OutlinedButton(
                          onPressed: widget.onCancel,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            overlayColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            side: BorderSide(
                              color: ColorManager.blueprime,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TransparentButtonTextConst.customTextStyle(context),
                          ),
                        ),
                      )
                  ),
                  const SizedBox(width: AppSize.s20,),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppPadding.p24,right: AppPadding.p10),
                    child: CustomElevatedButton(
                      width: AppSize.s105,
                      height: AppSize.s30,
                      text: "OK",
                      onPressed: () {
                        widget.onDelete();
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
class ConfirmOasisFormPopup extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final VoidCallback onClickBtn2;
  final bool? loadingDuration;
  final String title;
  final String? text;
  final String? btnText;
  final String? btnText2;
  const ConfirmOasisFormPopup({super.key, required this.onCancel,
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
                color: ColorManager.blueprime,
                borderRadius: const BorderRadius.only(
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
            const SizedBox(height: AppSize.s20,),
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
            const Spacer(),
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: AppPadding.p24),
                      child:  SizedBox(
                        width: AppSize.s100,
                        child: OutlinedButton(
                          onPressed: widget.onCancel,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            overlayColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            side: BorderSide(
                              color: ColorManager.blueprime,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Cancel',
                            style: TransparentButtonTextConst.customTextStyle(context),
                          ),),
                      )
                  ),
                  const SizedBox(width: AppSize.s20,),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppPadding.p24,right: AppPadding.p10),
                    child: CustomElevatedButton(
                      width: AppSize.s115,
                      height: AppSize.s30,
                      text: widget.btnText ?? AppStringEM.delete,
                      isLoading: widget.loadingDuration == true,
                      onPressed: () {
                        widget.onDelete();
                      },
                    ),
                  ),
                  const SizedBox(width: AppSize.s20,),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppPadding.p24,right: AppPadding.p10),
                    child: CustomElevatedButton(
                      width: AppSize.s110,
                      height: AppSize.s30,
                      text: widget.btnText2 ?? AppStringEM.delete,
                      isLoading: widget.loadingDuration == true,
                      onPressed: () {
                        widget.onClickBtn2();
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
  const ActionNeededPopup({super.key, required this.onCancel,
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
                color: ColorManager.blueprime,
                borderRadius: const BorderRadius.only(
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
            const SizedBox(height: AppSize.s20,),
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
            const Spacer(),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: AppPadding.p24),
                      child:  SizedBox(
                        width: AppSize.s100,
                        child: OutlinedButton(
                          onPressed: widget.onCancel,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            overlayColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            side: BorderSide(
                              color: ColorManager.blueprime,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Cancel',
                            style: TransparentButtonTextConst.customTextStyle(context),
                          ),),
                      )
                  ),
                  const SizedBox(width: AppSize.s20,),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppPadding.p24,right: AppPadding.p10),
                    child: CustomElevatedButton(
                      width: AppSize.s105,
                      height: AppSize.s30,
                      text: widget.btnText ?? AppStringEM.yes,
                      isLoading: widget.loadingDuration == true,
                      onPressed: () {
                        widget.onDelete();
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
  const FormChangePopup({super.key, required this.onCancel,
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
                color: ColorManager.blueprime,
                borderRadius: const BorderRadius.only(
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
            const SizedBox(height: AppSize.s20,),
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
            const Spacer(),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: AppPadding.p24),
                      child:  SizedBox(
                        width: AppSize.s100,
                        child: OutlinedButton(
                          onPressed: widget.onCancel,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            overlayColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            side: BorderSide(
                              color: ColorManager.blueprime,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Cancel',
                            style: TransparentButtonTextConst.customTextStyle(context),
                          ),),
                      )
                  ),
                  const SizedBox(width: AppSize.s20,),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppPadding.p24,right: AppPadding.p10),
                    child: CustomElevatedButton(
                      width: AppSize.s105,
                      height: AppSize.s30,
                      text: widget.btnText ?? AppStringEM.yes,
                      isLoading: widget.loadingDuration == true,
                      onPressed: () {
                        widget.onDelete();
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


