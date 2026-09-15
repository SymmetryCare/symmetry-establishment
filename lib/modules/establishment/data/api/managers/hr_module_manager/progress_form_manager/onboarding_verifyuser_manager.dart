import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/form_repository/form_general_repo.dart';



Future<ApiData> postverifyuser(
    BuildContext context,
    String email,
    ) async {
  /// Backends return the error message under different keys and shapes —
  /// this checks the common ones.
  String? _extractBackendMessage(dynamic data) {
    if (data == null) return null;
    if (data is String && data.isNotEmpty) return data;
    if (data is Map) {
      final msg = data['message'] ?? data['error'] ?? data['msg'] ?? data['detail'];
      if (msg is String && msg.isNotEmpty) return msg;
      // some backends send {"message": ["error1", "error2"]}
      if (msg is List && msg.isNotEmpty) return msg.join(', ');
    }
    return null;
  }

  /// Show the failure dialog safely (checks the widget is still mounted)
  void _showErrorDialog(String errorMessage) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) => FailedPopup(text: errorMessage),
      );
    }
  }

  try {
    var response = await Api(context).post(
      path: ProgressBarRepository.postverifyuser(),
      data: {"email": email},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      // orgDocumentGet(context);
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage ?? "Success");
    } else {
      final String errorMessage =
          _extractBackendMessage(response.data) ?? AppString.somethingWentWrong;

      _showErrorDialog(errorMessage);

      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: errorMessage);
    }
  } on DioException catch (e) {
    // ── backend responded with an error status (400/401/404/500 etc.)
    print("DioException: ${e.response?.statusCode} ${e.response?.data}");
    final String errorMessage =
        _extractBackendMessage(e.response?.data) ?? AppString.somethingWentWrong;

    _showErrorDialog(errorMessage);

    return ApiData(
      statusCode: e.response?.statusCode ?? 500,
      success: false,
      message: errorMessage,
    );
  } catch (e) {
    // ── anything else (no internet, timeout, unexpected)
    print("Error $e");

    _showErrorDialog(AppString.somethingWentWrong);

    return ApiData(
        statusCode: 500, success: false, message: AppString.somethingWentWrong);
  }
}

