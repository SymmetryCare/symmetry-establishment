import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/modules/establishment/providers/hr_register_provider.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/new_widget_const/forms_blue_header_const.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/form_reference_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/equipment_child/equipment_head_tabbar.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/progress_form_data/form_reference_data.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/taxtfield_constant.dart';

class ReferencesScreen extends StatefulWidget {
  final int employeeID;
  final Function onSave;
  final Function onBack;
  final Function onNext;
  const ReferencesScreen({
    super.key,
    required this.context,
    required this.employeeID, required this.onSave, required this.onBack, required this.onNext,
  });

  final BuildContext context;

  @override
  State<ReferencesScreen> createState() => _ReferencesScreenState();
}

class _ReferencesScreenState extends State<ReferencesScreen> {
  List<GlobalKey<_ReferencesFormState>> referenceFormKeys = [];
  bool isVisible = false;
  TextEditingController name = TextEditingController();
  TextEditingController titleposition = TextEditingController();
  TextEditingController companyorganization = TextEditingController();
  TextEditingController mobilenumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController knowthisperson = TextEditingController();
  TextEditingController lengthofassociation = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEducationData();
  }
  Future<void> _loadEducationData() async {
    try {
      List<ReferenceDataForm> prefilledData = await getEmployeeReferenceForm(context, widget.employeeID);
      if(prefilledData.isEmpty){
        addReferenseForm();
      }
      else{
        setState(() {
          referenceFormKeys = List.generate(
            prefilledData.length,
                (index) => GlobalKey<_ReferencesFormState>(),
          );
          final providerState = Provider.of<HrProgressMultiStape>(context,listen: false);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            providerState.isReferenceChnaged();
          });
        });
      }

    } catch (e) {
      print('Error loading Education data: $e');
    }
  }
  void addReferenseForm() {
    setState(() {
      referenceFormKeys.add(GlobalKey<_ReferencesFormState>());
    });
  }

  void removeReferenseForm(GlobalKey<_ReferencesFormState> key) {
    setState(() {
      referenceFormKeys.remove(key);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 150),
          child: FormsBlueHeaderConst(
            text: 'Please provide the names and contact information of three professional references who can speak to your work experience and qualifications.For each reference, kindly include the following information:',
          ),
        ),
        const SizedBox(height: AppSizeConst.A20),
        Column(
          children: referenceFormKeys.asMap().entries.map((entry) {
            int index = entry.key;
            GlobalKey<_ReferencesFormState> key = entry.value;
            return ReferencesForm(
              key: key,
              index: index + 1,
              onRemove: () => removeReferenseForm(key),
              employeeID: widget.employeeID,
              isVisible: isVisible,
            );
          }).toList(),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 150),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: addReferenseForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff50B5E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                    'Add Reference',
                    style:BlueButtonTextConst.customTextStyle(context)
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizeConst.A20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FormOutlineButtonConst(
              text: 'Previous',
              onPressed: () async {
                await widget.onBack();
              },
            ),
            const SizedBox(
              width: 30,
            ),

            FormSaveButtonConst(
              isLoading: isLoading,
              onPressed: () async {
                if (!mounted) return;

                try {
                  setState(() => isLoading = true);

                  int savedCount = 0;
                  bool anyFieldErrors = false;

                  for (var key in referenceFormKeys) {
                    final st = key.currentState;
                    if (st == null || st.isPrefill) continue;

                    st.clearFieldErrors();

                    final response = await postreferencescreenData(
                      context,
                      st.lengthofassociation.text,
                      "__",
                      st.companyorganization.text,
                      st.email.text,
                      st.widget.employeeID,
                      st.mobilenumber.text,
                      st.name.text,
                      st.knowthisperson.text,
                      st.titleposition.text,
                    );

                    if (!mounted) return;

                    if (response.statusCode == 200 || response.statusCode == 201) {
                      savedCount++;
                    } else {
                      if (response.fieldErrors != null && response.fieldErrors!.isNotEmpty) {
                        st.applyFieldErrors(response.fieldErrors!);
                      }
                      anyFieldErrors = true;
                    }
                  }

                  if (mounted && savedCount > 0 && !anyFieldErrors) {
                    await _loadEducationData();

                    showDialog(
                      context: context,
                      builder: (_) => const AddSuccessPopup(
                          message: 'Reference Document Saved Successfully.'
                      ),
                    );

                    widget.onSave();
                  }

                } catch (e) {
                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (_) => const AddFailePopup(
                        message: 'Failed to save reference data.',
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() => isLoading = false);
                  }
                }
              },
            ),
            const SizedBox(
              width: AppSize.s30,
            ),
            FormOutlineButtonConst(
              text: 'Next',
              onPressed: () async {
                await widget.onNext();
              },
            ),
          ],
        ),
      ],
    );
  }
}

