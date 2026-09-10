import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/manage_emp/manage_emp_repo.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/equipment_data.dart';

/// Get equipment
Future<List<EquipmentData>> getEquipement(
    BuildContext context,
    int employeeId,
    ) async {
  List<EquipmentData> itemsList = [];
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('MM/dd/yyyy');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }
  try {
    final response = await Api(context).get(
      path: ManageReposotory.getEquipement(employeeId: employeeId),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
          EquipmentData(
            employeeInventoryId: item['employeeInventoryId'] ?? 0,
            inventoryId: item['inventoryId'] ?? 0,
            assignedDate: item['assignedDate'] != null ? convertIsoToDayMonthYear(item['assignedDate']) : '' ,
            employeeId: item['employeeId'] ?? 0,
            givenId: item['givenId'] ?? '',
            inventoryTypeId: item['inventoryTypeId'] ?? '',
            name: item['name'] ?? '',
            fkCategoryId: item['fk_categoryId'] ?? 0,
            categoryName: item['categoryName'] ?? '',
            description: item['description'] ?? '',
            inventoryStatus: item['inventoryStatus'] ?? '',
          ),
        );
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } on DioException catch (e) {
    // e.response != null proves the server actually responded (4xx/5xx) —
    // print its real message instead of a silent generic failure.
    print("Error ${e.response?.data['message'] ?? e.message}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}




/// Get dropdown inventory
Future<List<InventoryDropdownData>> getDropdownInventory(
    BuildContext context) async {
  List<InventoryDropdownData> itemsData = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response =
    await Api(context).get(path: ManageReposotory.gerDropdownInventory(companyId: companyId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(InventoryDropdownData(
            inventoryId: item['inventoryId'],
            name: item['name'],
            qty: item['qty'],
            description: item['description'],
            companyId: item['companyId']));
      }
    } else {
      print("Equipment");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Equipement prefill data get
Future<EquipmentPrefillData> getPrefillEquipement(
    BuildContext context, int employeeId) async {
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('MM-dd-yyyy');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }

  var itemsData;
  try {
    final response =
    await Api(context).get(path: ManageReposotory.getEquipement(employeeId: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      String assignedFormattedDate =
      convertIsoToDayMonthYear(response.data['assignedDate']);
      itemsData =
          EquipmentPrefillData(
              empInventoryId: response.data['employeeInventoryId'],
              inventoryId: response.data['inventoryId'],
              assignedDate: assignedFormattedDate,
              employeeId: response.data['employeeId'],
              givenId: response.data['givenId'],
              inventoryTypeId: response.data['inventoryTypeId'],
              name: response.data['name'],
              createdAt: response.data['createdAt'] ?? "--");

    } else {
      print("Equipment prefill");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// add equipment
Future<ApiData> addEquipment(
    BuildContext context,
    int inventoryId,
    String assignedDate,
    int empId,
    String givenId,
    String inventoryTypeId,
    String name,
    int fkCategoryId,
    ) async {
  try {
    var response = await Api(context).post(
      path: ManageReposotory.addEquipement(),
      data: {
        "inventoryId": inventoryId,
        "assignedDate": "${assignedDate}T00:00:00Z",
        "employeeId": empId,
        "givenId": givenId,
        "inventoryTypeId": inventoryTypeId,
        "name": name,
        "fk_categoryId": fkCategoryId,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Equipment added");
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

/// Patch equipment
Future<ApiData> updateEquipmentStatusPatch(
    BuildContext context,
    int empInventoryId,
    int empId,
    String inventoryStatus,
    ) async {
  try {
    var response = await Api(context).patch(
      path: ManageReposotory.patchEquipement(empInventoryId: empInventoryId),
      data: {
        "employeeId": empId,
        "inventoryStatus": inventoryStatus,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Equipment status updated");
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}