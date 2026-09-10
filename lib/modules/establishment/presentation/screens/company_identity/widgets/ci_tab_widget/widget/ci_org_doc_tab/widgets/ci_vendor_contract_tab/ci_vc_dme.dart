import 'dart:async';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/modules/establishment/providers/delete_popup_provider.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/new_org_doc/new_org_doc.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/new_org_doc.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/files_constant-widget.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/org_add_popup_const.dart';

class VendorContractDMEProvider extends ChangeNotifier {
  // Controllers
  TextEditingController docNameController = TextEditingController();
  TextEditingController docIdController = TextEditingController();
  TextEditingController calenderController = TextEditingController();
  TextEditingController idOfDocController = TextEditingController();
  TextEditingController daysController = TextEditingController(text: "1");

  // StreamController
  final StreamController<List<NewOrgDocument>> reportController = StreamController<List<NewOrgDocument>>();

  // State Variables
  int currentPage = 1;
  bool isLoading = false;
  String? expiryType;
  String? selectedValue;
  String? selectedYear = FrontendConfigStore.data!.config.year;
  // String? selectedYear = AppConfig.year;

  // Methods
  void setCurrentPage(int pageNumber) {
    currentPage = pageNumber;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
  Future<void> onDelete(NewOrgDocument doc, BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return DeletePopupProvider(
          title: DeletePopupString.deleteDME,
          loadingDuration: isLoading,
          onCancel: () {
            Navigator.pop(context);
          },
          onDelete: () async {
            setLoading(true); // Set loading state
            try {
              await deleteNewOrgDoc(context, doc.orgDocumentSetupid);
              Navigator.pop(context); // Close the confirmation dialog
              showDialog(
                context: context,
                builder: (context) => DeleteSuccessPopup(),
              );
            } finally {
              setLoading(false); // Reset loading state
            }
          },
        );
      },
    );
  }

  Future<void> onEdit(NewOrgDocument doc, BuildContext context) async {
    var snapshotPrefill = await getPrefillNewOrgDocument(context, doc.orgDocumentSetupid);

    docNameController.text = snapshotPrefill.docName ?? "";

    showDialog(
      context: context,
      builder: (context) {
        return OrgDocNewEditPopup(
          title: EditPopupString.editDME,
          orgDocumentSetupid: snapshotPrefill.orgDocumentSetupid ?? 0,
          docTypeId: snapshotPrefill.documentTypeId ?? 0,
          subDocTypeId: snapshotPrefill.documentSubTypeId ?? 0,
          idOfDoc: snapshotPrefill.idOfDocument ?? "",
          docName: snapshotPrefill.docName ?? "",
          expiryType: snapshotPrefill.expiryType,
          threshhold: snapshotPrefill.threshold ?? 0,
          expiryDate: snapshotPrefill.expiryDate,
          expiryReminder: snapshotPrefill.expiryReminder,
          docTypeText: AppStringEM.vendorContracts,
          subDocTypeText: AppStringEM.dme,
        );
      },
    );
  }

  @override
  void dispose() {
    docNameController.dispose();
    docIdController.dispose();
    calenderController.dispose();
    idOfDocController.dispose();
    daysController.dispose();
    reportController.close();
    super.dispose();
  }
}

class VendorContractDME extends StatelessWidget {
  final int docId;
  final int subDocId;

  const VendorContractDME({
    super.key,
    required this.docId,
    required this.subDocId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorContractDMEProvider>(context);

    return Column(
      children: [
        PoliciesProcedureList(
          controller: provider.reportController,
          fetchDocuments: (context) => getNewOrgDocfetch(
            context,
            FrontendConfigStore.data!.config.vendorContracts,
            // AppConfig.vendorContracts,
            FrontendConfigStore.data!.config.subDocId8DME,
            // AppConfig.subDocId8DME,
            1,
            50,
          ),
          emptyMessage: ErrorMessageString.noDME,
          onEdit: (NewOrgDocument doc) {
            provider.onEdit(doc, context);
          },
          onDelete: (NewOrgDocument doc) {
            provider.onDelete(doc, context);
          },
        ),
      ],
    );
  }
}

