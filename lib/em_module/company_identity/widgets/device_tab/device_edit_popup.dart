import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import '../../../../../../app/resources/common_resources/common_theme_const.dart';
import '../../../../../../app/resources/establishment_resources/establishment_string_manager.dart';
import '../../../../../../app/services/api/managers/establishment_manager/manage_insurance_manager/device_manager.dart';
import '../../../../../../data/api_data/establishment_data/company_identity/device_data.dart';
import '../../../widgets/button_constant.dart';
import '../../../widgets/dialogue_template.dart';
import '../../../widgets/text_form_field_const.dart';
import '../ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';
import '../whitelabelling/success_popup.dart';

class EditInventoryPopup extends StatefulWidget {
  final InventoryData device;
  final VoidCallback onSuccess;
  const EditInventoryPopup({
    super.key,
    required this.device,
    required this.onSuccess,
  });

  @override
  State<EditInventoryPopup> createState() => _EditInventoryPopupState();
}

class _EditInventoryPopupState extends State<EditInventoryPopup> {
  late final TextEditingController _deviceNameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _descriptionController;

  late Future<List<SupplyOrderCategoryData>> _categoriesFuture;

  bool isLoading = false;
  String? deviceNameError;
  String? quantityError;
  String? categoryError;

  String? selectedCategory;
  int?    selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _categoriesFuture      = getSupplyOrderCategories(context);
    _deviceNameController  = TextEditingController(text: widget.device.name);
    _quantityController    = TextEditingController(text: widget.device.qty.toString());
    _descriptionController = TextEditingController(text: widget.device.description);

    selectedCategoryId = widget.device.fk_categoryId;
    selectedCategory   = widget.device.categoryName;

    _deviceNameController.addListener(() {
      if (_deviceNameController.text.isNotEmpty && deviceNameError != null) {
        setState(() => deviceNameError = null);
      }
    });
    _quantityController.addListener(() {
      if (_quantityController.text.isNotEmpty && quantityError != null) {
        setState(() => quantityError = null);
      }
    });
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    setState(() {
      deviceNameError = _deviceNameController.text.trim().isEmpty
          ? 'Device name cannot be empty' : null;
      quantityError = _quantityController.text.trim().isEmpty
          ? 'Quantity cannot be empty' : null;
      categoryError = selectedCategory == null
          ? 'Please select a category' : null;
    });
    return deviceNameError == null &&
        quantityError == null &&
        categoryError == null;
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      title: 'Edit Device',
      width: AppSize.s407,
      height: AppSize.s480,
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              // ── Device Name ──────────────────────────────────────────
              SMTextfieldAsteric(
                controller: _deviceNameController,
                keyboardType: TextInputType.text,
                text: 'Device Name',
              ),
              deviceNameError != null
                  ? Text(deviceNameError!, style: CommonErrorMsg.customTextStyle(context))
                  : const SizedBox(height: AppSize.s12),
              const SizedBox(height: AppSize.s10),

              // ── Quantity ─────────────────────────────────────────────
              SMTextfieldAsteric(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                text: 'Quantity',
              ),
              quantityError != null
                  ? Text(quantityError!, style: CommonErrorMsg.customTextStyle(context))
                  : const SizedBox(height: AppSize.s12),
              const SizedBox(height: AppSize.s10),

              // ── Description ──────────────────────────────────────────
              SMTextfieldAsteric(
                controller: _descriptionController,
                keyboardType: TextInputType.text,
                text: 'Description',
              ),
              const SizedBox(height: AppSize.s10),

              // ── Category Dropdown ─────────────────────────────────────
              RichText(
                text: TextSpan(
                  text: 'Category',
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
              const SizedBox(height: 5),
              FutureBuilder<List<SupplyOrderCategoryData>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {

                  // ── loading ──
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      width: 350, height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              selectedCategory ?? ' ',
                              style: AllPopupHeadings.customTextStyle(context),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: AppPadding.p8),
                            child: Icon(Icons.arrow_drop_down),
                          ),
                        ],
                      ),
                    );
                  }

                  // ── empty ──
                  if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return Container(
                      width: 350, height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFB1B1B1), width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        child: Text('No categories available',
                            style: AllPopupHeadings.customTextStyle(context)),
                      ),
                    );
                  }

                  // ── data ready ──
                  if (snapshot.hasData) {
                    // resolve selectedCategory from fk_categoryId if still null
                    if (selectedCategory == null && widget.device.fk_categoryId != null) {
                      final match = snapshot.data!.firstWhere(
                            (c) => c.categoryId == widget.device.fk_categoryId,
                        orElse: () => SupplyOrderCategoryData(categoryId: -1, categoryName: ''),
                      );
                      if (match.categoryId != -1) {
                        selectedCategory   = match.categoryName;
                        selectedCategoryId = match.categoryId;
                      }
                    }

                    List<DropdownMenuItem<String>> dropDownMenuItems = [];
                    for (var i in snapshot.data!) {
                      dropDownMenuItems.add(DropdownMenuItem<String>(
                        value: i.categoryName,
                        child: Text(i.categoryName),
                      ));
                    }

                    return CICCDropdown(
                      initialValue: selectedCategory,
                      onChange: (val) {
                        for (var a in snapshot.data!) {
                          if (a.categoryName == val) {
                            setState(() {
                              selectedCategory   = val;
                              selectedCategoryId = a.categoryId;
                              categoryError      = null;
                            });
                          }
                        }
                      },
                      items: dropDownMenuItems,
                    );
                  }

                  return const SizedBox();
                },
              ),
              categoryError != null
                  ? Text(categoryError!, style: CommonErrorMsg.customTextStyle(context))
                  : const SizedBox(height: AppSize.s4),
            ],
          ),
        ),
      ],
      bottomButtons: isLoading
          ? SizedBox(
        width: AppSize.s30, height: AppSize.s30,
        child: CircularProgressIndicator(color: ColorManager.blueprime),
      )
          : CustomElevatedButton(
        width: AppSize.s105,
        height: AppSize.s30,
        text: AppStringEM.save,
        onPressed: () async {
          if (_validateFields()) {
            setState(() => isLoading = true);
            final result = await updateInventory(
              context,
              widget.device.inventoryId,
              _deviceNameController.text.trim(),
              int.tryParse(_quantityController.text.trim()) ?? 0,
              _descriptionController.text.trim(),
              selectedCategoryId!,
            );
            setState(() => isLoading = false);
            if (result.success) {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddSuccessPopup(
                    message: 'Device Updated Successfully',
                  );
                },
              );
              widget.onSuccess();
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddErrorPopup(
                    message: result.message.isNotEmpty
                        ? result.message
                        : 'Failed to update device',
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}