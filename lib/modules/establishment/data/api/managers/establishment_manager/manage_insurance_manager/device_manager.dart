import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/device_data.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/device_repo.dart';

// ── GET — Inventory by Company ─────────────────────────────────────────────────
Future<List<InventoryData>> getInventoryList(BuildContext context) async {
  List<InventoryData> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
      path: InventoryRepository.getByCompanyId(companyId: companyId),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
          InventoryData(
            inventoryId:  item['inventoryId'],
            name:         item['name'],
            qty:          item['qty'],
            description:  item['description'],
            companyId:    item['companyId'],
            sku:          item['sku'],
            price:        item['price'],
            expiryDate:   item['expiryDate'],
            fk_categoryId: item['fk_categoryId'],
            categoryName: item['categoryName'],   // map if API returns it
          ),
        );
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

// ── POST — Add Inventory ───────────────────────────────────────────────────────
Future<ApiData> addInventory(
    BuildContext context,
    String name,
    int qty,
    String description,
    // String sku,
    // num price,
    // String expiryDate,
    int categoryId,
    ) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await Api(context).post(
      path: InventoryRepository.add,
      data: {
        "name":         name,
        "qty":          qty,
        "description":  description,
        "companyId":    companyId,
        // "sku":          sku,
        // "price":        price,
        // "expiryDate":   expiryDate,
        "fk_categoryId": categoryId,
      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Inventory added");
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
      );
    } else {
      print("Error 1");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'],
      );
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}

// ── PATCH — Update Inventory ───────────────────────────────────────────────────
Future<ApiData> updateInventory(
    BuildContext context,
    int inventoryId,
    String name,
    int qty,
    String description,
    // String sku,
    // num price,
    // String expiryDate,
    int categoryId,
    ) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await Api(context).patch(
      path: InventoryRepository.update(inventoryId: inventoryId),
      data: {
        "name":         name,
        "qty":          qty,
        "description":  description,
        "companyId":    companyId,
        // "sku":          sku,
        // "price":        price,
        // "expiryDate":   expiryDate,
        "fk_categoryId": categoryId,
      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Inventory updated");
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
      );
    } else {
      print("Error 1");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'],
      );
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}

// ── DELETE — Delete Inventory ──────────────────────────────────────────────────
Future<ApiData> deleteInventory(
    BuildContext context,
    int inventoryId,
    ) async {
  try {
    var response = await Api(context).delete(
      path: InventoryRepository.delete(inventoryId: inventoryId),
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Inventory deleted");
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
      );
    } else {
      print("Error 1");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'],
      );
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}

// ── GET — Supply Order Categories ─────────────────────────────────────────────
Future<List<SupplyOrderCategoryData>> getSupplyOrderCategories(BuildContext context) async {
  List<SupplyOrderCategoryData> itemsList = [];
  try {
    final response = await Api(context).get(
      path: SupplyOrderRepository.getCategories,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
          SupplyOrderCategoryData(
            categoryId:   item['categoryId'],
            categoryName: item['categoryName'],
          ),
        );
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}