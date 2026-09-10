import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/profile_repo.dart';

import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/gender_data.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';

///get hrTab
Future<List<GenderData>> getGenderDropdown(BuildContext context) async {
  List<GenderData> itemsList = [];
  try {
    final response = await Api(context)
        .get(path: ProfileRepository.getGender());
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("ResponseList:::::${itemsList}");
      for (var item in response.data) {
        itemsList.add(
            GenderData(
                genderId: item['genderId'],
                gender: item['gender'],
            )
        );
      }
    } else {
      print('Api Error');
    }
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

Future<List<RaceModelData>> getRaceDropdown(BuildContext context) async {
  List<RaceModelData> itemsList = [];
  try {
    final response = await Api(context)
        .get(path: ProfileRepository.getrace());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
            RaceModelData(
              raceId: item['raceId']??0,
              raceName: item['race']??'',
            )
        );
      }
    } else {
      print('Api Error');
    }
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}