class ReferencesForm extends StatefulWidget {
  final int employeeID;
  final VoidCallback onRemove;
  final int index;
  final bool isVisible;
  const ReferencesForm(
      {Key? key,
        required this.onRemove,
        required this.index,
        required this.employeeID,
        required this.isVisible
      })
      : super(key: key);

  @override
  _ReferencesFormState createState() => _ReferencesFormState();
}

class _ReferencesFormState extends State<ReferencesForm> {
  bool isPrefill= true;
  TextEditingController name = TextEditingController();
  TextEditingController titleposition = TextEditingController();
  TextEditingController companyorganization = TextEditingController();
  TextEditingController mobilenumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController knowthisperson = TextEditingController();
  TextEditingController lengthofassociation = TextEditingController();
  int? referenseIndex;
  void initState() {
    super.initState();
    _initializeFormWithPrefilledData();
  }
  Future<void> _initializeFormWithPrefilledData() async {
    try {
      List<ReferenceDataForm> prefilledData = await getEmployeeReferenceForm(context, widget.employeeID);
      if (prefilledData.isNotEmpty) {
        var data = prefilledData[widget.index - 1];
        setState(() {
          name.text = data.name ?? '';
          titleposition.text = data.title ?? '';
          companyorganization.text = data.company ?? '';
          mobilenumber.text = data.mob ?? '';
          email.text = data.email ?? '';
          knowthisperson.text = data.references ?? '';
          lengthofassociation.text = data.association ?? '';
          referenseIndex = data.referenceId ?? 0;
        });
      }

    } catch (e) {
      print('Failed to load prefilled data: $e');
    }
  }

  String? _nameError;
  String? _emailDocError;
  String? _lengthError;
  String? _addressDocError;
  String? _pPhoneDocError;
  String? _positionError;
  String? _OrganizationError;
  String? _KnowthisError;

  bool _isFormValid = true;
  String? _validateTextField(String value, String fieldName) {
    if (value.isEmpty) {
      _isFormValid = false;
      return "Please Enter $fieldName";
    }
    return null;
  }

  void _validateForm() {
    setState(() {
      _isFormValid = true;
      _nameError = _validateTextField(name.text, ' Name');
      _positionError = _validateTextField(titleposition.text, 'Position ');
      _OrganizationError = _validateTextField(companyorganization.text, 'Organization Name');
      _KnowthisError =
          _validateTextField(knowthisperson.text, ' Person Name');
      _pPhoneDocError =
          _validateTextField(mobilenumber.text, 'Phone Number');
      _emailDocError =
          _validateTextField(email.text, 'Email ID');
      _lengthError = _validateTextField(
          lengthofassociation.text, 'Length Of Association');
    });
  }

  void applyFieldErrors(List<ErrorDetail> errors) {
    if (!mounted) return;
    setState(() {
      for (final e in errors) {
        switch (e.key) {
          case 'name':
            _nameError = e.message;
            break;
          case 'title':
            _positionError = e.message;
            break;
          case 'company':
            _OrganizationError = e.message;
            break;
          case 'primaryPhoneNbr':
            _pPhoneDocError = e.message;
            break;
          case 'email':
            _emailDocError = e.message;
            break;
          case 'references':
            _KnowthisError = e.message;
            break;
          case 'association':
            _lengthError = e.message;
            break;
          default:
            break;
        }
      }
    });
  }

  void clearFieldErrors() {
    if (!mounted) return;
    setState(() {
      _nameError = null;
      _positionError = null;
      _OrganizationError = null;
      _pPhoneDocError = null;
      _emailDocError = null;
      _KnowthisError = null;
      _lengthError = null;
    });
  }

