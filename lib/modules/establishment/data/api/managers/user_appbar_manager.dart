
import 'package:flutter/cupertino.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/user/user_appbar.dart';

import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/establishment_repository.dart';

Future<UserAppBar> getAppBarDetails(BuildContext context) async {
  var itemsList;
  try{
    final companyId = await TokenManager.getCompanyId();
    final loginUserId = await TokenManager.getuserId();
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.userPrefillGet(userId: loginUserId));
    if(response.statusCode == 200 || response.statusCode == 201){
      itemsList = UserAppBar(
          userId: response.data['userId'] ?? 0,
          firstName: response.data['firstName']?? "",
          lastName: response.data['lastName']?? "",
          departmentId: response.data['departmentId'] ?? 0,
          department: response.data['department']?? "",
          email: response.data['email']?? "",
          companyId: companyId,
          password: response.data['password']?? "",
          status: response.data['status'] ?? "",
          employeeId: response.data['employeeId'] ?? 0,
          imgUrl: response.data['imgUrl']?? "");
      print("User Data for Appbar : $itemsList");
    }
    else{
      print("User Data for Appbar error");
    }
    return itemsList;
  }
  catch(e){
    print("Error $e");
    return itemsList;
  }
}
