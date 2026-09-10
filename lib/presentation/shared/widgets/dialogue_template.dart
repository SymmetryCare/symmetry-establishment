import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_layout.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_shell.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';

class DialogueTemplate extends StatelessWidget {
  final double width;
  final double height;
  final String title;
  final Color? color;
  final List<Widget> body;
  final Widget bottomButtons;
  VoidCallback? onClear;
  bool? isScrollable;
  DialogueTemplate(
      {super.key,
      this.onClear,
      this.color,
      this.isScrollable = false,
      required this.width,
      required this.height,
      required this.body,
      required this.bottomButtons,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FormDialogSurface(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FormDialogHeader(
              title: title,
              backgroundColor: color,
              onClose: onClear ?? () => Navigator.pop(context),
            ),
            Flexible(child: FormDialogBody(children: body)),

            ///button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppPadding.p20),
              child: Center(
                child: bottomButtons,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Termination template
class TerminationDialogueTemplate extends StatelessWidget {
  final double width;
  final double height;
  final String title;
  final List<Widget> body;
  final Widget bottomButtons;
  const TerminationDialogueTemplate(
      {super.key,
      required this.width,
      required this.height,
      required this.body,
      required this.bottomButtons,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FormDialogSurface(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed blue container (not scrollable)
            FormDialogHeader(
                title: title, onClose: () => Navigator.pop(context)),

            // Scrollable content
            Flexible(child: FormDialogBody(children: body)),

            const SizedBox(height: AppSize.s15),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppPadding.p20),
              child: Center(
                child: bottomButtons,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