  // NEW: shared email regex used for live validation
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'References #${widget.index}' ,
                style:  HeadingFormStyle.customTextStyle(context),
              ),
              if (widget.index > 1)
                IconButton(
                  icon:
                  const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: widget.onRemove,
                ),
            ],
          ),
          const SizedBox(height: AppSizeConst.A20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFieldRegister(
                      header: AppString.name,
                      controller: name,
                      hintText: 'Enter Name',
                      hintStyle: onlyFormDataStyle.customTextStyle(context),
                      height: 32,
                      // UPDATED: live-clear server error once corrected
                      onChanged: (value){
                        setState(() {
                          if(value.isNotEmpty){
                            isPrefill= false;
                            _nameError = null;
                          }
                        });
                      },
                    ),
                    if (_nameError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          _nameError!,
                          style: CommonErrorMsg.customTextStyle(context),
                        ),
                      ),
                    const SizedBox(height: AppSizeConst.A20),
                    CustomTextFieldRegister(
                      header: AppString.title_position,
                      controller: titleposition,
                      hintText: 'Enter Position',
                      hintStyle:onlyFormDataStyle.customTextStyle(context),
                      height: 32,
                      // UPDATED: live-clear server error once corrected
                      onChanged: (value){
                        setState(() {
                          if(value.isNotEmpty){
                            isPrefill= false;
                            _positionError = null;
                          }
                        });
                      },
                    ),
                    if (_positionError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          _positionError!,
                          style: CommonErrorMsg.customTextStyle(context),
                        ),
                      ),
                    const SizedBox(height: AppSizeConst.A20),
                    CustomTextFieldRegister(
                      header: AppString.company_organization,
                      controller: companyorganization,
                      hintText: 'Enter Organization Name',
                      hintStyle: onlyFormDataStyle.customTextStyle(context),
                      height: 32,
                      // UPDATED: live-clear server error once corrected
                      onChanged: (value){
                        setState(() {
                          if(value.isNotEmpty){
                            isPrefill= false;
                            _OrganizationError = null;
                          }
                        });
                      },
                    ),
                    if (_OrganizationError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          _OrganizationError!,
                          style: CommonErrorMsg.customTextStyle(context),
                        ),
                      ),
                    const SizedBox(height: AppSizeConst.A20),
                    Text(
                      AppString.mobile_number,
                      style: AllPopupHeadings.customTextStyle(context),
                    ),
                    const SizedBox(height: AppSize.s5),
                    CustomTextFieldRegisterPhone(
                      controller: mobilenumber,
                      hintText: 'Enter Number',
                      hintStyle:onlyFormDataStyle.customTextStyle(context),
                      height: 32,
                      // UPDATED: live-clear server error once corrected
                      onChanged: (value){
                        setState(() {
                          if(value.isNotEmpty){
                            isPrefill= false;
                            _pPhoneDocError = null;
                          }
                        });
                      },
                    ),
                    if (_pPhoneDocError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          _pPhoneDocError!,
                          style: CommonErrorMsg.customTextStyle(context),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(flex:1,child: Container()),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppString.email,
                      style:AllPopupHeadings.customTextStyle(context),
                    ),
                    const SizedBox(height: AppSize.s5),
                    CustomTextFieldForEmail(
                      controller: email,
                      hintText: 'Enter Email',
                      hintStyle:onlyFormDataStyle.customTextStyle(context),
                      height: 32,
                      // UPDATED: live-validate email so a corrected value
                      // clears the server-driven error immediately
                      onChanged: (value){
                        setState(() {
                          if(value.isNotEmpty){
                            isPrefill= false;
                          }
                          if (value.isEmpty) {
                            _emailDocError = null;
                          } else if (_emailRegex.hasMatch(value)) {
                            _emailDocError = null;
                          } else {
                            _emailDocError = 'Please enter a valid email address.';
                          }
                        });
                      },
                    ),
                    if (_emailDocError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          _emailDocError!,
                          style: CommonErrorMsg.customTextStyle(context),
                        ),
                      ),
                    const SizedBox(height: AppSizeConst.A20),
                    CustomTextFieldRegister(
                      header: AppString.how_do_you_know_this_person,
                      controller: knowthisperson,
                      hintText: 'Enter Text',
                      hintStyle:onlyFormDataStyle.customTextStyle(context),
                      height: 32,
                      // UPDATED: live-clear server error once corrected
                      onChanged: (value){
                        setState(() {
                          if(value.isNotEmpty){
                            isPrefill= false;
                            _KnowthisError = null;
                          }
                        });
                      },
                    ),
                    if (_KnowthisError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          _KnowthisError!,
                          style: CommonErrorMsg.customTextStyle(context),
                        ),
                      ),
                    const SizedBox(height: AppSizeConst.A20),
                    CustomTextFieldRegister(
                      header: AppString.length_of_association,
                      controller: lengthofassociation,
                      hintText: 'Enter Length',
                      hintStyle: onlyFormDataStyle.customTextStyle(context),
                      height: 32,
                      // UPDATED: live-clear server error once corrected
                      onChanged: (value){
                        setState(() {
                          if(value.isNotEmpty){
                            isPrefill= false;
                            _lengthError = null;
                          }
                        });
                      },
                    ),
                    if (_lengthError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          _lengthError!,
                          style: CommonErrorMsg.customTextStyle(context),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizeConst.A20),
          Text(
            'Please ensure that the references you provide are professional contacts who can provide insight into your skills, work ethic and character.',
            style: FileuploadString.customTextStyle(context),
          ),
          const SizedBox(height: AppSizeConst.A20),
          const Divider(
            color: Colors.grey,
            thickness: 2,
          ),
          const SizedBox(height: AppSizeConst.A20),
        ],
      ),
    );
  }
}