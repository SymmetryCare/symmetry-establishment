import 'dart:async';
import 'dart:html' as html;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/modules/establishment/providers/hr_register_provider.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/new_widget_const/forms_blue_header_const.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/form_education_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/download_doc_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/constant_textfield/const_textfield.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/add_employee/clinical_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/uploadData_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/qualification_bar_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/add_employee/clinical.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/onboarding_data/onboarding_qualification_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/progress_form_data/form_education_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/radio_button_tile_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/taxtfield_constant.dart';
import 'dart:typed_data';

class EducationScreen extends StatefulWidget {
  final int employeeID;
  final Function onSave;
  final Function onBack;
  final Function onNext;
  const EducationScreen({
    super.key,
    required this.context,
    required this.employeeID, required this.onSave, required this.onBack, required this.onNext,
  });

  final BuildContext context;

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  List<GlobalKey<_EducationFormState>> educationFormKeys = [];
  bool isVisible = false;
  double textFieldWidth = 430;
  double textFieldHeight = 38;

  // Current step in the stepper
  int _currentStep = 0;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEducationData();
  }

  Future<void> _loadEducationData() async {
    try {
      List<EducationDataForm> prefilledData = await getEmployeeEducationForm(context, widget.employeeID);

      if (!mounted) return;

      if (prefilledData.isEmpty) {
        addEducationForm(); // Assumes this method uses setState safely inside
      } else {
        if (!mounted) return;
        setState(() {
          educationFormKeys = List.generate(
            prefilledData.length,
                (index) => GlobalKey<_EducationFormState>(),
          );
        });

        final providerState = Provider.of<HrProgressMultiStape>(context, listen: false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            providerState.isEducationChnaged();
          }
        });
      }
    } catch (e) {
      print('Error loading Education data: $e');
    }
  }


  Future<void> processEducationForms() async {
    bool skipFinally = false;
    if (!mounted) return;

    setState(() => isLoading = true);

    int savedCount = 0;
    int totalToSave = 0;
    bool anyError = false;
    String? lastErrorMessage;

    try {
      for (var key in educationFormKeys) {
        final st = key.currentState;
        if (st == null || st.isPrefill) continue;

        totalToSave++;

        try {
          if (st.finalPath != null &&
              st.finalPath!.isNotEmpty &&
              st.fileAbove20Mb) {
            if (mounted) {
              showDialog(
                context: context,
                builder: (_) => const AddErrorPopup(message: 'File is too large!'),
              );
              setState(() => isLoading = false);
            }
            skipFinally = true;
            return;
          }

          final selectedDegreeValue =
          (st.selectedDegree == 'Select') ? '--' : st.selectedDegree.toString();

          final response = await posteducationscreen(
            context,
            st.widget.employeeID,
            st.graduatetype.toString(),
            selectedDegreeValue,
            st.majorsubject.text,
            st.city.text,
            st.collegeuniversity.text,
            st.phone.text,
            st.state.text,
            "USA",
            "2024-08-09",
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            savedCount++;

            if (st.fileName != null) {
              await uploadEducationDocument(
                context,
                response.educationIdr!,
                st.finalPath,
                st.fileName!,
              );
            }
          } else {
            // NEW: capture the server's real message instead of silently continuing
            anyError = true;
            lastErrorMessage = response.message;
          }
        } catch (e) {
          print("Error processing an education form entry: $e");
          anyError = true;
          lastErrorMessage = AppString.somethingWentWrong;
        }
      }

      if (!mounted) return;

      // NEW: only refresh + show success + allow onSave() when every
      // changed form actually saved with no errors
      if (savedCount > 0 && !anyError && savedCount == totalToSave) {
        await _loadEducationData();

        showDialog(
          context: context,
          builder: (_) => const AddSuccessPopup(
            message: 'Education Document Saved Successfully.',
          ),
        );
      } else if (anyError) {
        // NEW: surface the actual server message
        showDialog(
          context: context,
          builder: (_) => AddErrorPopup(
            message: lastErrorMessage ?? AppString.somethingWentWrong,
          ),
        );
      }

    } finally {
      if (!skipFinally && mounted) {
        setState(() => isLoading = false);

        // UPDATED: onSave() now only fires when there was no error at all —
        // previously this ran unconditionally on every path
        if (savedCount > 0 && !anyError && savedCount == totalToSave) {
          widget.onSave();
        }
      }
    }
  }



  void addEducationForm() {
    setState(() {
      educationFormKeys.add(GlobalKey<_EducationFormState>( ));
    });
  }

  void removeEduacationForm(GlobalKey<_EducationFormState> key) {
    setState(() {
      educationFormKeys.remove(key);
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
          children: educationFormKeys.asMap().entries.map((entry) {
            int index = entry.key;
            GlobalKey<_EducationFormState> key = entry.value;
            return EducationForm(
              key: key,
              index: index + 1,
              onRemove: () => removeEduacationForm(key),
              employeeID: widget.employeeID, isVisible: isVisible,
            );
          }).toList(),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 150),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isVisible = true;
                    addEducationForm();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff50B5E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                    'Add Education',
                    style: BlueButtonTextConst.customTextStyle(context)
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
              onPressed: () {
                widget.onBack();
              },
            ),
            const SizedBox(
              width: 30,
            ),

            FormSaveButtonConst(
              isLoading: isLoading,
              onPressed: () async {
                if (!mounted) return;
                await processEducationForms();
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

class EducationForm extends StatefulWidget {
  final int employeeID;
  final VoidCallback onRemove;
  final int index;
  final bool isVisible;

  const EducationForm(
      {Key? key,
        required this.onRemove,
        required this.index,
        required this.employeeID, required this.isVisible, })
      : super(key: key);

  @override
  _EducationFormState createState() => _EducationFormState();
}

class _EducationFormState extends State<EducationForm> {
  bool isPrefill= true;
  TextEditingController collegeuniversity = TextEditingController();
  TextEditingController majorsubject = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController state = TextEditingController();

  List<String> _fileNames = [];
  bool _loading = false;
  Uint8List? finalPath;
  String? fileName;
  int? educationIndex;
  int selectedDegreeId = 0;

  String? graduatetype='Yes';
  String? selectedDegree ='Select';
  String? docName;
  String? docUrl;

  final StreamController<List<AEClinicalDiscipline>> Degreestream =
  StreamController<List<AEClinicalDiscipline>>();

  bool fileAbove20Mb = false;

  // ── Cached future — prevents refetch/rebuild loop on every build ──
  late Future<List<EduactionDegree>> _degreeDropDownFuture;

  void initState() {
    super.initState();
    HrAddEmplyClinicalDisciplinApi(context, 1).then((data) {
      Degreestream.add(data);
    }).catchError((error) {});
    _initializeFormWithPrefilledData();
    _degreeDropDownFuture = getDegreeDropDown(context);
  }

  Future<void> _initializeFormWithPrefilledData() async {
    try {
      List<EducationDataForm> prefilledData = await getEmployeeEducationForm(context, widget.employeeID);
      if (prefilledData.isNotEmpty) {
        var data = prefilledData[widget.index - 1]; // Assuming index matches the data list
        setState(() {
          collegeuniversity.text = data.college ?? '';
          majorsubject.text = data.major ?? '';
          phone.text = data.phone ?? '';
          city.text = data.city ?? '';
          state.text = data.state ?? '';
          graduatetype = data.graduate ?? '';
        selectedDegree = (data.degree == '--' || data.degree == null) ? 'Select' : data.degree ?? '';
          educationIndex = data.educationID ?? 0;
          docName = data.docName ?? "--";
          docUrl = data.docUrl ?? '';

        });
      }
    } catch (e) {
      print('Failed to load prefilled data: $e');
    }
  }

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
                'Education #${widget.index}',
                style: HeadingFormStyle.customTextStyle(context),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFieldRegister(
                      header: 'College/University',
                      controller: collegeuniversity,
                      hintText: 'Enter College/University Name',
                      hintStyle: onlyFormDataStyle.customTextStyle(context),
                      height: 32,
                    ),
                    const SizedBox(height: AppSizeConst.A20),
                    Text(
                      'Graduate',
                      style: AllPopupHeadings.customTextStyle(context),
                    ),
                    StatefulBuilder(
                      builder: (BuildContext context, void Function(void Function()) setState) {
                        return Padding(
                          padding:  const EdgeInsets.only(right:200),
                          child: Row(
                            children: [
                              Expanded(
                                  child: CustomRadioListTile(
                                    title: 'Yes',
                                    value: 'Yes',
                                    groupValue: graduatetype,
                                    onChanged: (value) {
                                      setState(() {
                                        graduatetype = value;
                                        isPrefill =false;
                                      });
                                    },
                                  )),
                              Expanded(
                                child: CustomRadioListTile(
                                  title: 'No',
                                  value: 'No',
                                  groupValue: graduatetype,
                                  onChanged: (value) {
                                    setState(() {
                                      graduatetype = value;
                                      isPrefill =false;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSizeConst.A20),
                    CustomTextFieldRegister(
                      header: 'Major Subject',
                      controller: majorsubject,
                      hintText: 'Enter Subject',
                      hintStyle:onlyFormDataStyle.customTextStyle(context),
                      height: 32,
                      onChanged: (value){
                        if(value.isNotEmpty){
                          isPrefill= false;
                        }
                      },
                    ),
                    const SizedBox(height: AppSizeConst.A20),
                    Text(
                      'Degree',
                      style:AllPopupHeadings.customTextStyle(context),
                    ),
                    const SizedBox(height: AppSize.s5),
                    StatefulBuilder(
                      builder: (BuildContext context, void Function(void Function()) setState) { return Container(
                        height: 32,
                        child: buildDropdownButton(context),
                      );  },

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
                      'Phone ',
                      style: AllPopupHeadings.customTextStyle(context),
                    ),
                    const SizedBox(height: AppSize.s5),
                    CustomTextFieldRegisterPhone(
                      controller: phone,
                      hintText: 'Enter Phone Number',
                      hintStyle: onlyFormDataStyle.customTextStyle(context),
                      height: 32,
                      onChanged: (value){
                        if(value.isNotEmpty){
                          isPrefill= false;
                        }
                      },
                    ),
                    const SizedBox(height: AppSizeConst.A20),
                    CustomTextFieldRegister(
                      header: 'City',
                      controller: city,
                      hintText: 'Enter City',
                      hintStyle:onlyFormDataStyle.customTextStyle(context),
                      height: 32,
                      onChanged: (value){
                        if(value.isNotEmpty){
                          isPrefill= false;
                        }
                      },
                    ),
                    const SizedBox(height: AppSizeConst.A20),
                    CustomTextFieldRegister(
                      header: 'State',
                      controller: state,
                      hintText: 'Enter State',
                      hintStyle: onlyFormDataStyle.customTextStyle(context),
                      height: 32,
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
          const SizedBox(height: AppSizeConst.A20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Upload your degree / certifications as a pdf.',
                  style: FileuploadString.customTextStyle(context),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width / 20),
              StatefulBuilder(
                builder: (BuildContext context, void Function(void Function()) setState) { return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                        onPressed: ()async {
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
                        icon: docName == "--" ? const Icon(Icons.upload, color: Colors.white):null,
                        label:docName == null ?Text(
                          'Upload File',
                          style: BlueButtonTextConst.customTextStyle(context),
                        ):Text(
                          'Uploaded',
                          style: BlueButtonTextConst.customTextStyle(context),
                        )
                    ),
                    const SizedBox(height: 8,),
                    docName != null
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Uploaded File: ', style: onlyFormDataStyle.customTextStyle(context)),
                        InkWell(
                          onTap: (docUrl == null || docUrl!.isEmpty) ? null : () async {
                            // Previously submitted (prefilled) file: download it.
                            await downloadFile(
                              context: context,
                              fileUrl: docUrl!,
                              documentName: docName!,
                              apiPath: DownloadDocumentRepository.getDocumentByFileName(),
                            );
                          },
                          child: AutoSizeText(
                            docName!,
                            style: onlyFormDataStyle.customTextStyle(context).copyWith(
                              decoration: (docUrl == null || docUrl!.isEmpty) ? null : TextDecoration.underline,
                              color: (docUrl == null || docUrl!.isEmpty) ? null : const Color(0xff50B5E5),
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
                );  },

              ),
              SizedBox(height: MediaQuery.of(context).size.height / 20),
            ],
          ),
          const SizedBox(height: AppSizeConst.A20),
          const Divider(
            color: Colors.grey,
            thickness: 2,
          ),
          const SizedBox(height: AppSizeConst.A20),

          ///upload document/ Display file names if picked
        ],
      ),
    );
  }

  Widget buildDropdownButton(BuildContext context) {
    // Store prefilled degree value (you can initialize it with null or fetch it dynamically)
    return FutureBuilder<List<EduactionDegree>>(
      future: _degreeDropDownFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 30,
            padding: const EdgeInsets.only(bottom: 3, top: 5, left: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(),
                  child: Text(
                    selectedDegree!,
                    style: DocumentTypeDataStyle.customTextStyle(context),
                  ),
                ),
                const Icon(Icons.arrow_drop_down_sharp, color: Colors.grey),
              ],
            ),

          );
        } else if (snapshot.hasError) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
         child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '',
                style: DocumentTypeDataStyle.customTextStyle(context),
              ),
              const Icon(Icons.arrow_drop_down_sharp, color: Colors.grey),
            ],
          ),

          );
        } else if (snapshot.hasData) {
          List<DropdownMenuItem<String>> dropDownList = [];
          int degreeID = 0;

          // Populate the dropdown list from the fetched data
          for (var i in snapshot.data!) {
            dropDownList.add(DropdownMenuItem<String>(
              child: Text(i.degree),
              value: i.degree,
            ));
          }

          // If prefilledDegree is set, use it for the value of the dropdown
          String initialValue = selectedDegree ?? "Select";

          return StatefulBuilder(
            builder: (BuildContext context, void Function(void Function()) setState) {

              return CustomDropdownTextFieldwidh(
                menuMaxHeight: 150,
                dropDownMenuList: dropDownList,
                onChanged: (newValue) {
                  isPrefill = false;
                  for (var a in snapshot.data!) {
                    if (a.degree == newValue) {
                      selectedDegree = a.degree;
                      degreeID = a.degreeId;
                      selectedDegreeId = degreeID;
                      print("Degree :: ${selectedDegree}");
                    }
                  }
                },
                hintText: initialValue,
                height: 31,
              );
            },
          );
        } else {
          return CustomDropdownTextField(
            headText: 'Degree',
            items: const ['No Data'],
          );
        }
      },
    );
  }
}

