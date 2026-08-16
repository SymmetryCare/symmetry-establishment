import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/app/resources/common_resources/common_theme_const.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/button_constant.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/text_form_field_const.dart';
import 'package:provider/provider.dart';
import '../../../../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../../../../app/resources/establishment_resources/establishment_string_manager.dart';
import '../../../../../../../app/services/api/managers/establishment_manager/work_schedule_manager.dart';
import '../../../../../../widgets/error_popups/failed_popup.dart';
import '../../../../../../widgets/error_popups/four_not_four_popup.dart';
import '../../../../company_identity/widgets/whitelabelling/success_popup.dart';
import '../../../../widgets/dialogue_template.dart';
///add popup
class AddHolidayProvider with ChangeNotifier {
  TextEditingController holidayNameController = TextEditingController();
  TextEditingController calenderController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  bool isLoading = false;
  String? holidayNameError;
  String? holidayDateError;
  bool isFormValid = true;

  AddHolidayProvider() {
    holidayNameController.addListener(_hideHolidayNameError);
  }

  void _hideHolidayNameError() {
    if (holidayNameController.text.isNotEmpty && holidayNameError != null) {
      holidayNameError = null;
      notifyListeners();
    }
  }

  void validateForm() {
    isFormValid = true;
    holidayNameError = _validateTextField(holidayNameController.text, 'holiday name');
    holidayDateError = _validateTextField(calenderController.text, 'holiday date');
    notifyListeners();
  }

  String? _validateTextField(String value, String fieldName) {
    if (value.isEmpty) {
      isFormValid = false;
      return "Please enter $fieldName";
    }
    return null;
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (date != null) {
      selectedDate = date;
      calenderController.text = DateFormat('yyyy-MM-dd').format(date);
      holidayDateError = null;
      notifyListeners();
    }
  }

  // Future<void> addHoliday(BuildContext context) async {
  //   validateForm();
  //   if (isFormValid) {
  //     isLoading = true;
  //     notifyListeners();
  //
  //     try {
  //       String selectedDate = calenderController.text;
  //       int year = int.parse(selectedDate.split('-')[0]);
  //       var response = await addHolidaysPost(
  //         context,
  //         holidayNameController.text,
  //         calenderController.text,
  //         year,
  //       );
  //
  //       if (response.statusCode == 200 || response.statusCode == 201) {
  //         Navigator.pop(context);
  //         showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return AddSuccessPopup(message: 'Holiday Added Successfully');
  //           },
  //         );
  //       } else if (response.statusCode == 400 || response.statusCode == 404) {
  //         Navigator.pop(context);
  //         showDialog(
  //           context: context,
  //           builder: (BuildContext context) => const FourNotFourPopup(),
  //         );
  //       } else {
  //         Navigator.pop(context);
  //         showDialog(
  //           context: context,
  //           builder: (BuildContext context) => FailedPopup(text: response.message),
  //         );
  //       }
  //     } finally {
  //       isLoading = false;
  //       holidayNameController.clear();
  //       calenderController.clear();
  //       notifyListeners();
  //     }
  //   }
  // }
}

class AddHolidayPopup extends StatelessWidget {
  final VoidCallback? onSave;
  const AddHolidayPopup({Key? key, this.onSave}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddHolidayProvider>(context);

    return DialogueTemplate(
      width: AppSize.s400,
      height: AppSize.s330,
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppPadding.p3,
            horizontal: AppPadding.p15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Holiday Name Field
              SMTextfieldAsteric(
                controller: provider.holidayNameController,
                keyboardType: TextInputType.text,
                text: AddPopupString.holidayName,
              ),
              provider.holidayNameError != null
                  ? Text(
                provider.holidayNameError!,
                style: CommonErrorMsg.customTextStyle(context),
              )
                  : const SizedBox(height: AppSize.s12),
              const SizedBox(height: AppSize.s10),

              // Holiday Date Field
              RichText(
                text: TextSpan(
                  text: AddPopupString.holidayDate,
                  style: AllPopupHeadings.customTextStyle(context),
                  children: [
                    TextSpan(
                      text: ' *',
                      style: AllPopupHeadings.customTextStyle(context).copyWith(
                        color: ColorManager.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppPadding.p4),
                child: SizedBox(
                  width: AppSize.s354,
                  height: AppSize.s30,
                  child: TextFormField(
                    controller: provider.calenderController,
                    style: DocumentTypeDataStyle.customTextStyle(context),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: ColorManager.fmediumgrey, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: ColorManager.fmediumgrey, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'yyyy-mm-dd',
                      hintStyle: DocumentTypeDataStyle.customTextStyle(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(width: 1),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppPadding.p12),
                      suffixIcon: Icon(
                        Icons.calendar_month_outlined,
                        color: ColorManager.blueprime,
                      ),
                    ),
                    readOnly: true,
                    onTap: () => provider.selectDate(context),
                  ),
                ),
              ),
              provider.holidayDateError != null
                  ? Text(
                provider.holidayDateError!,
                style: CommonErrorMsg.customTextStyle(context),
              )
                  : const SizedBox(height: AppSize.s12),
            ],
          ),
        ),
      ],
      bottomButtons: provider.isLoading
          ? SizedBox(
        width: AppSize.s30,
        height: AppSize.s30,
        child: CircularProgressIndicator(
          color: ColorManager.blueprime,
        ),
      )
          : CustomElevatedButton(
        width: AppSize.s120,
        height: AppSize.s30,
        text: AddPopupString.addHoliday,
        onPressed: () async{
          provider.validateForm();
          if (provider.isFormValid) {
            provider.isLoading = true;
            provider.notifyListeners();
            try {
              String selectedDate = provider.calenderController.text;
              int year = int.parse(selectedDate.split('-')[0]);
              var response = await addHolidaysPost(
                context,
                provider.holidayNameController.text,
                provider.calenderController.text,
                year,
              );

              if (response.statusCode == 200 || response.statusCode == 201) {
                if (onSave != null) {
                  onSave!(); // Trigger the callback to refresh the data
                }
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddSuccessPopup(message: 'Holiday Added Successfully');
                  },
                );
              } else if (response.statusCode == 400 || response.statusCode == 404) {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) => const FourNotFourPopup(),
                );
              } else {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) => FailedPopup(text: response.message),
                );
              }
            } finally {
              if (onSave != null) {
                onSave!();
              }
              provider.isLoading = false;
              provider.holidayNameController.clear();
              provider.calenderController.clear();
              provider.notifyListeners();
            }
          }
        },
      ),
      title: AddPopupString.addNewHoliday,
    );
  }
}

