import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/providers/hr_register_provider.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/thank_you_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/bottom_row.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/top_row.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/taxtfield_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/dropdown_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/constant_in_all.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/form_acknowledgements_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/form_banking_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/form_clinical_license.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/form_educaton_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/form_employment_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/form_general_Screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/form_health_records_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/form_legal_documents_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/form_licenses_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/form_reference_screen.dart';

// ✅ Suppresses Flutter's auto-drawn scrollbar for vertical scrollables only
// (e.g. anything scrolling inside the Stepper's content area). Horizontal
// scroll is untouched and falls through to the default behavior, so the
// CustomScrollbar wrapping the Stepper's horizontal SingleChildScrollView
// below keeps showing its themed thumb exactly as before.
class _HorizontalOnlyScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    if (details.direction == AxisDirection.down || details.direction == AxisDirection.up) {
      return child;
    }
    return super.buildScrollbar(context, child, details);
  }
}

class MultiStepForm extends StatefulWidget {
  final int depID;
  final int employeeID;

  const MultiStepForm(
      {super.key, required this.employeeID, required this.depID});

  @override
  _MultiStepFormState createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm> {
  final ScrollController _horizontalScrollController = ScrollController();

  double textFieldWidth = 430;
  double textFieldHeight = 38;

  TextEditingController firstName = TextEditingController();

  // Current step in the stepper
  int _currentStep = 0;

  bool isChecked = false;

  bool get isFirstStep => _currentStep == 0;
  bool _isEducationSaved = false;
  bool _isEmployeementSaved = false;
  bool _isLicenseSaved = false;
  bool _isBankingSaved = false;
  bool _isReferenceSaved = false;
  bool _isClicalLicenseSaved = false;
  bool _isHealthRecordSaved = false;
  bool _isAckRecordSaved = false;

  bool get isLastStep => _currentStep == steps().length - 1;
  bool isCompleted = false;

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isCompleted
        ? const OnBoardingThankYou()
        : Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopRowConstant(),
      ),
      // ✅ Wraps the whole body so any vertical scrollable inside (e.g.
      // within the Stepper's content area) doesn't get Flutter's default
      // auto-drawn scrollbar, while horizontal scroll (the Stepper itself,
      // via CustomScrollbar below) is unaffected.
      body: ScrollConfiguration(
        behavior: _HorizontalOnlyScrollBehavior(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Details",
                    style: FormHeading.customTextStyle(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSize.s5),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
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
                        padding:
                        const EdgeInsets.only(bottom: AppPadding.p10),
                        child: SizedBox(
                          width: contentWidth,
                          height: constraints.maxHeight,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                              ),
                              child: Stepper(
                                physics: const ScrollPhysics(),
                                type: StepperType.horizontal,
                                steps: steps(),
                                currentStep: _currentStep,
                                // Custom icon override: replaces the default pencil
                                // icon shown for StepState.editing (i.e. when
                                // providerState.isXxxSaved == false). Return null
                                // for any other state to keep default behaviour
                                // (index number / check / error) untouched.
                                stepIconBuilder: (int index, StepState state) {
                                  if (state == StepState.editing) {
                                    return const Icon(
                                      Icons.mode_edit_outline_outlined,
                                      color: Colors.white,
                                      size: 18.0,
                                    );
                                  }
                                  return null;
                                },
                                onStepContinue: () {
                                  if (isLastStep) {
                                    setState(() => isCompleted = true);
                                  } else {
                                    setState(() => _currentStep += 1);
                                  }
                                },
                                onStepCancel: isFirstStep
                                    ? null
                                    : () => setState(
                                        () => _currentStep -= 1),
                                controlsBuilder: (context, details) =>
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(top: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          if (!isFirstStep) ...[
                                            const SizedBox(width: 20),
                                            const SizedBox(),
                                          ],
                                          const SizedBox(width: 20),
                                        ],
                                      ),
                                    ),
                                onStepTapped: (step) =>
                                    setState(() => _currentStep = step),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomBarRow(),
    );
  }

  List<Step> steps() {
    final providerState =
    Provider.of<HrProgressMultiStape>(context, listen: false);
    List<Step> stepsList = [
      // General step
      Step(
        state: providerState.isGneralSaved
            ? StepState.complete
            : StepState.editing,
        isActive: _currentStep >= 0,
        title: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Text(
            'General',
            style: formNameText.customTextStyle(context),
          ),
        ),
        content: generalForm(
          context: context,
          employeeID: widget.employeeID,
          onSave: () {
            setState(() {
              _currentStep = _currentStep + 1;
              providerState.isGeneralChnaged();
            });
          },
          onNext: () {
            setState(() {
              _currentStep = _currentStep + 1;
            });
          },
        ),
      ),
      // Employment step
      Step(
        state: providerState.isEmployeementSaved
            ? StepState.complete
            : StepState.editing,
        isActive: _currentStep >= 1,
        title: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Text(
            'Employment',
            style: formNameText.customTextStyle(context),
          ),
        ),
        content: EmploymentScreen(
          context: context,
          employeeID: widget.employeeID,
          onSave: () {
            setState(() {
              _currentStep = _currentStep + 1;
              providerState.isEmployeementChnaged();
            });
          },
          onBack: () {
            setState(() {
              _currentStep = _currentStep - 1;
            });
          },
          onNext: () {
            setState(() {
              _currentStep = _currentStep + 1;
            });
          },
        ),
      ),
      // Education step
      Step(
        state: providerState.isEducationSaved
            ? StepState.complete
            : StepState.editing,
        isActive: _currentStep >= 2,
        title: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Text(
            'Education',
            style: formNameText.customTextStyle(context),
          ),
        ),
        content: EducationScreen(
          context: context,
          employeeID: widget.employeeID,
          onSave: () {
            setState(() {
              _currentStep = _currentStep + 1;
              providerState.isEducationChnaged();
            });
          },
          onBack: () {
            setState(() {
              _currentStep = _currentStep - 1;
            });
          },
          onNext: () {
            setState(() {
              _currentStep = _currentStep + 1;
            });
          },
        ),
      ),
      // References step
      Step(
        state: providerState.isReferenceSaved
            ? StepState.complete
            : StepState.editing,
        isActive: _currentStep >= 3,
        title: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Text(
            'References',
            style: formNameText.customTextStyle(context),
          ),
        ),
        content: ReferencesScreen(
          context: context,
          employeeID: widget.employeeID,
          onSave: () {
            setState(() {
              _currentStep = _currentStep + 1;
              providerState.isReferenceChnaged();
            });
          },
          onBack: () {
            setState(() {
              _currentStep = _currentStep - 1;
            });
          },
          onNext: () {
            setState(() {
              _currentStep = _currentStep + 1;
            });
          },
        ),
      ),
      // Licenses step
      Step(
        state: providerState.isLicenseSaved
            ? StepState.complete
            : StepState.editing,
        isActive: _currentStep >= 4,
        title: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Text(
            'Licenses',
            style: formNameText.customTextStyle(context),
          ),
        ),
        content: LicensesScreen(
          context: context,
          employeeID: widget.employeeID,
          onSave: () {
            setState(() {
              _currentStep = _currentStep + 1;
              providerState.isLicenseChnaged();
            });
          },
          onBack: () {
            setState(() {
              _currentStep = _currentStep - 1;
            });
          },
          onNext: () {
            setState(() {
              _currentStep = _currentStep + 1;
            });
          },
        ),
      ),
      // Conditionally add Clinical License if depID matches clinicalId
      Step(
        state: providerState.isClicalLicenseSaved
            ? StepState.complete
            : StepState.editing,
        isActive: _currentStep >= 5,
        title: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Text(
            'Clinical\nLicense',
            style: formNameText.customTextStyle(context),
          ),
        ),
        content: Clinical_licenses(
          context: context,
          employeeID: widget.employeeID,
          onSave: () {
            setState(() {
              _currentStep = _currentStep + 1;
              providerState.isClinicalLicenseChnaged();
            });
          },
          onBack: () {
            setState(() {
              _currentStep = _currentStep - 1;
            });
          },
          onNext: () {
            setState(() {
              _currentStep = _currentStep + 1;
            });
          },
        ),
      ),
      // Banking step
      Step(
        state: providerState.isBankingSaved
            ? StepState.complete
            : StepState.editing,
        isActive: _currentStep >= 6,
        title: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Text(
            'Banking',
            style: formNameText.customTextStyle(context),
          ),
        ),
        content: BankingScreen(
          context: context,
          employeeID: widget.employeeID,
          onSave: () {
            setState(() {
              _currentStep = _currentStep + 1;
              providerState.isBankingChnaged(); // Mark education data as saved
            });
          },
          onBack: () {
            print(">>>>>>>${_currentStep}");
            setState(() {
              _currentStep = _currentStep - 1;
            });
          },
          onNext: () {
            setState(() {
              _currentStep = _currentStep + 1;
            });
          },
        ),
      ),
      // Health Records step
      Step(
        state: providerState.isHealthRecordSaved
            ? StepState.complete
            : StepState.editing,
        isActive: _currentStep >= 7,
        title: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Text(
            'Health \nRecords',
            style: formNameText.customTextStyle(context),
          ),
        ),
        content: HealthRecordsScreen(
          context: context,
          employeeID: widget.employeeID,
          onSave: () {
            setState(() {
              _currentStep = _currentStep + 1;
              providerState.isHealthRecordChnaged();
            });
          },
          onBack: () {
            setState(() {
              _currentStep = _currentStep - 1;
            });
          },
          onNext: () {
            setState(() {
              _currentStep = _currentStep + 1;
            });
          },
        ),
      ),
      // Acknowledgements step
      Step(
        state: providerState.isAckRecordSaved
            ? StepState.complete
            : StepState.editing,
        isActive: _currentStep >= 8,
        title: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Text(
            'Acknowledgements',
            style: formNameText.customTextStyle(context),
          ),
        ),
        content: AcknowledgementsScreen(
          context: context,
          employeeID: widget.employeeID,
          onSave: () {
            setState(() {
              _currentStep = _currentStep + 1;
              providerState.isAckRecordChnaged();
            });
          },
          onBack: () {
            setState(() {
              _currentStep = _currentStep - 1;
            });
          },
          onNext: () {
            setState(() {
              _currentStep = _currentStep + 1;
            });
          },
        ),
      ),
      // Legal Documents step
      Step(
        state: _currentStep <= 9 ? StepState.editing : StepState.complete,
        isActive: _currentStep >= 9,
        title: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Text(
            'Legal \nDocuments',
            style: formNameText.customTextStyle(context),
          ),
        ),
        content: LegalDocumentsScreen(
          context: context,
          employeeID: widget.employeeID,
          onSave: () {
            setState(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OnBoardingThankYou()),
              );
            });
          },
          onBack: () {
            setState(() {
              _currentStep = _currentStep - 1;
            });
          },
        ),
      ),
    ];
    List<Step> stepsLista = [
      // General step
      Step(
        state: providerState.isGneralSaved
            ? StepState.complete
            : StepState.editing,
        isActive: _currentStep >= 0,
        title: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Text(
            'General',
            style: formNameText.customTextStyle(context),
          ),
        ),
        content: generalForm(
          context: context,
          employeeID: widget.employeeID,
          onSave: () {
            setState(() {
              _currentStep = _currentStep + 1;
              providerState.isGeneralChnaged();
            });
          },
          onNext: () {
            setState(() {
              _currentStep = _currentStep + 1;
            });
          },
        ),
      ),
      // Employment step
      Step(
        state: providerState.isEmployeementSaved
            ? StepState.complete
            : StepState.editing,
        isActive: _currentStep >= 1,
        title: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Text(
            'Employment',
            style: formNameText.customTextStyle(context),
          ),
        ),
        content: EmploymentScreen(
          context: context,
          employeeID: widget.employeeID,
          onSave: () {
            setState(() {
              _currentStep = _currentStep + 1;
              providerState.isEmployeementChnaged();
            });
          },
          onBack: () {
            setState(() {
              _currentStep = _currentStep - 1;
            });
          },
          onNext: () {
            setState(() {
              _currentStep = _currentStep + 1;
            });
          },
        ),
      ),
      // Education step
      Step(
        state: providerState.isEducationSaved
            ? StepState.complete
            : StepState.editing,
        isActive: _currentStep >= 2,
        title: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Text(
            'Education',
            style: formNameText.customTextStyle(context),
          ),
        ),
        content: EducationScreen(
          context: context,
          employeeID: widget.employeeID,
          onSave: () {
            setState(() {
              _currentStep = _currentStep + 1;
              providerState.isEducationChnaged();
            });
          },
          onBack: () {
            setState(() {
              _currentStep = _currentStep - 1;
            });
          },
          onNext: () {
            setState(() {
              _currentStep = _currentStep + 1;
            });
          },
        ),
      ),
      // References step
      Step(
        state: providerState.isReferenceSaved
            ? StepState.complete
            : StepState.editing,
        isActive: _currentStep >= 3,
        title: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Text(
            'References',
            style: formNameText.customTextStyle(context),
          ),
        ),
        content: ReferencesScreen(
          context: context,
          employeeID: widget.employeeID,
          onSave: () {
            setState(() {
              _currentStep = _currentStep + 1;
              providerState.isReferenceChnaged();
            });
          },
          onBack: () {
            setState(() {
              _currentStep = _currentStep - 1;
            });
          },
          onNext: () {
            setState(() {
              _currentStep = _currentStep + 1;
            });
          },
        ),
      ),
      // Licenses step
      Step(
        state: providerState.isLicenseSaved
            ? StepState.complete
            : StepState.editing,
        isActive: _currentStep >= 4,
        title: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Text(
            'Licenses',
            style: formNameText.customTextStyle(context),
          ),
        ),
        content: LicensesScreen(
          context: context,
          employeeID: widget.employeeID,
          onSave: () {
            setState(() {
              _currentStep = _currentStep + 1;
              providerState.isLicenseChnaged();
            });
          },
          onBack: () {
            setState(() {
              _currentStep = _currentStep - 1;
            });
          },
          onNext: () {
            setState(() {
              _currentStep = _currentStep + 1;
            });
          },
        ),
      ),
      // Banking step
      Step(
        state: providerState.isBankingSaved
            ? StepState.complete
            : StepState.editing,
        isActive: _currentStep >= 5,
        title: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Text(
            'Banking',
            style: formNameText.customTextStyle(context),
          ),
        ),
        content: BankingScreen(
          context: context,
          employeeID: widget.employeeID,
          onSave: () {
            setState(() {
              _currentStep = _currentStep + 1;
            });
          },
          onBack: () {
            print(">>>>>>>${_currentStep}");
            setState(() {
              _currentStep = _currentStep - 1;
              providerState.isBankingChnaged();
            });
          },
          onNext: () {
            setState(() {
              _currentStep = _currentStep + 1;
            });
          },
        ),
      ),
      // Health Records step
      Step(
        state: providerState.isHealthRecordSaved
            ? StepState.complete
            : StepState.editing,
        isActive: _currentStep >= 6,
        title: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Text(
            'Health \nRecords',
            style: formNameText.customTextStyle(context),
          ),
        ),
        content: HealthRecordsScreen(
          context: context,
          employeeID: widget.employeeID,
          onSave: () {
            setState(() {
              _currentStep = _currentStep + 1;
              providerState.isHealthRecordChnaged();
            });
          },
          onBack: () {
            setState(() {
              _currentStep = _currentStep - 1;
            });
          },
          onNext: () {
            setState(() {
              _currentStep = _currentStep + 1;
            });
          },
        ),
      ),
      // Acknowledgements step
      Step(
        state: providerState.isAckRecordSaved
            ? StepState.complete
            : StepState.editing,
        isActive: _currentStep >= 7,
        title: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Text(
            'Acknowledgements',
            style: formNameText.customTextStyle(context),
          ),
        ),
        content: AcknowledgementsScreen(
          context: context,
          employeeID: widget.employeeID,
          onSave: () {
            setState(() {
              _currentStep = _currentStep + 1;
              providerState.isAckRecordChnaged();
            });
          },
          onBack: () {
            setState(() {
              _currentStep = _currentStep - 1;
            });
          },
          onNext: () {
            setState(() {
              _currentStep = _currentStep + 1;
            });
          },
        ),
      ),
      // Legal Documents step
      Step(
        state: _currentStep <= 8 ? StepState.editing : StepState.complete,
        isActive: _currentStep >= 8,
        title: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Text(
            'Legal \nDocuments',
            style: formNameText.customTextStyle(context),
          ),
        ),
        content: LegalDocumentsScreen(
          context: context,
          employeeID: widget.employeeID,
          onSave: () {
            setState(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OnBoardingThankYou()),
              );
            });
          },
          onBack: () {
            setState(() {
              _currentStep = _currentStep - 1;
            });
          },
        ),
      ),
    ];

    if (widget.depID == FrontendConfigStore.data?.config.clinicalId) {
      return stepsList;
    } else {
      return stepsLista;
    }
  }
}