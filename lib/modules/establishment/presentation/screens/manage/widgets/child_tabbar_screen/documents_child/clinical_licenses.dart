import 'dart:async';

import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/download_doc_const.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/clinical_licenses_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/onboarding_data/clinical_license_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/widgets/compensation_add_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/widgets/document_row_card.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/manage_card_grid.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/delete_popup_const.dart';

/// Green PNG badge and its wash, from the Clinical license design.
const Color _licenseGreen = Color(0xFF1AB595);
const String _licenseIcon = 'images/doc_png.svg';

/// Everything one licence card needs, so Driving and Practitioner — which
/// come off different endpoints and different models — can share one card
/// builder instead of the two near-identical 250-line blocks this file used
/// to carry.
class _LicenseCard {
  final String title;
  final String expiryDate;
  final String url;
  final String fileName;
  final String docId;
  final String apiPath;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LicenseCard({
    required this.title,
    required this.expiryDate,
    required this.url,
    required this.fileName,
    required this.docId,
    required this.apiPath,
    required this.onEdit,
    required this.onDelete,
  });

  /// "--" is the API's stand-in for "no file uploaded".
  bool get hasFile => url != '--';
}

class ClinicalLicensesDoc extends StatefulWidget {
  final int employeeId;
  final String employeeStatus;
  const ClinicalLicensesDoc({
    super.key,
    required this.employeeId,
    required this.employeeStatus,
  });

  @override
  State<ClinicalLicensesDoc> createState() => _ClinicalLicensesDocState();
}

