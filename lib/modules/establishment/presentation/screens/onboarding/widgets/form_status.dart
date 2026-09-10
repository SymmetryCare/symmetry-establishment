import 'dart:async';

import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/download_doc_const.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/form_status_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/onboarding_data/form_status_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/widgets/document_row_card.dart';

class FormStatusScreen extends StatefulWidget {
  final int employeeId;
  const FormStatusScreen({super.key,required this.employeeId});

  @override
  State<FormStatusScreen> createState() => _FormStatusScreenState();
}

class _FormStatusScreenState extends State<FormStatusScreen> {
  final StreamController<List<FormModel>> formController =
  StreamController<List<FormModel>>();
  int currentPage = 1;
  final int itemsPerPage = 10;
  final int totalPages = 5;

  void onPageNumberPressed(int pageNumber) {
    setState(() {
      currentPage = pageNumber;
    });
  }

  @override
  void initState() {
    super.initState();
    getFormStatus(context,widget.employeeId,).then((data){
      formController.add(data);
    }).catchError((error){});
  }
  Future<void> _openForm(FormModel formStatus) async {
    await downloadFile(
        context: context,
        fileUrl: formStatus.url,
        documentName: formStatus.htmlname,
        apiPath: DownloadDocumentRepository
            .getFormHtmlTemplatesStatusDocumentByFileName());
  }

  @override
  Widget build(BuildContext context) {
    ///hide handbook code
    return StreamBuilder<List<FormModel>>(
      stream: formController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: ColorManager.blueprime,
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Offstage();
        }
        if (snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              AppStringHRNoData.noOnboardFormStatus,
              style: AllNoDataAvailable.customTextStyle(context),
            ),
          );
        }
        if (snapshot.hasData) {
          final filteredData = snapshot.data!
              .where((formStatus) =>
          formStatus.htmlname != AppStringLegalDocument.returnOfcompanyProperty &&
              formStatus.htmlname != AppStringLegalDocument.employeeHandbook)
              .toList(); // Filter out employeeHandbook
          return ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final FormModel formStatus = filteredData[index];
                final bool signed = formStatus.signed ||
                    formStatus.htmlname ==
                        AppStringLegalDocument.employeeHandbook;
                return DocumentRowCard(
                  fileName: formStatus.htmlname,
                  statusLabel: signed ? 'Signed' : 'Unsigned',
                  statusColor: signed
                      ? const Color(0xFF1AB595)
                      : const Color(0xFFE05D5F),
                  onTap: () => _openForm(formStatus),
                  // Only a signed form has a document to pull down.
                  onDownload: signed ? () => _openForm(formStatus) : null,
                );
              },
            ),
          );
        }
        return const Offstage();
      },
    );
  }
}