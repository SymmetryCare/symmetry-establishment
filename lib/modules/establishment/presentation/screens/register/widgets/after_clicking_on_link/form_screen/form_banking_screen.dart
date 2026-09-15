import 'dart:core';
import 'dart:html' as html;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';


import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/form_banking_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/download_doc_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/new_widget_const/forms_blue_header_const.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/providers/hr_register_provider.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/uploadData_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/progress_form_data/form_banking_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/radio_button_tile_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/taxtfield_constant.dart';

// NEW: model used to read the per-field server validation errors

class BankingScreen extends StatefulWidget {
  final int employeeID;
  final Function onSave;
  final Function onBack;
  final Function onNext;

  const BankingScreen({
    super.key,
    required this.context,
    required this.employeeID, required this.onSave, required this.onBack, required this.onNext,
  });

  final BuildContext context;

  @override
  State<BankingScreen> createState() => _BankingScreenState();
}

class _BankingScreenState extends State<BankingScreen> {
  List<GlobalKey<BankingFormState>> bankingFormKeys = [];
  bool isVisible = false;
  var validateAccounts;



  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBankingData();
  }

  Future<void> _loadBankingData() async {
    try {
      List<BankingDataForm> prefilledData = await getBankingForm(context, widget.employeeID);
      if (!mounted) return; // ⬅️ Add this line before setState
      if(prefilledData.isEmpty){
        addBankingForm();
      }
      else{
        setState(() {
          bankingFormKeys = List.generate(
            prefilledData.length,
                (index) => GlobalKey<BankingFormState>(),
          );
        });
        final providerState = Provider.of<HrProgressMultiStape>(context,listen: false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted)  providerState.isBankingChnaged();
        });
      }
    } catch (e) {
      print('Error loading Banking data: $e');
    }
  }

  void addBankingForm() {
    setState(() {
      bankingFormKeys.add(GlobalKey<BankingFormState>());
    });
  }

  void removeBankingForm(GlobalKey<BankingFormState> key) {
    setState(() {
      bankingFormKeys.remove(key);
    });
  }

  Future<void> perfFormBanckingData({
    required BuildContext context,
    required int employeeId,
    required String accountNumber,
    required String bankName,
    required int amountRequested,
    required String checkUrl,
    required String effectiveDate,
    required String routingNumber,
    required String type,
    required String requestedPercentage,
    required dynamic documentFile,
    required String documentName,
  }) async {
    try {
      ApiDataRegister response = await postbankingscreenData(
          context,
          employeeId,
          accountNumber,
          bankName,
          amountRequested,
          checkUrl,
          effectiveDate,
          routingNumber,
          type,
          requestedPercentage);


      await uploadcheck(
          context: context,
          employeeid: employeeId,
          empBankingId: response.banckingId!,
          documentFile: documentFile,
          documentName: documentName);
      print('BanckingId :::::: ${response.banckingId!}');

      if(response.statusCode == 200 || response.statusCode == 201){
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AddSuccessPopup(
              message: 'Banking Document Saved',
            );
          },
        );

        await  _loadBankingData();
      }
      else{
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AddFailePopup(
              message: 'Failed To Save Banking Document',
            );
          },
        );
      }
    } catch (e) {
      await showDialog(
        context: context,
        builder: (BuildContext context) => const FourNotFourPopup(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HRBankingProvider>(context);
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.p150),
          child: FormsBlueHeaderConst(
            text: 'Your personal details will be required to proceed through the recruitment process.',
          ),
        ),
        const SizedBox(height: AppSizeConst.A20),        Column(
          children: bankingFormKeys.asMap().entries.map((entry) {
            int index = entry.key;
            GlobalKey<BankingFormState> key = entry.value;
            return BankingForm(
              key: key,
              index: index + 1,
              onRemove: () => removeBankingForm(key),
              employeeID: widget.employeeID, isVisible: isVisible,
            );
          }).toList(),
        ),
        Padding(
          padding: const EdgeInsets.only(left: AppPadding.p150),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: addBankingForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff50B5E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Add Bank Details',
                  style:BlueButtonTextConst.customTextStyle(context),
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
              isLoading: provider.isLoading,
              onPressed: () async {
                for (var key in bankingFormKeys) {
                  key.currentState?.clearFieldErrors();
                }

                final result = await provider.saveBankingDetails(
                  bankingFormKeys: bankingFormKeys,
                  employeeId: widget.employeeID,
                  context: context,
                );

                if (!mounted) return;

                // UPDATED: only refresh + show success when there were zero failures
                if (result.saved > 0 && result.failed == 0) {
                  await _loadBankingData();
                  await showDialog(
                    context: context,
                    builder: (_) => const AddSuccessPopup(
                      message: 'Banking Document Saved Successfully.',
                    ),
                  );

                  // UPDATED: onSave() now only fires on a fully clean save —
                  // previously this ran unconditionally at the bottom regardless
                  // of result.failed
                  widget.onSave();
                }

                if (result.failed > 0) {
                  // UPDATED: show the actual server message instead of a generic count
                  await showDialog(
                    context: context,
                    builder: (_) => AddErrorPopup(
                      message: result.lastErrorMessage ?? AppString.somethingWentWrong,
                    ),
                  );
                }
                // No navigation happens when result.failed > 0
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

class BankingForm extends StatefulWidget {
  final int employeeID;
  final VoidCallback onRemove;
  final int index;
  final bool isVisible;
  const BankingForm(
      {super.key,
        required this.onRemove,
        required this.index,
        required this.employeeID, required this.isVisible});

  @override
  BankingFormState createState() => BankingFormState();
}

class BankingFormState extends State<BankingForm> {
  @override
  void initState() {
    super.initState();
    // Add listeners to controllers
    accountnumber.addListener(validateAccounts);
    verifyaccountnumber.addListener(validateAccounts);
    _initializeFormWithPrefilledData();
  }

  @override
  void dispose() {
    // Dispose controllers when widget is removed
    accountnumber.dispose();
    verifyaccountnumber.dispose();
    super.dispose();
  }
  bool isPrefill= true;

  TextEditingController effectivecontroller = TextEditingController();
  TextEditingController requestammount = TextEditingController();
  TextEditingController accountnumber = TextEditingController();
  TextEditingController routingnumber = TextEditingController();
  TextEditingController bankname = TextEditingController();
  TextEditingController verifyaccountnumber = TextEditingController();

  String? selectedtype ='Checking';

  String? selectedacc;
  int? bankingId;
  String? checkUrl;
  String? checkFullUrl;

  List<String> _fileNames = [];
  bool _loading = false;

  bool fileAbove20Mb = false;

  // ---------------------------------------------------------------------
  // NEW: per-field error strings driven by the server's `key` values
  // (matching the POST body field names sent to postbankingscreenData)
  // ---------------------------------------------------------------------
  String? _accountNumberError;
  String? _bankNameError;
  String? _amountRequestedError;
  String? _effectiveDateError;
  String? _routingNumberError;
  String? _typeError;
  String? _requestedPercentageError;

  /// Maps the server's [ErrorDetail.key] values onto this specific
  /// banking form's error variables. Public (no leading underscore) so
  /// the parent/provider can call it via the GlobalKey's currentState.
  void applyFieldErrors(List<ErrorDetail> errors) {
    if (!mounted) return;
    setState(() {
      for (final e in errors) {
        switch (e.key) {
          case 'accountNumber':
            _accountNumberError = e.message;
            break;
          case 'bankName':
            _bankNameError = e.message;
            break;
          case 'amountRequested':
            _amountRequestedError = e.message;
            break;
          case 'effectiveDate':
            _effectiveDateError = e.message;
            break;
          case 'routingNumber':
            _routingNumberError = e.message;
            break;
          case 'type':
            _typeError = e.message;
            break;
          case 'requestedPercentage':
            _requestedPercentageError = e.message;
            break;
          default:
          // Unmapped key — the toast/dialog message already shown covers it.
            break;
        }
      }
    });
  }

  /// Clears all server-driven field errors on this form. Call before a
  /// fresh submit so stale errors from a previous attempt don't linger.
  void clearFieldErrors() {
    if (!mounted) return;
    setState(() {
      _accountNumberError = null;
      _bankNameError = null;
      _amountRequestedError = null;
      _effectiveDateError = null;
      _routingNumberError = null;
      _typeError = null;
      _requestedPercentageError = null;
    });
  }

  Future<void> _initializeFormWithPrefilledData() async {
    try {
      List<BankingDataForm> prefilledData = await getBankingForm(context, widget.employeeID);
      if (prefilledData.isNotEmpty) {
        var data = prefilledData[widget.index - 1]; // Assuming index matches the data list
        setState(() {
          effectivecontroller.text = data.effectiveDate ?? '';
          requestammount.text = data.amountRequested.toString() ?? "";
          accountnumber.text = data.accountNumber ?? '';
          routingnumber.text = data.routingNumber ?? '';
          bankname.text = data.bankName ?? '';
          verifyaccountnumber.text = data.accountNumber ?? '';
          selectedtype = data.type ?? '';
          checkUrl = data.checkUrl.split('/').last;
          checkFullUrl = data.checkUrl;
          bankingId = data.empBankingId ?? 0;

        });
      }
    } catch (e) {
      print('Failed to load prefilled data: $e');
    }
  }


  bool _documentUploaded = true;
  var fileName;
  var fileName1;
  dynamic filePath;
  File? xfileToFile;
  var finalPath;

  String? errorMessage;

  void validateAccounts() {
    setState(() {
      if (accountnumber.text != verifyaccountnumber.text) {
        errorMessage = 'Account numbers do not match';
      } else {
        errorMessage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bank Details #${widget.index}',
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
                      header: 'Effective Date',
                      onTap: () async {
                        DateTime? pickedDate =
                        await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          effectivecontroller.text =
                          "${pickedDate.toLocal()}"
                              .split(' ')[0];
                        }
                      },
                      readOnly: true,
                      isDigitSelect: true,
                      controller: effectivecontroller,
                      hintText: 'yyyy-mm-dd',
                      hintStyle: onlyFormDataStyle.customTextStyle(context),
                      height: 32,
                      onChanged: (value){
                        if(value.isNotEmpty){
                          isPrefill= false;
                        }
                      },
                      suffixIcon: const Icon(
                        Icons.calendar_month_outlined,
                        color: Color(0xff50B5E5),
                        size: 22,
                      ),


                    ),
                    // NEW: server-driven error for Effective Date
                    if (_effectiveDateError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _effectiveDateError!,
                          style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                        ),
                      ),
                    const SizedBox(height: AppSizeConst.A20),
                    CustomTextFieldRegister(
                      header: 'Bank Name',
                      controller: bankname,
                      hintText: 'Enter Bank Name',
                      hintStyle:onlyFormDataStyle.customTextStyle(context),
                      height: 32,
                      onChanged: (value){
                        if(value.isNotEmpty){
                          isPrefill= false;
                        }
                      },
                    ),
                    // NEW: server-driven error for Bank Name
                    if (_bankNameError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _bankNameError!,
                          style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                        ),
                      ),
                    const SizedBox(height: AppSizeConst.A20),
                    Text(
                      'Routing/Transit Number ( 9 Digits )',
                      style:AllPopupHeadings.customTextStyle(context),
                    ),
                    const SizedBox(height: AppSize.s5),
                    CustomTextFieldSSn(
                      keyboardType: TextInputType.number,
                      maxLength: 9,
                      controller: routingnumber,
                      hintText: 'Enter Number',
                      hintStyle:onlyFormDataStyle.customTextStyle(context),
                      height: 32,
                      // UPDATED: live-clear the routing number error once 9 digits are typed
                      onChanged: (value){
                        setState(() {
                          if(value.isNotEmpty){
                            isPrefill= false;
                          }
                          if (value.length == 9 || value.isEmpty) {
                            // NEW: complete (9 digits) or empty — clear any stale error
                            _routingNumberError = null;
                          } else {
                            _routingNumberError = 'Routing number must be exactly 9 digits';
                          }
                        });
                      },
                    ),
// NEW: server-driven error for Routing Number
                    if (_routingNumberError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _routingNumberError!,
                          style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                        ),
                      ),
                    const SizedBox(height: AppSizeConst.A20),
                    Text(
                      'Type',
                      style: AllPopupHeadings.customTextStyle(context),
                    ),
                    const SizedBox(height: AppSize.s5),
                    Row(
                      children: [
                        Expanded(
                            child: CustomRadioListTile(
                              title: 'Checking',
                              value: 'Checking',
                              groupValue: selectedtype,
                              onChanged: (value) {
                                setState(() {
                                  selectedtype = value;
                                  isPrefill= false;
                                });
                              },
                            )),
                        Expanded(
                          child: CustomRadioListTile(
                            title: 'Savings',
                            value: 'Savings',
                            groupValue: selectedtype,
                            onChanged: (value) {
                              setState(() {
                                selectedtype = value;
                                isPrefill= false;
                              });
                            },
                          ),
                        ),
                      ],
                    ).paddingOnly(right: 170),
                    // NEW: server-driven error for Type
                    if (_typeError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _typeError!,
                          style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(flex: 1,child: Container()),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requested amount for this account (select one)',
                      style: AllPopupHeadings.customTextStyle(context),
                    ),
                    const SizedBox(height: AppSize.s5),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: requestammount,   // listens only to this controller
                      builder: (context, textValue, _) {
                        return CustomTextFieldRegister(
                          keyboardType: TextInputType.number,
                          isDigitSelect: true,
                          hintText: 'Enter Requested amount',
                          controller: requestammount,
                          prefixText: textValue.text.isNotEmpty ? '\$ ' : '',
                          height: 32,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              isPrefill = false;
                            }
                            // no setState needed
                          },
                        );
                      },
                    ),
                    // NEW: server-driven error for Requested Amount
                    if (_amountRequestedError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _amountRequestedError!,
                          style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                        ),
                      ),
                    // NEW: server-driven error for Requested Percentage
                    // (shown near the amount field since there's no
                    // dedicated percentage input in this form)
                    if (_requestedPercentageError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _requestedPercentageError!,
                          style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                        ),
                      ),
                    const SizedBox(height: AppSizeConst.A20),
                    CustomTextFieldRegister(
                      header: 'Account Number ',
                      keyboardType: TextInputType.number,
                      isDigitSelect: true,
                      controller: accountnumber,
                      hintText: 'Enter AC Number',
                      hintStyle: onlyFormDataStyle.customTextStyle(context),
                      height: 32,
                      onChanged: (value){
                        if(value.isNotEmpty){
                          isPrefill= false;
                        }
                      },
                    ),
                    // NEW: server-driven error for Account Number
                    if (_accountNumberError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _accountNumberError!,
                          style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                        ),
                      ),
                    const SizedBox(height: AppSizeConst.A20),
                    CustomTextFieldRegister(
                      header: 'Verify Account Number',
                      keyboardType: TextInputType.number,
                      isDigitSelect: true,
                      controller: verifyaccountnumber,
                      hintText: 'Enter AC Number',
                      hintStyle: onlyFormDataStyle.customTextStyle(context),
                      height: 32,
                      onChanged: (value){
                        if(value.isNotEmpty){
                          isPrefill= false;
                        }
                      },
                    ),
                    errorMessage != null ?
                    Padding(
                      padding: const EdgeInsets.only(top:1),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                            color: Colors.red, fontSize: 10),
                      ),
                    ) : const SizedBox(height:13),

                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizeConst.A20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Upload your void check.',
                  style:  FileuploadString.customTextStyle(context),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                      onPressed: ()async{
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf']
                        );
                        final fileSize = result?.files.first.size; // File size in bytes
                        if (fileSize != null) {
                          final isAbove20MB = fileSize > (20 * 1024 * 1024); // Check if file is larger than 20MB

                          if (isAbove20MB) {
                            // If the file is larger than 20MB, show an error message
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const AddErrorPopup(
                                  message: 'File is too large!',
                                );
                              },
                            );
                          } else {
                            // If the file is less than 20MB, proceed with the upload process
                            if (result != null) {
                              final file = result.files.first;
                              setState(() {
                                fileName = file.name;
                                finalPath = file.bytes;
                                fileAbove20Mb = false; // This flag indicates that the file is below 20MB
                              });
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff50B5E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),

                      ),
                      icon: checkUrl == "--" ? const Icon(Icons.upload, color: Colors.white):null,
                      label:checkUrl == null ?Text(
                        'Upload File',
                        style:BlueButtonTextConst.customTextStyle(context),
                      ):Text(
                        'Uploaded',
                        style: BlueButtonTextConst.customTextStyle(context),
                      )
                  ),
                  const SizedBox(height: 8,),
                  checkUrl != null
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Uploaded File: ', style: onlyFormDataStyle.customTextStyle(context)),
                      InkWell(
                        onTap: () async {
                          if (checkFullUrl != null && checkFullUrl!.isNotEmpty) {
                            // Previously submitted (prefilled) file: download it.
                            await downloadFile(
                              context: context,
                              fileUrl: checkFullUrl!,
                              documentName: checkUrl!,
                              apiPath: DownloadDocumentRepository.getEmployeeBankingsDocumentByFileName(),
                            );
                          }
                        },
                        child: AutoSizeText(
                          checkUrl!,
                          style: onlyFormDataStyle.customTextStyle(context).copyWith(
                            decoration: TextDecoration.underline,
                            color: const Color(0xff50B5E5),
                          ),
                        ),
                      ),
                    ],
                  )
                      : fileName != null
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('File picked: ', style: onlyFormDataStyle.customTextStyle(context)),
                      InkWell(
                        onTap: () {
                          if (finalPath != null) {
                            final blob = html.Blob([finalPath], 'application/pdf');
                            final url = html.Url.createObjectUrlFromBlob(blob);
                            html.window.open(url, '_blank');
                          }
                        },
                        child: AutoSizeText(
                          '$fileName',
                          style: onlyFormDataStyle.customTextStyle(context).copyWith(
                            decoration: TextDecoration.underline,
                            color: const Color(0xff50B5E5),
                          ),
                        ),
                      ),
                    ],
                  )
                      : const SizedBox(),
                ],
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.height /
                      20), // Display file names if picked
            ],
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