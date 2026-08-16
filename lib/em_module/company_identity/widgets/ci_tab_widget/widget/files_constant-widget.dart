import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../../../app/resources/color.dart';
import '../../../../../../../app/resources/common_resources/common_theme_const.dart';
import '../../../../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../../../../app/resources/value_manager.dart';
import '../../../../../../../data/api_data/establishment_data/company_identity/new_org_doc.dart';
import '../../../../../../widgets/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:prohealth/presentation/widgets/widgets/custom_scrollbar.dart';
import './ci_org_doc_tab/widgets/heading_constant_widget.dart';

///stf
class PoliciesProcedureList extends StatefulWidget {
  final StreamController<List<NewOrgDocument>> controller;
  final Future<List<NewOrgDocument>> Function(BuildContext context) fetchDocuments;
  final String emptyMessage;
  final Function(NewOrgDocument doc) onEdit;
  final Function(NewOrgDocument doc) onDelete;
  final int itemsPerPage;

  const PoliciesProcedureList({
    super.key,
    required this.controller,
    required this.fetchDocuments,
    required this.emptyMessage,
    required this.onEdit,
    required this.onDelete,
    this.itemsPerPage = 10,
  });

  @override
  State<PoliciesProcedureList> createState() => _PoliciesProcedureListState();
}

class _PoliciesProcedureListState extends State<PoliciesProcedureList> {
  final ScrollController _horizontalScrollController = ScrollController();
  int flexVal = 2;

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int currentPage = 1;
    final _controller = widget.controller;

    return Expanded(
      child: StreamBuilder<List<NewOrgDocument>>(
        stream: _controller.stream,
        builder: (context, snapshot) {
          widget.fetchDocuments(context).then((data) {
            _controller.add(data);
          }).catchError((error) {
            // Handle error
          });

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: ColorManager.blueprime,
              ),
            );
          }

          if (snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                widget.emptyMessage,
                style: AllNoDataAvailable.customTextStyle(context),
              ),
            );
          }

          if (snapshot.hasData) {
            int totalItems = snapshot.data!.length;
            int totalPages = (totalItems / widget.itemsPerPage).ceil();
            List<NewOrgDocument> paginatedData = snapshot.data!
                .skip((currentPage - 1) * widget.itemsPerPage)
                .take(widget.itemsPerPage)
                .toList();

            return Column(
              children: [
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    const double minContentWidth = 1200;
                    final double contentWidth = constraints.maxWidth > minContentWidth
                        ? constraints.maxWidth
                        : minContentWidth;
                    return CustomScrollbar(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        controller: _horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: AppPadding.p10),
                          child: SizedBox(
                            width: contentWidth,
                            height: constraints.maxHeight,
                            child: Column(
                              children: [
                                TableHeadingConst(),
                                SizedBox(height: AppSize.s10),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: paginatedData.length,
                                    itemBuilder: (context, index) {
                                      int serialNumber = index + 1 + (currentPage - 1) * widget.itemsPerPage;
                                      String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                                      NewOrgDocument policiesdata = paginatedData[index];

                                      return Column(
                                        children: [
                                          SizedBox(height: AppSize.s5),
                                          Container(
                                            padding: EdgeInsets.only(bottom: AppPadding.p5),
                                            margin: EdgeInsets.symmetric(horizontal: AppMargin.m50),
                                            decoration: BoxDecoration(
                                              color: ColorManager.white,
                                              borderRadius: BorderRadius.circular(4),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: ColorManager.grey.withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            height: AppSize.s56,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                Expanded(
                                                  flex: flexVal,
                                                  child: Center(
                                                    child: Text(
                                                      formattedSerialNumber,
                                                      style: DocumentTypeDataStyle.customTextStyle(context),
                                                      textAlign: TextAlign.start,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: flexVal,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 115.0),
                                                    child: Text(
                                                      policiesdata.idOfDocument,
                                                      style: DocumentTypeDataStyle.customTextStyle(context),
                                                      textAlign: TextAlign.start,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(flex: 1, child: SizedBox()),
                                                Expanded(
                                                  flex: flexVal,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(left: AppPadding.p20),
                                                    child: Text(
                                                      policiesdata.docName,
                                                      textAlign: TextAlign.start,
                                                      style: DocumentTypeDataStyle.customTextStyle(context),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: flexVal,
                                                  child: Center(
                                                    child: Text(
                                                      policiesdata.expiryReminder,
                                                      style: DocumentTypeDataStyle.customTextStyle(context),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      IconButton(
                                                        hoverColor: Colors.transparent,
                                                        splashColor: Colors.transparent,
                                                        highlightColor: Colors.transparent,
                                                        onPressed: () => widget.onEdit(policiesdata),
                                                        icon: Icon(
                                                          Icons.edit_outlined,
                                                          size: IconSize.I18,
                                                          color: IconColorManager.bluebottom,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        hoverColor: Colors.transparent,
                                                        splashColor: Colors.transparent,
                                                        highlightColor: Colors.transparent,
                                                        onPressed: () => widget.onDelete(policiesdata),
                                                        icon: Icon(
                                                          Icons.delete_outline,
                                                          size: IconSize.I18,
                                                          color: IconColorManager.red,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                PaginationControlsWidget(
                  currentPage: currentPage,
                  items: snapshot.data!,
                  itemsPerPage: widget.itemsPerPage,
                  onPreviousPagePressed: () {
                    if (currentPage > 1) {
                      currentPage--;
                    }
                  },
                  onPageNumberPressed: (pageNumber) {
                    currentPage = pageNumber;
                  },
                  onNextPagePressed: () {
                    if (currentPage < totalPages) {
                      currentPage++;
                    }
                  },
                ),
              ],
            );
          }

          return Offstage();
        },
      ),
    );
  }
}