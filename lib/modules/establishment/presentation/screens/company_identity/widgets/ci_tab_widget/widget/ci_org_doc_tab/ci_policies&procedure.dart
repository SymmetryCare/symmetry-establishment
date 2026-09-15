import 'dart:async';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/new_org_doc/new_org_doc.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/heading_constant_widget.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/org_add_popup_const.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/modules/establishment/providers/delete_popup_provider.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/new_org_doc.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/files_constant-widget.dart';

///provide
class CIPoliciesProcedureProvider extends ChangeNotifier {
  // Controllers
  TextEditingController docNameController = TextEditingController();
  TextEditingController docIdController = TextEditingController();
  TextEditingController calenderController = TextEditingController();
  TextEditingController idOfDocController = TextEditingController();
  TextEditingController daysController = TextEditingController(text: "1");

  // StreamControllers
  final StreamController<List<NewOrgDocument>> policiesAndProcedureController =
  StreamController<List<NewOrgDocument>>();

  // State Variables
  int currentPage = 1;
  bool isLoading = false;

  final int itemsPerPage = 10;
  final int totalPages = 5;

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
          title: DeletePopupString.deletePolicy,
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
          height: AppSize.s383,
          title: EditPopupString.editPolicy,
          orgDocumentSetupid: snapshotPrefill.orgDocumentSetupid ?? 0,
          docTypeId: snapshotPrefill.documentTypeId ?? 0,
          subDocTypeId: snapshotPrefill.documentSubTypeId ?? 0,
          idOfDoc: snapshotPrefill.idOfDocument ?? "",
          docName: snapshotPrefill.docName ?? "",
          expiryType: snapshotPrefill.expiryType,
          threshhold: snapshotPrefill.threshold ?? 0,
          expiryDate: snapshotPrefill.expiryDate,
          expiryReminder: snapshotPrefill.expiryReminder,
          docTypeText: AppStringEM.policiesAndProcedures,
          subDocTypeText: '',
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
    policiesAndProcedureController.close();
    super.dispose();
  }
}

class CIPoliciesProcedure extends StatelessWidget {
  final int docId;
  final int subDocId;

  const CIPoliciesProcedure({
    super.key,
    required this.docId,
    required this.subDocId,
  });

  @override
  Widget build(BuildContext context) {
    // Get the provider instance
    final provider = Provider.of<CIPoliciesProcedureProvider>(context);

    return Column(
      children: [
        PoliciesProcedureList(
          controller: provider.policiesAndProcedureController,
          fetchDocuments: (context) => getNewOrgDocfetch(
            context,
            FrontendConfigStore.data!.config.policiesAndProcedure,
            // AppConfig.policiesAndProcedure,
            FrontendConfigStore.data!.config.subDocId0,
            // AppConfig.subDocId0,
            1,
            50,
          ),
          emptyMessage: ErrorMessageString.noPolicyProcedure,
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

///calendar code
// child2: Visibility(
//   visible: selectedExpiryType == "Scheduled" || selectedExpiryType == "Issuer Expiry",
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Padding(
//         padding: const EdgeInsets.only(left: 2),
//         child: Text(
//           "Expiry Date",
//           style: GoogleFonts.firaSans(
//             fontSize: FontSize.s12,
//             fontWeight: FontWeight.w700,
//             color: ColorManager.mediumgrey,
//             decoration: TextDecoration.none,
//           ),
//         ),
//       ),
//       SizedBox(height: 5,),
//       FormField<String>(
//         builder: (FormFieldState<String> field) {
//           return SizedBox (
//             width: 354,
//             height: 30,
//             child:   TextFormField(
//               controller: calenderController,
//               cursorColor: ColorManager.black,
//               style: GoogleFonts.firaSans(
//                 fontSize: FontSize.s12,
//                 fontWeight: FontWeight.w700,
//                 color: ColorManager.mediumgrey,
//                 //decoration: TextDecoration.none,
//               ),
//               decoration: InputDecoration(
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: ColorManager.fmediumgrey, width: 1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: ColorManager.fmediumgrey, width: 1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 hintText: 'mm-dd-yyyy',
//                 hintStyle: GoogleFonts.firaSans(
//                   fontSize: FontSize.s12,
//                   fontWeight: FontWeight.w700,
//                   color: ColorManager.mediumgrey,
//                   //decoration: TextDecoration.none,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide(width: 1,color: ColorManager.fmediumgrey),
//                 ),
//                 contentPadding:
//                 EdgeInsets.symmetric(horizontal: 16),
//                 suffixIcon: Icon(Icons.calendar_month_outlined,
//                     color: ColorManager.blueprime),
//                 errorText: field.errorText,
//               ),
//               onTap: () async {
//                 DateTime? pickedDate = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(3101),
//                 );
//                 if (pickedDate != null) {
//                   calenderController.text =
//                       DateFormat('MM-dd-yyyy').format(pickedDate);
//                 }
//               },
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'please select birth date';
//                 }
//                 return null;
//               },
//             ),
//           );
//         },
//       ),
//     ],
//   ),
// ),
