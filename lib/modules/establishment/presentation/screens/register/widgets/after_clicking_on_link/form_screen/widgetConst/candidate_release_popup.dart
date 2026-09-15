import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/legal_documents/legal_document_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/legal_document_data/legal_oncall_doc_data.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/google_aotopromt_api_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/text_form_field_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/form_screen_const.dart';

class CandidateReleaseSignPopup extends StatefulWidget {
  final int employeeId;
  final int htmlFormTemplateId;
  final VoidCallback? onSigned;

  const CandidateReleaseSignPopup({super.key, required this.employeeId, required this.htmlFormTemplateId, this.onSigned,});

  @override
  State<CandidateReleaseSignPopup> createState() => _CandidateReleaseSignPopupState();
}

class _CandidateReleaseSignPopupState extends State<CandidateReleaseSignPopup> {

  TextEditingController middleNameController = TextEditingController();
  TextEditingController maidenSurnameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController stateLicenseController = TextEditingController();
  bool loading = false;
  bool _isFormValid = true;
  bool _isSubmitted = false;
  String? middleError;
  String? maidenError;
  String? addressError;
  String? fullNameError;
  String? stateError;

  String? _addressDocError;

  
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
      middleError = _validateTextField(middleNameController.text, 'middle name');
      fullNameError = _validateTextField(fullNameController.text, 'full name');
      stateError = _validateTextField(stateLicenseController.text, 'state name');
      if (middleError != null || fullNameError != null || stateError != null) {
        _isFormValid = false;
      }
    });
  }




  List<String> _suggestions = [];
  @override
  void initState() {
    super.initState();
    addressController.addListener(_onCountyNameChanged);
    middleNameController.addListener(() {
      if (_isSubmitted) {
        setState(() {
          middleError = _validateTextField(middleNameController.text, 'middle name');
        });
      }
    });

    fullNameController.addListener(() {
      if (_isSubmitted) {
        setState(() {
          fullNameError = _validateTextField(fullNameController.text, 'full name');
        });
      }
    });
    stateLicenseController.addListener(() {
      if (_isSubmitted) {
        setState(() {
          stateError = _validateTextField(stateLicenseController.text, 'state name');
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onCountyNameChanged() async {
    if (addressController.text.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }
    final suggestions = await fetchSuggestions(addressController.text);
    if (suggestions[0] == addressController.text) {
      setState(() {
        _suggestions.clear();
      });
    } else if (addressController.text.isEmpty) {
      setState(() {
        _suggestions = suggestions;
      });
    } else {
      setState(() {
        _suggestions = suggestions;
      });
    }
  }





  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: AppSize.s420,
      height: AppSize.s620,
      title: 'Candidate Release Form',
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text( AppStringLegalDocument.popupMsgHead,
                style:  LegalDocumentPopupMessage.customTextStyle(context),),
              const SizedBox(height: AppSize.s20),
              SMTextfieldAsteric(
                controller: fullNameController,
                keyboardType: TextInputType.text,
                text: 'Full Name as it appear on license',
              ),
              fullNameError != null ?
                Text(
                  fullNameError!,
                  style: CommonErrorMsg.customTextStyle(context),
                ) : const SizedBox(height: AppSize.s12,),
              const SizedBox(height: AppSize.s7),
              SMTextfieldAsteric(
                controller: stateLicenseController,
                keyboardType: TextInputType.text,
                text: 'State Issuing License',
              ),
              stateError != null ?
                Text(
                  stateError!,
                  style: CommonErrorMsg.customTextStyle(context),
                ) : const SizedBox(height: AppSize.s12,),
              const SizedBox(height: AppSize.s7),
              SMTextfieldAsteric(
                controller: middleNameController,
                keyboardType: TextInputType.text,
                text: 'Middle Name',
              ),
              middleError != null ? // Display error if any
                Text(
                  middleError!,
                  style: CommonErrorMsg.customTextStyle(context),
                ) : const SizedBox(height: AppSize.s12,),

              const SizedBox(height: AppSize.s7),
              SMTextFConst(
                controller: maidenSurnameController,
                keyboardType: TextInputType.text,
                text: 'Mainden Surname Alisa',
              ),
              const SizedBox(height: AppSize.s10),
              AddressInput(
                controller: addressController,
                onSuggestionSelected: (selectedSuggestion) {
                  // Handle the selected suggestion here
                  print("Selected suggestion: $selectedSuggestion");
                },
                onChanged: (String value) {
                  // Validate when user types in the address field
                  setState(() {
                    if (value.isEmpty) {
                      _addressDocError = 'Address cannot be empty';
                    } else {
                      _addressDocError = null; // Clear error if text is entered
                    }
                  });
                },
              ),
            ],
          ),

        )
      ],
      bottomButtons: CustomElevatedButton(
          width: AppSize.s105,
          height: AppSize.s30,
          text: AppStringEM.submit,
          isLoading: loading,
          onPressed: () async {

            String addressText = addressController.text;
            if (addressText.isEmpty) {
              setState(() {
                _addressDocError = 'Address cannot be empty';
              });
            }else {
              setState(() {
                _addressDocError = null; // Clear any previous error
              });
              // Proceed with form submission or other logic
              print("Address is valid: $addressText");
            }
            setState(() {
              _isSubmitted = true; // Mark form as submitted
              loading = true; // Start loading
            });
            _validateForm();
            if (!_isFormValid) {
              setState(() {
                loading = false;
              });
              return;
            }
            try{
              CandidateRealeaseDocument candidateRealeaseDocument = await getCandidateRealeaseDocument(context: context, employeeId: widget.employeeId,
                  candidateReleaseFormhtmlId: widget.htmlFormTemplateId, middleName: middleNameController.text,
                  maindenSurnameAlisa: maidenSurnameController.text.isEmpty ? AppConfig.dash : maidenSurnameController.text,
                  currentAddress: addressController.text.isEmpty ? AppConfig.dash : addressController.text,
                  stateIssuingLicense: stateLicenseController.text, fullName: fullNameController.text);
              if(candidateRealeaseDocument.statusCode == 200 || candidateRealeaseDocument.statusCode == 201){
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_)=>SignatureFormScreen(
                  isDisable:false,
                  documentName: candidateRealeaseDocument.name,
                  onPressed: () { widget.onSigned?.call(); },
                  htmlFormData: candidateRealeaseDocument.html,
                  employeeId: widget.employeeId,//widget.employeeID,
                  htmlFormTemplateId: candidateRealeaseDocument.candidateRealeaseId,)
                ));
              }
              else if(candidateRealeaseDocument.statusCode == 400 || candidateRealeaseDocument.statusCode == 404){
                showDialog(
                  context: context,
                  builder: (BuildContext context) => const FourNotFourPopup(),
                );
              }
              else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => const FailedPopup(text: "Something Went Wrong"),
                );
              }
            }
            finally {
            setState(() {
              loading = false;
            });
            }
          }
      ),);
  }
}



class AddressInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onSuggestionSelected;
  final Function(String) onChanged;// Callback to notify parent

  const AddressInput({required this.controller, this.onSuggestionSelected, required this.onChanged});

  @override
  _AddressInputState createState() => _AddressInputState();
}

class _AddressInputState extends State<AddressInput> {
  List<String> _suggestions = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onCountyNameChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onCountyNameChanged);
    _removeOverlay();
    super.dispose();
  }

  void _onCountyNameChanged() async {
    final query = widget.controller.text;
    if (query.isEmpty) {
      _suggestions.clear();
      _removeOverlay();
      return;
    }

    final suggestions = await fetchSuggestions(query);
    setState(() {
      _suggestions = suggestions.isNotEmpty && suggestions[0] != query ? suggestions : [];
    });
    _showOverlay();
  }

  void _showOverlay() {
    _removeOverlay();

    if (_suggestions.isEmpty) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
          children:[
            GestureDetector(
              onTap: _removeOverlay,
              child: Container(
                color: Colors.transparent, // Make this transparent so it's invisible
              ),
            ),Positioned(
              left: position.dx,
              top: position.dy + renderBox.size.height,
              width: 354,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: _suggestions.length > 5 ? 80.0 : double.infinity,
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            _suggestions[index],
                            style: TableSubHeading.customTextStyle(context),
                          ),
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            widget.controller.text = _suggestions[index];
                            _suggestions.clear();
                            _removeOverlay();

                            // Call the callback with the selected suggestion
                            if (widget.onSuggestionSelected != null) {
                              widget.onSuggestionSelected!(_suggestions[index]);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ]),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return   SMTextFConst(
      controller:  widget.controller,
      keyboardType: TextInputType.text,
      text: 'Current Address',
    );
  }
}