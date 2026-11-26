import 'package:flutter/material.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';

/// Red delete icon used in the Zones tables (County, Zone, Zip Code).
class ZoneDeleteIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;
  const ZoneDeleteIconButton(
      {super.key, required this.onPressed, this.tooltip = 'Delete'});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onPressed: onPressed,
      icon: Icon(Icons.delete_outline,
          size: IconSize.I22, color: IconColorManager.red),
    );
  }
}

/// Asks for confirmation, runs [delete], then shows the success or failure
/// popup. Returns true when the record was deleted.
///
/// The list reloads by itself: a successful DELETE through `Api` fires
/// DataRefresh, which every AutoRefreshMixin screen listens to.
Future<bool> confirmZoneDelete({
  required BuildContext context,
  required String title,
  required String text,
  required Future<ApiData> Function() delete,
}) async {
  bool deleting = false;
  bool deleted = false;
  ApiData? failure;

  await showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => DeletePopup(
        title: title,
        text: text,
        loadingDuration: deleting,
        onCancel: () => Navigator.pop(dialogContext),
        onDelete: () async {
          if (deleting) return;
          setDialogState(() => deleting = true);
          final response = await delete();
          if (response.success) {
            deleted = true;
          } else {
            failure = response;
          }
          if (dialogContext.mounted) Navigator.pop(dialogContext);
        },
      ),
    ),
  );

  if (!context.mounted) return deleted;
  if (deleted) {
    showDialog(context: context, builder: (_) => const DeleteSuccessPopup());
  } else if (failure != null) {
    showDialog(
        context: context,
        builder: (_) => FailedPopup(text: failure!.message));
  }
  return deleted;
}