class EditHolidayProvider extends ChangeNotifier {
  final TextEditingController nameController;
  final TextEditingController dateController;
  final VoidCallback? onSave;
  bool isLoading = false;
  String? holidayNameError;
  String? holidayDateError;

  EditHolidayProvider({required String holidayName, required String holidayDate,this.onSave, })
      : nameController = TextEditingController(text: holidayName),
        dateController = TextEditingController(text: holidayDate);

  void clearErrors() {
    holidayNameError = null;
    holidayDateError = null;
    notifyListeners();
  }

  void validateInputs() {
    if (nameController.text.isEmpty) {
      holidayNameError = 'Please enter holiday name';
    } else {
      holidayNameError = null;
    }

    if (dateController.text.isEmpty) {
      holidayDateError = 'Please select a holiday date';
    } else {
      holidayDateError = null;
    }
    notifyListeners();
  }

  Future<void> updateHoliday(BuildContext context, int holidayId) async {
    validateInputs();

    if (holidayNameError == null && holidayDateError == null) {
      isLoading = true;
      notifyListeners();

      try {
        // Mock API call logic
        var response = await updateHolidays(
          context,
          holidayId,
          nameController.text,
          dateController.text,
          2024,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (onSave != null) {
            onSave!();
          }
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddSuccessPopup(
                message: 'Holiday Edited Successfully',
              );
            },
          );
        } else if (response.statusCode == 400 || response.statusCode == 404) {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) => const FourNotFourPopup(),
          );
        } else {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) =>
                FailedPopup(text: response.message),
          );
        }

        // Clear controllers
        nameController.clear();
        dateController.clear();
      } finally {
        if (onSave != null) {
          onSave!();
        }
        isLoading = false;
        notifyListeners();
      }
    }
  }
}

class EditHolidayPopup extends StatelessWidget {
  final int holidayId;
  final String holidayName;
  final String holidayDate;
  final VoidCallback? onSave;

  const EditHolidayPopup({
    Key? key,
    required this.holidayId,
    required this.holidayName,
    required this.holidayDate, this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditHolidayProvider(
        holidayName: holidayName,
        holidayDate: holidayDate,
      ),
      child: Consumer<EditHolidayProvider>(
        builder: (context, provider, _) {
          return DialogueTemplate(
            width: AppSize.s400,
            height: AppSize.s330,
            body: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppPadding.p3,
                  horizontal: AppPadding.p15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Holiday Name Field
                    SMTextfieldAsteric(
                      controller: provider.nameController,
                      keyboardType: TextInputType.text,
                      text: AddPopupString.holidayName,
                      onChange: provider.clearErrors,
                    ),
                   provider.holidayNameError != null ?
                      Text(
                        provider.holidayNameError!,
                        style: CommonErrorMsg.customTextStyle(context),
                      ): SizedBox(height: AppSize.s12,),
                    SizedBox(height: AppSize.s10),
                    RichText(
                      text: TextSpan(
                        text: AddPopupString.holidayDate,
                        style: AllPopupHeadings.customTextStyle(context),
                        children: [
                          TextSpan(
                            text: ' *',
                            style: AllPopupHeadings.customTextStyle(context)
                                .copyWith(color: ColorManager.red),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSize.s5),
                    SizedBox(
                      width: AppSize.s354,
                      height: AppSize.s30,
                      child: TextFormField(
                        controller: provider.dateController,
                        style: DocumentTypeDataStyle.customTextStyle(context),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: ColorManager.fmediumgrey, width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: ColorManager.fmediumgrey, width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: 'yyyy-mm-dd',
                          hintStyle:
                          DocumentTypeDataStyle.customTextStyle(context),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(width: 1),
                          ),
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 12),
                          suffixIcon: Icon(Icons.calendar_month_outlined,
                              color: ColorManager.blueprime),
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2101),
                          );
                          if (date != null) {
                            provider.dateController.text =
                                DateFormat('yyyy-MM-dd').format(date);
                            provider.clearErrors();
                          }
                        },
                      ),
                    ),
                    provider.holidayDateError != null ?
                      Text(
                        provider.holidayDateError!,
                        style: CommonErrorMsg.customTextStyle(context),
                      ): SizedBox(height: AppSize.s12,),
                  ],
                ),
              ),
            ],
            bottomButtons: provider.isLoading
                ? SizedBox(
              width: AppSize.s30,
              height: AppSize.s30,
              child: CircularProgressIndicator(
                color: ColorManager.blueprime,
              ),
            )
                : CustomElevatedButton(
              width: AppSize.s130,
              height: AppSize.s30,
              text: AppStringEM.save,
              onPressed: () {
                provider.updateHoliday(context, holidayId);
                if (onSave != null) {
                  onSave!();
                }
              },
            ),
            title: EditPopupString.editholiday,
          );
        },
      ),
    );
  }
}
