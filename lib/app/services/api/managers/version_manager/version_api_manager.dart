import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/app/services/api/repository/version/version_repo.dart';
import 'package:symmetry_establishment/data/api_data/version/version_model_data.dart';

///get Employee API
Future<VersionData> getApplicationVersion(
  BuildContext context,
) async {
  var itemsList;
  try {
    final response =
        await Api(context).get(path: VersionRepository.getVersion());
    if (response.statusCode == 200 || response.statusCode == 201) {
      itemsList = VersionData(
          id: response.data['id'],
          versionName: response.data['versionName'] ?? "--",
          lastUpdated: response.data['lastUpdated'] ?? "--");
      print("Response:::::${response}");
    } else {
      print('Version Api Error');
    }
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}