class _ClinicalLicensesDocState extends State<ClinicalLicensesDoc> {
  final StreamController<List<ClinicalLicenseDataModel>>
      drivingLicenseController =
      StreamController<List<ClinicalLicenseDataModel>>();
  final StreamController<List<PractitionerLicenseDataModel>>
      practitionerLicenseController =
      StreamController<List<PractitionerLicenseDataModel>>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDrivingLicenseData();
    _loadPractitionerLicenseData();
  }

  void _loadDrivingLicenseData() {
    getDrivingLicenseRecord(context, widget.employeeId, "yes").then((data) {
      if (mounted) drivingLicenseController.add(data);
    }).catchError((error) {
      // Handle error
    });
  }

  void _loadPractitionerLicenseData() {
    getPractitionerLicenseRecord(context, widget.employeeId, "yes")
        .then((data) {
      if (mounted) practitionerLicenseController.add(data);
    }).catchError((error) {
      // Handle error
    });
  }

  @override
  void dispose() {
    drivingLicenseController.close();
    practitionerLicenseController.close();
    super.dispose();
  }

  bool get _isReadOnly =>
      widget.employeeStatus == 'Terminated' ||
      widget.employeeStatus == 'Inactive';

  @override
  Widget build(BuildContext context) {
    // The two licences sit side by side in the same responsive grid the
    // Banking and Qualifications cards use.
    return ManageCardGrid(
      children: [
        _drivingLicenseSlot(),
        _practitionerLicenseSlot(),
      ],
    );
  }

  // ── Slots ─────────────────────────────────────────────────────────────
  // Each slot owns its own stream, so one licence loading or coming back
  // empty never blanks the other.

  Widget _drivingLicenseSlot() {
    return StreamBuilder<List<ClinicalLicenseDataModel>>(
      stream: drivingLicenseController.stream,
      builder: (context, snapshot) => _slot(
        snapshot,
        emptyMessage: AppString.noDrivingLicense,
        build: (data) {
          final license = data.first;
          final String docId = license.drivingLicenseId.toString();
          return _LicenseCard(
            title: 'Driving License',
            expiryDate: license.expDate,
            url: license.url,
            fileName: license.fileName,
            docId: docId,
            apiPath:
                DownloadDocumentRepository.getDrivingLicenseDocumentByFileName(),
            onEdit: () => _openEditPopup<ClinicalLicensePrefillDataModel>(
              // Computed once per press rather than inside the dialog's
              // builder, which would re-fire the API on every rebuild.
              prefill: getDrivingLicenseRecordPreFill(
                context: context,
                docId: docId,
              ),
              popup: (data) => ClinicalLicensesAddPopup(
                title: 'Edit Driving Licenses',
                employeeId: widget.employeeId,
                drivingList: data,
                docId: docId,
                licenseName: 'Driving License',
              ),
              onClosed: _loadDrivingLicenseData,
            ),
            onDelete: () => _confirmDelete(
              title: 'Delete Driving License',
              delete: () => deleteDrivingLicense(context, docId),
              onDeleted: _loadDrivingLicenseData,
            ),
          );
        },
      ),
    );
  }

  Widget _practitionerLicenseSlot() {
    return StreamBuilder<List<PractitionerLicenseDataModel>>(
      stream: practitionerLicenseController.stream,
      builder: (context, snapshot) => _slot(
        snapshot,
        emptyMessage: AppString.noPractitionerLicense,
        build: (data) {
          final license = data.first;
          final String docId = license.practitionerLicenceId.toString();
          return _LicenseCard(
            title: 'Practitioner License',
            expiryDate: license.expDate,
            url: license.url,
            fileName: license.fileName,
            docId: docId,
            apiPath: DownloadDocumentRepository
                .getPractitionerLicenseDocumentByFileName(),
            onEdit: () => _openEditPopup<PractitionerLicensePreFillDataModel>(
              prefill: getPractitionerLicenseRecordPreFill(
                context: context,
                docId: docId,
              ),
              popup: (data) => ClinicalLicensesAddPopup(
                title: 'Edit Practitioner Licenses',
                employeeId: widget.employeeId,
                practionerData: data,
                docId: docId,
                licenseName: 'Practitioner License',
              ),
              onClosed: _loadPractitionerLicenseData,
            ),
            onDelete: () => _confirmDelete(
              title: 'Delete Practitioner License',
              delete: () => deletePractitionerLicense(context, docId),
              onDeleted: _loadPractitionerLicenseData,
            ),
          );
        },
      ),
    );
  }

  /// Loading / empty / loaded, sized to a card so the grid does not jump
  /// between states.
  Widget _slot<T>(
    AsyncSnapshot<List<T>> snapshot, {
    required String emptyMessage,
    required _LicenseCard Function(List<T> data) build,
  }) {
    Widget boxed(Widget child) => SizedBox(
          height: 72,
          child: Center(child: child),
        );

    if (snapshot.connectionState == ConnectionState.waiting) {
      return boxed(
        SizedBox(
          height: 25,
          width: 25,
          child: CircularProgressIndicator(color: ColorManager.blueprime),
        ),
      );
    }
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return boxed(
        Text(emptyMessage, style: AllNoDataAvailable.customTextStyle(context)),
      );
    }
    return _card(build(snapshot.data!));
  }

  // ── The card ──────────────────────────────────────────────────────────

  Widget _card(_LicenseCard license) {
    void download() => downloadFile(
          context: context,
          fileUrl: license.url,
          documentName: license.fileName,
          apiPath: license.apiPath,
        );

    return DocumentRowCard(
      dense: true,
      iconAsset: _licenseIcon,
      accentColor: _licenseGreen,
      idLabel: license.title,
      fileName: 'Expiry Date: ${license.expiryDate}',
      onTap: license.hasFile ? download : null,
      onEdit: _isReadOnly ? null : license.onEdit,
      onPrint: license.hasFile ? download : null,
      onDownload: license.hasFile ? download : null,
      onDelete: _isReadOnly ? null : license.onDelete,
    );
  }

  // ── Shared popups ─────────────────────────────────────────────────────

  /// Generic over the prefill model: Driving and Practitioner prefill from
  /// different types and feed different popup parameters, so the caller
  /// supplies the popup once the data is in.
  void _openEditPopup<T>({
    required Future<T> prefill,
    required Widget Function(T data) popup,
    required VoidCallback onClosed,
  }) {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<T>(
        future: prefill,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: ColorManager.blueprime),
            );
          }
          return popup(snapshot.data as T);
        },
      ),
    ).then((_) => onClosed());
  }

  void _confirmDelete({
    required String title,
    required Future<dynamic> Function() delete,
    required VoidCallback onDeleted,
  }) {
    bool dialogIsOpen = true;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => DeletePopup(
          loadingDuration: _isLoading,
          title: title,
          onCancel: () {
            dialogIsOpen = false;
            Navigator.pop(context);
          },
          onDelete: () async {
            setState(() => _isLoading = true);
            if (dialogIsOpen) setDialogState(() {});
            try {
              final result = await delete();
              dialogIsOpen = false;
              Navigator.pop(context);
              if (result.success) onDeleted();
            } finally {
              if (mounted) setState(() => _isLoading = false);
              if (dialogIsOpen) setDialogState(() {});
            }
          },
        ),
      ),
    );
  }
}
