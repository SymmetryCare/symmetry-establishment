import 'package:flutter/material.dart';

import 'package:symmetry_establishment/presentation/shared/widgets/delete_popup_const.dart';

/// The delete-confirmation dialog under the name the Establishment screens
/// call it.
///
/// Reconstructed from the call sites across the Company Identity document
/// tabs; the original lived in the `prohealth` monolith and did not come across
/// with the extracted screens. It is the same dialog as [DeletePopup] — same
/// parameters, same behaviour — so this delegates rather than reimplementing
/// it, and the two cannot drift apart. (The "Provider" in the name is
/// upstream's; it is a dialog widget, not a `ChangeNotifier`.)
class DeletePopupProvider extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final bool? loadingDuration;
  final String title;
  final String? text;
  final String? btnText;

  const DeletePopupProvider({
    super.key,
    required this.onCancel,
    required this.onDelete,
    required this.title,
    this.loadingDuration,
    this.text,
    this.btnText,
  });

  @override
  Widget build(BuildContext context) => DeletePopup(
        onCancel: onCancel,
        onDelete: onDelete,
        title: title,
        loadingDuration: loadingDuration,
        text: text,
        btnText: btnText,
      );
}
