import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/app/services/api/repository/calling/callingApi_repo.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';

Future<ApiData> addRegisterDevice({
  required BuildContext context,
  required int userId,
  required String fcmToken,
  required String deviceType,
  required String deviceName,
}) => _deviceRequest(
  context: context,
  path: CallingRepo.postRegisterDevice(),
  data: {
    'userId': userId,
    'fcmToken': fcmToken,
    'deviceType': deviceType,
    'deviceName': deviceName,
  },
);

Future<ApiData> unRegisterDevice({
  required BuildContext context,
  required String fcmToken,
}) => _deviceRequest(
  context: context,
  path: CallingRepo.postUnRegisterDevice(),
  data: {'fcmToken': fcmToken},
);

Future<ApiData> _deviceRequest({
  required BuildContext context,
  required String path,
  required Map<String, dynamic> data,
}) async {
  try {
    final response = await Api(context).post(path: path, data: data);
    final statusCode = response.statusCode ?? 500;
    final success = statusCode == 200 || statusCode == 201;
    return ApiData(
      statusCode: statusCode,
      success: success,
      message: success
          ? response.statusMessage ?? 'Success'
          : response.data?['message']?.toString() ?? 'Request failed',
      data: response.data,
    );
  } catch (_) {
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}
