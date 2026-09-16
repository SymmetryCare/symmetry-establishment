import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/form_education_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/progress_form_data/form_education_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_employee_documents/widgets/add_degree_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:symmetry_establishment/modules/establishment/providers/delete_popup_provider.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';

/// Holds the company's degree list for the Degree tab of Employee Documents.
///
/// The degrees are the options behind the Degree dropdown in the employee
/// education form, so creating/editing/deleting one here changes what
/// employees can pick there.
class DegreeListProvider extends ChangeNotifier {
  final int itemsPerPage = 10;
  int currentPage = 1;
  bool _isLoading = false;
  bool _disposed = false;

  /// The degrees held as plain state rather than a stream: the Degree tab is
  /// built lazily by the PageView, so a broadcast stream could emit before the
  /// tab exists and leave it stuck on the spinner.
  List<EduactionDegree>? _degrees;
  Object? _error;
  bool _isFetching = false;

  List<EduactionDegree>? get degrees => _degrees;
  Object? get error => _error;
  bool get isFetching => _isFetching;

  void init(BuildContext context) => fetchDegrees(context);

  Future<void> fetchDegrees(BuildContext context) async {
    _isFetching = true;
    try {
      final data = await getDegreeDropDown(context);
      _degrees = data;
      _error = null;
    } catch (error) {
      _error = error;
    } finally {
      _isFetching = false;
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  String getSerialNumber(int index) {
    return (index + 1 + (currentPage - 1) * itemsPerPage)
        .toString()
        .padLeft(2, '0');
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void onPageNumberPressed(int pageNumber) {
    currentPage = pageNumber;
    notifyListeners();
  }

  void onPreviousPagePressed() {
    if (currentPage > 1) {
      currentPage--;
      notifyListeners();
    }
  }

  void onNextPagePressed(int totalPages) {
    if (currentPage < totalPages) {
      currentPage++;
      notifyListeners();
    }
  }

  void handleAdd(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddDegreePopup(
        onDegreeAdded: () => fetchDegrees(context),
      ),
    );
  }

  void handleEdit(BuildContext context, EduactionDegree degree) {
    showDialog(
      context: context,
      builder: (_) => AddDegreePopup(
        degreeId: degree.degreeId,
        initialDegree: degree.degree,
        onDegreeAdded: () => fetchDegrees(context),
      ),
    );
  }

  void handleDelete(BuildContext context, EduactionDegree degree) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return DeletePopupProvider(
          title: DeletePopupString.deleteDegree,
          loadingDuration: _isLoading,
          onCancel: () {
            Navigator.pop(dialogContext);
          },
          onDelete: () async {
            setLoading(true);
            try {
              await deleteEmployeeDegree(
                context: context,
                degreeId: degree.degreeId,
              );
              Navigator.pop(dialogContext);
              showDialog(
                context: context,
                builder: (_) => DeleteSuccessPopup(),
              );
            } finally {
              await fetchDegrees(context);
              setLoading(false);
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Degree tab: lists the company's degrees with edit and delete actions.
class DegreeList extends StatefulWidget {
  const DegreeList({super.key});

  @override
  State<DegreeList> createState() => _DegreeListState();
}

class _DegreeListState extends State<DegreeList> {
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DegreeListProvider>(
      builder: (context, provider, _) {
        if (provider.degrees == null && provider.error == null) {
          return Center(
            child: CircularProgressIndicator(
              color: ColorManager.blueprime,
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Text(
              'Error: ${provider.error}',
              style: AllNoDataAvailable.customTextStyle(context),
            ),
          );
        }

        if (provider.degrees!.isEmpty) {
          return Center(
            child: Text(
              ErrorMessageString.noDegree,
              style: AllNoDataAvailable.customTextStyle(context),
            ),
          );
        }

        final degrees = provider.degrees!;
        final int totalPages = (degrees.length / provider.itemsPerPage).ceil();
        if (provider.currentPage > totalPages) {
          provider.currentPage = totalPages;
        }
        final paginatedData = degrees
            .skip((provider.currentPage - 1) * provider.itemsPerPage)
            .take(provider.itemsPerPage)
            .toList();

        return Column(
          children: [
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                const double minContentWidth = 1200;
                final double contentWidth =
                    constraints.maxWidth > minContentWidth
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
                            const _DegreeTableHeading(),
                            SizedBox(height: AppSize.s10),
                            Expanded(
                              child: ListView.builder(
                                itemCount: paginatedData.length,
                                itemBuilder: (context, index) {
                                  final degree = paginatedData[index];
                                  return Column(
                                    children: [
                                      SizedBox(height: AppSize.s5),
                                      Container(
                                        padding: const EdgeInsets.only(
                                            bottom: AppPadding.p5),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: AppMargin.m50),
                                        decoration: BoxDecoration(
                                          color: ColorManager.white,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          boxShadow: [
                                            BoxShadow(
                                              color: ColorManager.grey
                                                  .withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        height: AppSize.s56,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Center(
                                                child: Text(
                                                  provider
                                                      .getSerialNumber(index),
                                                  style: DocumentTypeDataStyle
                                                      .customTextStyle(context),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 6,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: AppPadding.p20),
                                                child: Text(
                                                  degree.degree,
                                                  textAlign: TextAlign.start,
                                                  style: DocumentTypeDataStyle
                                                      .customTextStyle(context),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                    splashColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    hoverColor:
                                                        Colors.transparent,
                                                    onPressed: () =>
                                                        provider.handleEdit(
                                                            context, degree),
                                                    icon: Icon(
                                                      Icons.edit_outlined,
                                                      size: IconSize.I18,
                                                      color: IconColorManager
                                                          .bluebottom,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  IconButton(
                                                    splashColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    hoverColor:
                                                        Colors.transparent,
                                                    onPressed: () =>
                                                        provider.handleDelete(
                                                            context, degree),
                                                    icon: Icon(
                                                      Icons
                                                          .delete_outline_outlined,
                                                      size: IconSize.I18,
                                                      color:
                                                          IconColorManager.red,
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
              currentPage: provider.currentPage,
              items: degrees,
              itemsPerPage: provider.itemsPerPage,
              onPreviousPagePressed: provider.onPreviousPagePressed,
              onPageNumberPressed: provider.onPageNumberPressed,
              onNextPagePressed: () => provider.onNextPagePressed(totalPages),
            ),
          ],
        );
      },
    );
  }
}

class _DegreeTableHeading extends StatelessWidget {
  const _DegreeTableHeading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.s30,
      margin: EdgeInsets.symmetric(
          horizontal: AppMargin.m48, vertical: AppMargin.m10),
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p20),
      decoration: BoxDecoration(
        color: ColorManager.fmediumgrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                AppStringEM.srNo,
                style: TableHeading.customTextStyle(context),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.only(left: AppPadding.p20),
              child: Text(
                AppStringEM.degree,
                style: TableHeading.customTextStyle(context),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              AppStringEM.actions,
              textAlign: TextAlign.center,
              style: TableHeading.customTextStyle(context),
            ),
          ),
        ],
      ),
    );
  }
}
