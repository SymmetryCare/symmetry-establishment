import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/string_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/icon_button_constant.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';

class DefineFormList extends StatelessWidget {
  final String formName;

  /// Fetches the document and opens it for signing. Awaitable rather than a
  /// plain VoidCallback so the Sign button can stay disabled, showing a
  /// spinner, for as long as that is in flight — it is a network round trip
  /// followed by a push, and every extra tap used to start another one.
  final Future<void> Function()? onSigned;
  final VoidCallback onView;
  final bool isSigned;
  final bool isHandbook;
  final bool isReturnCompany;
  final VoidCallback? handBookView;

  const DefineFormList({
    Key? key,
    required this.formName,
    this.onSigned,
    required this.onView,
    required this.isSigned,
    required this.isHandbook,
    this.handBookView, required this.isReturnCompany,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          formName,
          style: DefineWorkWeekStyle.customTextStyle(context),
        ),
    isReturnCompany
        ? Padding(
      padding: const EdgeInsets.only(right: 40.0),
      child: Text('NA',style: TextStyle(
          fontSize: FontSize.s12,
          fontWeight: FontWeight.w700,
          color: ColorManager.mediumgrey)),
    )
        :  isHandbook ? Padding(
          padding: const EdgeInsets.only(right: 1.0),
          child: InkWell(
            onTap: handBookView,
            child: Container(
                height: 30,
                width: 90,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xff1696C8)),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.only(bottom: 5,left: 15,right: 10),
                child:
                const Padding(
                  padding: EdgeInsets.only(top: 6.0),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('View',style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: FontSize.s14,
                          color: Color(0xff1696C8),
                        ),),
                        SizedBox(width: 10,),
                        Center(
                          child: Icon(
                            Icons.remove_red_eye_outlined,
                            color: Color(0xff1696C8),
                            size:IconSize.I20,
                          ),
                        ),]),
                )),
          ),
        )
        : Row(
          children: [
            // Conditional rendering: If signed, show a check mark
            isSigned ?
            InkWell(
              onTap: onView,
              child: Container(
                height: 30,
                width: 90,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xff1696C8)),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.only(bottom: 5,left: 10,right: 10),
                child:
              const Padding(
                padding: EdgeInsets.only(top: 6.0),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left:3),
                      child: Text('View',style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: FontSize.s14,
                        color: Color(0xff1696C8),
                      ),),
                    ),
                    SizedBox(width: 10,),
                    Center(
                      child: Icon(
                        Icons.remove_red_eye_outlined,
                        color: Color(0xff1696C8),
                        size: IconSize.I20,
                      ),
                    ),]),
              )),
            )
                : const SizedBox(width: 50,),
            const SizedBox(width: 10),
            isSigned
                ? Container(
              width: 90,
                  child: const Center(
                    child: Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 24,
                                ),
                  ),
                )
                : Container(
              width: 90,
                  child: _SignButton(onSigned: onSigned),
                              ),
          ],
        ),
      ],
    );
  }
}

/// The Sign button for one row. It owns its own in-flight flag so that the
/// row being signed is the only one that changes — the list renders one of
/// these per legal document.
///
/// While [onSigned] is running the button is disabled and shows a spinner
/// in place of its label, which is what stops a second tap starting a second
/// fetch and stacking a second signature screen on top of the first. Its
/// geometry is unchanged either way, so the row doesn't jump.
class _SignButton extends StatefulWidget {
  const _SignButton({required this.onSigned});

  final Future<void> Function()? onSigned;

  @override
  State<_SignButton> createState() => _SignButtonState();
}

class _SignButtonState extends State<_SignButton> {
  bool _isSigning = false;

  Future<void> _handleTap() async {
    final Future<void> Function()? onSigned = widget.onSigned;
    if (_isSigning || onSigned == null) return;

    setState(() => _isSigning = true);
    try {
      await onSigned();
    } finally {
      // The callback pushes the signature screen rather than awaiting it, so
      // this lands once the document is on screen. The row may also have been
      // rebuilt out from under us by the refreshed form status.
      if (mounted) setState(() => _isSigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onSigned != null && !_isSigning;
    return ElevatedButton(
      onPressed: enabled ? _handleTap : null,
      child: _isSigning
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              'Sign',
              style: BlueButtonTextConst.customTextStyle(context),
            ),
    );
  }
}
