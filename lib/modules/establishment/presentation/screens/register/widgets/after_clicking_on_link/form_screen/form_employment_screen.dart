import 'dart:html' as html;
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:symmetry_establishment/modules/establishment/providers/hr_register_provider.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/form_employment_manager.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/download_doc_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/new_widget_const/forms_blue_header_const.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/employeement_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/uploadData_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/progress_form_data/form_employment_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/widgets/acknowledgement_add_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/taxtfield_constant.dart';

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/form_employment_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/progress_form_data/form_employment_data.dart';
import 'dart:convert';

import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/taxtfield_constant.dart';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EmploymentScreen extends StatefulWidget {
  final int employeeID;
  final BuildContext context;
  final Function onSave;
  final Function onNext;
  final Function onBack;

  const EmploymentScreen({
    super.key,
    required this.employeeID,
    required this.context, required this.onSave, required this.onBack,
    required this.onNext,
  });

  @override
  State<EmploymentScreen> createState() => _EmploymentScreenState();
}

class _EmploymentScreenState extends State<EmploymentScreen> {
  List<GlobalKey<_EmploymentFormState>> employmentFormKeys = [];
  List<EmploymentDataForm> prefilledData = [];
  bool isVisible = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEmploymentData();
  }

  Future<void> _loadEmploymentData() async {
    try {
      List<EmploymentDataForm> data = await getEmployeeHistoryForm(context, widget.employeeID);

      if (data.isEmpty) {
        setState(() {
          addEmploymentForm();
        });
      } else {
        setState(() {
          prefilledData = data;
          employmentFormKeys = List.generate(
            prefilledData.length,
                (index) => GlobalKey<_EmploymentFormState>(),
          );
          final providerState = Provider.of<HrProgressMultiStape>(context,listen: false);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            providerState.isEmployeementChnaged();
          });
        });
      }
    } catch (e) {
      print('Error loading employment data: $e');
    }
  }

  void addEmploymentForm() {
    setState(() {
      employmentFormKeys.add(GlobalKey<_EmploymentFormState>());
    });
  }

  void removeEmploymentForm(GlobalKey<_EmploymentFormState> key) {
    setState(() {
      employmentFormKeys.remove(key);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 150),
          child: FormsBlueHeaderConst(
            text: 'Your personal details will be required to proceed through the recruitment process.',
          ),
        ),
        const SizedBox(height: AppSizeConst.A20),
        Column(
          children: employmentFormKeys.asMap().entries.map((entry) {
            int index = entry.key;
            GlobalKey<_EmploymentFormState> key = entry.value;
            return EmploymentForm(
              key: key,
              index: index + 1,
              onRemove: () => removeEmploymentForm(key),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.blueprime,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                    'Add Experience',
                    style:BlueButtonTextConst.customTextStyle(context)
                ),
                onPressed: () {
                  setState(() {
                    isVisible = true;
                    addEmploymentForm();
                  });
                },
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
                setState(() {
                  isLoading = true;
                });

                int savedCount = 0;
                int totalToSave = 0;
                bool anyError = false;
                String? lastErrorMessage;

                try {
                  for (var key in employmentFormKeys) {
                    final state = key.currentState!;
                    if (state.isPrefill == false) {
                      totalToSave++;
                      try {
                        var response = await postemploymentscreenData(
                          context,
                          state.widget.employeeID,
                          state.employerController.text,
                          state.cityController.text,
                          state.reasonForLeavingController.text,
                          state.supervisorNameController.text,
                          state.supervisorMobileNumberController.text,
                          state.finalPositionController.text,
                          state.startDateController.text,
                          state.isChecked ? "Currently Working" : state.endDateController.text,
                          "NA",
                          "United States Of America",
                        );

                        if (response.statusCode == 200 || response.statusCode == 201) {
                          savedCount++;

                          if (state.fileName != null) {
                            await uploadEmployeeResume(
                              context: context,
                              employeementId: response.employeeMentId!,
                              documentFile: state.finalPath!,
                              documentName: state.fileName!,
                            );
                          }
                        } else {
                          anyError = true;
                          lastErrorMessage = response.message;
                        }
                      } on DioException catch (e) {
                        final msg = e.response?.data is Map
                            ? (e.response?.data['message']?.toString() ??
                            AppString.somethingWentWrong)
                            : AppString.somethingWentWrong;
                        print("DioException in form entry: ${e.response?.statusCode} -> $msg");
                        anyError = true;
                        lastErrorMessage = msg;
                      } catch (e) {
                        print("Error processing a form entry: $e");
                        anyError = true;
                        lastErrorMessage = AppString.somethingWentWrong;
                      }
                    }
                  }

                  if (!mounted) return;

                  if (savedCount > 0 && !anyError && savedCount == totalToSave) {
                    await _loadEmploymentData();

                    showDialog(
                      context: context,
                      builder: (_) => const AddSuccessPopup(
                        message: 'Employment Document Saved Successfully.',
                      ),
                    );

                    widget.onSave();
                  } else if (anyError) {
                    showDialog(
                      context: context,
                      builder: (_) => AddErrorPopup(
                        message: lastErrorMessage ?? AppString.somethingWentWrong,
                      ),
                    );
                  }

                } on DioException catch (e) {
                  print("Unexpected DioException during save: ${e.response?.statusCode}");
                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (_) => const AddErrorPopup(
                        message: AppString.somethingWentWrong,
                      ),
                    );
                  }
                } catch (e) {
                  print("Unexpected error during save: $e");
                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (_) => const AddErrorPopup(
                        message: AppString.somethingWentWrong,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      isLoading = false;
                    });
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



class EmploymentForm extends StatefulWidget {
  final int employeeID;
  final VoidCallback onRemove;
  final int index;
  final bool isVisible;
  const EmploymentForm({
    Key? key,
    required this.onRemove,
    required this.index,
    required this.employeeID,
    required this.isVisible,
  }) : super(key: key);

  @override
  _EmploymentFormState createState() => _EmploymentFormState();
}

class _EmploymentFormState extends State<EmploymentForm> {

  bool isPrefill= true;
  TextEditingController employerController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController reasonForLeavingController = TextEditingController();
  TextEditingController supervisorNameController = TextEditingController();
  TextEditingController supervisorMobileNumberController = TextEditingController();
  TextEditingController finalPositionController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  bool isChecked = false;

  List<String> _fileNames = [];
  bool _loading = false;
  Uint8List? finalPath;
  String? fileName;
  int? employementIndex;
  String? docName;
  String? docurl;


  bool fileAbove20Mb = false;

  @override
  void initState() {
    super.initState();
    _initializeFormWithPrefilledData();
  }

  Future<void> _initializeFormWithPrefilledData() async {
    try {
      List<EmploymentDataForm> prefilledData = await getEmployeeHistoryForm(context, widget.employeeID);
      if (prefilledData.isNotEmpty) {
        var data = prefilledData[widget.index - 1];
        setState(() {
          employerController.text = data.employer ?? '';
          cityController.text = data.city ?? '';
          reasonForLeavingController.text = data.reason ?? '';
          supervisorNameController.text = data.supervisor ?? '';
          supervisorMobileNumberController.text = data.supMobile ?? '';
          finalPositionController.text = data.title ?? '';
          startDateController.text = data.dateOfJoining ?? '';
          endDateController.text = data.endDate;
          if (data.endDate == 'Currently Working') {
            isChecked = true;
          }
          else {
            isChecked = false;
          }

          employementIndex = data.employmentId ?? 0;
          docName = data.documentName;
          docurl = data.documentUrl;

        });
      }
    } catch (e) {
      print('Failed to load prefilled data: $e');
    }
  }

  Future<void> _handleFileUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    final fileSize = result?.files.first.size;

    if (fileSize != null) {
      final isAbove20MB = fileSize > (20 * 1024 * 1024);

      if (isAbove20MB) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AddErrorPopup(
              message: 'File is too large!',
            );
          },
        );
      } else {
        if (result != null) {
          final file = result.files.first;
          setState(() {
            fileName = file.name;
            finalPath = file.bytes;
            fileAbove20Mb = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Employment #${widget.index}',
                style:  HeadingFormStyle.customTextStyle(context),
              ),
              if (widget.index > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: widget.onRemove,
                ),
            ],
          ),
          const SizedBox(height: AppSizeConst.A20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFieldRegister(
                      header: 'Final Position Title',
                      controller: finalPositionController,
                      hintText: 'Enter Title',
                      hintStyle:onlyFormDataStyle.customTextStyle(context),
                      height: 32.0,
                      onChanged: (value){
                        if(value.isNotEmpty){
                          isPrefill= false;
                        }
                      },
                    ),
                    const SizedBox(height: AppSizeConst.A20),
                    CustomTextFieldRegister(
                      header: 'Employer',
                      controller: employerController,
                      hintText: 'Enter Text',
                      hintStyle:onlyFormDataStyle.customTextStyle(context),
                      height: 32.0,
                      onChanged: (value){
                        if(value.isNotEmpty){
                          isPrefill= false;
                        }
                      },
                    ),
                    const SizedBox(height: AppSizeConst.A20),
                    CustomTextFieldRegister(
                      header: 'Start Date',
                      onTap:  () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(3100),
                        );
                        if (pickedDate != null) {
                          startDateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                        }
                      },
                      readOnly: true,
                      controller: startDateController,
                      hintText: 'yyyy-mm-dd',
                      hintStyle:onlyFormDataStyle.customTextStyle(context),
                      height: 32.0,
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
                    const SizedBox(height: AppSizeConst.A20),
                    CustomTextFieldRegister(
                      header: 'End Date',
                      headerStyle: isChecked ? AllPopupHeadings.customTextStyle(context).copyWith(color: Colors.grey) : AllPopupHeadings.customTextStyle(context),
                      readOnly: true,
                      enabled: !isChecked,
                      onTap: isChecked ? null : () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(3100),
                        );
                        if (pickedDate != null) {
                          endDateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                        }
                      },
                      controller: endDateController,
                      hintText: 'yyyy-mm-dd',
                      hintStyle: isChecked ?   onlyFormDataStyle.customTextStyle(context).copyWith(color: Colors.grey):onlyFormDataStyle.customTextStyle(context),
                      height: 32.0,
                      onChanged: (value){
                        if(value.isNotEmpty){
                          isPrefill= false;
                        }
                      },
                      suffixIcon: Icon(
                        Icons.calendar_month_outlined,
                        color: isChecked ? Colors.grey : const Color(0xff50B5E5),
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: AppSizeConst.A20),
                    Row(
                      children: [
                        Checkbox(
                          splashRadius: 0,
                          activeColor: const Color(0xff50B5E5),
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = value!;
                              if (isChecked) {
                                endDateController.clear();
                                isPrefill =false;
                              }
                            });
                          },
                        ),
                        Text(
                          'Currently work here',
                          style: onlyFormDataStyle.customTextStyle(context),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
              Expanded(flex: 1,child: Container()),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFieldRegister(
                      header: 'Reason For Leaving',
                      controller: reasonForLeavingController,
                      hintText: 'Enter Leaving Reason',
                      hintStyle:onlyFormDataStyle.customTextStyle(context),
                      height: 32.0,
                      onChanged: (value){
                        if(value.isNotEmpty){
                          isPrefill= false;
                        }
                      },
                    ),
                    const SizedBox(height: AppSizeConst.A20),
                    CustomTextFieldRegister(
                      header: "Last Supervisor’s Name",
                      controller: supervisorNameController,
                      hintText: 'Enter Supervisor’s Name',
                      hintStyle:onlyFormDataStyle.customTextStyle(context),
                      height: 32.0,
                      onChanged: (value){
                        if(value.isNotEmpty){
                          isPrefill= false;
                        }
                      },
                    ),
                    const SizedBox(height: AppSizeConst.A20),
                    Text(
                      'Supervisor’s Mobile Number',
                      style:AllPopupHeadings.customTextStyle(context),
                    ),
                    const SizedBox(height: AppSize.s5),
                    CustomTextFieldRegisterPhone(
                      controller: supervisorMobileNumberController,
                      hintText: 'Enter Mobile Number',
                      hintStyle: onlyFormDataStyle.customTextStyle(context),
                      height: 32.0,
                      onChanged: (value){
                        if(value.isNotEmpty){
                          isPrefill= false;
                        }
                      },
                    ),
                    const SizedBox(height: AppSizeConst.A20),
                    CustomTextFieldRegister(
                      header: 'City',
                      controller: cityController,
                      hintText: 'Enter City',
                      hintStyle: onlyFormDataStyle.customTextStyle(context),
                      height: 32.0,
                      onChanged: (value){
                        if(value.isNotEmpty){
                          isPrefill= false;
                        }
                      },
                    ),
                  ],
                ),
              ),

            ],
          ),
          if (isChecked) ...[
            const SizedBox(height: AppSize.s15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Upload your resume as a pdf with a maximum size of 2 mb.',
                    style: FileuploadString.customTextStyle(context),
                  ),
                ),

                StatefulBuilder(
                  builder: (BuildContext context, void Function(void Function()) setState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _handleFileUpload,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff50B5E5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          icon: docName == "--" ? const Icon(Icons.upload, color: Colors.white) : null,
                          label: docName == null
                              ? Text('Upload File', style: BlueButtonTextConst.customTextStyle(context))
                              : Text('Uploaded', style: BlueButtonTextConst.customTextStyle(context)),
                        ),
                        const SizedBox(height: AppSize.s5),
                        docName != null
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Uploaded File: ', style: onlyFormDataStyle.customTextStyle(context)),
                            InkWell(
                              onTap: () async {
                                if (docurl != null && docurl!.isNotEmpty) {
                                  downloadFile(context: context,
                                      fileUrl: docurl!,
                                      documentName:docName!,
                                      apiPath: DownloadDocumentRepository.getEmployeeEmploymentHistoriesDocumentByFileName());
                                  // final uri = Uri.parse(docurl!);
                                  // await launchUrl(uri, webOnlyWindowName: '_blank');
                                }
                              },
                              child: AutoSizeText(
                                docName!,
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
                                  final blob = html.Blob([finalPath!], 'application/pdf');
                                  final url = html.Url.createObjectUrlFromBlob(blob);
                                  html.window.open(url, '_blank');
                                }
                              },
                              child: AutoSizeText(
                                fileName!,
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
                    );
                  },
                ),
              ],
            ),
          ],
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