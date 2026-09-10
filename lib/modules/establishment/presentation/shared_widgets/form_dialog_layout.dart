import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_fields.dart';

/// The Register layout: section headings sit outside the bordered field grid.
class FormDialogSection extends StatelessWidget {
  final String title;
  final Widget child;
  const FormDialogSection(
      {super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          FormDialogSectionTitle(title),
          FormDialogCard(child: child),
        ],
      );
}

class FormDialogSectionTitle extends StatelessWidget {
  final String title;
  const FormDialogSectionTitle(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 6),
        child: Text(title,
            style: FormDialogFields.labelStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            )),
      );
}

class FormDialogCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final BoxConstraints? constraints;
  const FormDialogCard({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.constraints,
    this.padding = const EdgeInsets.fromLTRB(10, 9, 10, 9),
  });
  @override
  Widget build(BuildContext context) => Container(
        width: width,
        constraints: constraints,
        padding: padding,
        decoration: BoxDecoration(
          color: const Color(0xFFFDFDFD),
          border: Border.all(color: const Color(0x29000000)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: child,
      );
}

/// Equal-width cells, aligned at the top so validation stays with its field.
class FormDialogGrid extends StatelessWidget {
  final List<Widget> children;
  final int columns;
  const FormDialogGrid({super.key, required this.children, this.columns = 3})
      : assert(columns > 0);

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final cells = children
            .where((child) =>
                !(child is Visibility &&
                    (!child.visible ||
                        (child.child is SizedBox &&
                            (child.child as SizedBox).child == null))) &&
                !(child is SizedBox && child.child == null))
            .toList();
        final count = constraints.maxWidth < 440
            ? 1
            : constraints.maxWidth < 660
                ? columns.clamp(1, 2)
                : columns;
        return Column(mainAxisSize: MainAxisSize.min, children: [
          for (var start = 0; start < cells.length; start += count) ...[
            if (start > 0) const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (var cell = 0; cell < count; cell++) ...[
                if (cell > 0) const SizedBox(width: 12),
                Expanded(
                    child: start + cell < cells.length
                        ? cells[start + cell]
                        : const SizedBox.shrink()),
              ],
            ]),
          ],
        ]);
      });
}

/// Scroll only the form, keeping the header and action buttons visible.
class FormDialogBody extends StatelessWidget {
  final List<Widget> children;
  const FormDialogBody({super.key, required this.children});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              children[i],
            ],
          ],
        ),
      );
}

/// Shared label, rectangular input inset and validation slot used by Register
/// and Manage. A child which already includes its label can omit [label].
class FormDialogField extends StatelessWidget {
  final String? label;
  final bool isRequired;
  final Widget child;
  final String? error;
  final Widget? validation;
  const FormDialogField(
      {super.key,
      this.label,
      this.isRequired = true,
      required this.child,
      this.error,
      this.validation});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(left: 5, bottom: 2),
              child: Text.rich(TextSpan(
                text: label,
                style: FormDialogFields.labelStyle,
                children: [
                  if (isRequired)
                    TextSpan(
                        text: ' *',
                        style: FormDialogFields.labelStyle
                            .copyWith(color: Colors.red))
                ],
              )),
            ),
          if (label != null)
            Padding(padding: const EdgeInsets.all(5), child: child)
          else
            child,
          validation ??
              (error == null
                  ? const SizedBox(height: 8)
                  : Padding(
                      padding: const EdgeInsets.only(left: 5, top: 2),
                      child: Text(error!,
                          style: FormDialogFields.labelStyle
                              .copyWith(color: Colors.red, fontSize: 9)),
                    )),
        ],
      );
}
