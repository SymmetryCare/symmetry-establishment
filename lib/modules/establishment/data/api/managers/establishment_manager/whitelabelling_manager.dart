

import 'package:flutter/cupertino.dart';
import 'package:symmetry_establishment/app/services/base64/encode_decode_base64.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';

import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/whitelabelling_modal/whitelabelling_modal_.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/establishment_repository.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/org_doc_ccd.dart';


///post
Future<ApiData> postWhitelabellingAdd(
    BuildContext context,
    String officeId,
    String primaryNo,
    String secondaryNo,
    String primFax,
    String secondaryFax,
    String alternativeNo,
    String email,
    String name,
    String address,

    ) async{
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await Api(context).post(
        path: EstablishmentManagerRepository.
        postCompanyOffice(),
        data: {
          "company_id": companyId,
          "office_id": officeId,
          "primary_phone": primaryNo,
          "secondary_phone": secondaryNo,
          "primary_fax": primFax,
          "secondary_fax": secondaryFax,
          "alternative_phone":alternativeNo,
          "email": email,
          "name": name,
          "address": address,
        });
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Updated request");
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
    print("Error 2");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}
/// Company contact get
Future<CompanyContactPrefill> getCompanyContactPrefill(
    BuildContext context,
    ) async{
  var itemData;
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await Api(context).get(
        path: EstablishmentManagerRepository.
        patchCompanyContact(companyId: companyId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("fetched Contact details");
      return itemData = CompanyContactPrefill(
          companyContactID: response.data['company_contact_id']??0,
          companyId:  response.data['company_id']??0,
          primaryNo:  response.data['primary_phone']??"",
          secondaryPhoneNo:  response.data['secondary_phone']??"",
          primaryFax:  response.data['primary_fax']??"",
          alternativePhoneNo:  response.data['alternative_phone']??"",
          email:  response.data['email']??"");
    } else {
      print("Error 1");
      return itemData;
    }

  } catch (e) {
    print("Error $e");
    return itemData;

  }
}
/// post company contact
Future<ApiData> postCompanyContact(
    BuildContext context,
    // String officeId,
    String primaryNo,
    String secondaryNo,
    String primFax,
    String secondaryFax,
    String alternativeNo,
    String email,
    // String name,
    // String address,

    ) async{
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await Api(context).post(
        path: EstablishmentManagerRepository.
        postCompanyContact(),
        data: {
          "company_id": companyId,
          "primary_phone": primaryNo,
          "secondary_phone": secondaryNo,
          "primary_fax": primFax,
          "alternative_phone": alternativeNo,
          "email": email
        });
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Added company contact");
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
    print("Error 2");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

/// patch company contact
Future<ApiData> patchWhitelabellingCompanyContact(
    BuildContext context,
    // String officeId,
    String primaryNo,
    String secondaryNo,
    String primFax,
    String secondaryFax,
    String alternativeNo,
    String email,
    // String name,
    // String address,

    ) async{
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await Api(context).patch(
        path: EstablishmentManagerRepository.
        patchCompanyContact(companyId: companyId),
        data: {
          "company_id": companyId,
          "primary_phone": primaryNo,
          "secondary_phone": secondaryNo,
          "primary_fax": primFax,
          "alternative_phone": alternativeNo,
          "email": email
        });
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Updated company contact");
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
    print("Error 2");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}
/// Upload Logo
Future<ApiData> uploadWebAndAppLogo({
  required BuildContext context,
  required String type,
  required dynamic documentFile,
  required String documentName,
}
    ) async{
  try {
    final companyId = await TokenManager.getCompanyId();
    var logoDoc = await AppFilePickerBase64.getEncodeBase64(bytes: documentFile);
    var response = await Api(context).post(
        path: EstablishmentManagerRepository.
        uploadCompanyLogo(companyId: companyId, type: type),
        data: {
          "base64":logoDoc
        });
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Logo Uploaded");
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
    print("Error 2");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

/// patch company logo

Future<ApiData> patchWebAndAppLogo({
  required BuildContext context,
  required String type,
  required dynamic documentFile,
  required int companyLogoId,
  required String documentName,
}
    ) async{
  try {
    final companyId = await TokenManager.getCompanyId();
    var logoDoc = await AppFilePickerBase64.getEncodeBase64(bytes: documentFile);
    var response = await Api(context).patch(
        path: EstablishmentManagerRepository.
        patchCompanyLogo(companyId: companyId, companyLogoId:companyLogoId,type: type),
        data: {
          "base64":logoDoc
        });
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Logo patch Uploaded");
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
    print("Error 2");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

///
// Future< WhiteLabellingCompanyDetailModal> getWhiteLabellingData(
//     BuildContext context,
//     // int companyID, String officeId
//     int companyDetail
//     ) async {
//   var itemsData;
//   try {
//     final response = await Api(context).get(
//         path: EstablishmentManagerRepository. getWhitelabellingDetail(
//             companyDetail:  companyDetail
//         )
//     );
//     print(response);
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       print("Office details response<<::${itemsData}");
//       // for (var item in response.data['officeDetail']) {
//       itemsData =  WhiteLabellingCompanyDetailModal(
//           // officeName: response.data['officeDetail']['name'],
//           // priNumber: response.data['officeDetail']['primary_phone'],
//           // secNumber: response.data['officeDetail']['secondary_phone'],
//           // alternateNumber: response.data['officeDetail']['alternative_phone'],
//           // address: response.data['officeDetail']['address'],
//           // email: response.data['officeDetail']['email'],
//           // officeID: response.data['officeDetail']["office_id"],
//           sucess: true,
//           message: response.statusMessage!);
//       // }
//       // );
//       // itemsList.add(
//       //   ManageDetails(
//       //       officeName: item['name'],
//       //       priNumber: item['primary_phone'],
//       //       secNumber: item['secondary_phone'],
//       //       alternateNumber: item['alternative_phone'],
//       //       address: item['address'],
//       //       email: item['email'],
//       //       officeID: item["office_id"],
//       //       sucess: true,
//       //       message: response.statusMessage!),
//       // );
//       print("Office details response:::::${itemsData}");
//       // CompanyModel(
//       //   name: response.data['Name'],
//       //   address: response.data['address'],
//       //   );
//     } else {
//       print('Api Error');
//       //return itemsList;
//     }
//     return itemsData;
//   } catch (e) {
//     print("Error $e");
//     return itemsData;
//   }
// }

Future<WhiteLabellingCompanyDetailModal> getWhiteLabellingData(
    BuildContext context,
    ) async {
  var itemsData;
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(path: EstablishmentManagerRepository.getWhitelabellingDetail(
        companyId: companyId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      var responseData = response.data;
      print("Sucess");
      // WLCompanyDetailModal companyDetail =
      // WLCompanyDetailModal.fromJson(responseData['CompanyDetail']);
      // WLContactDetailModal contactDetail =
      // WLContactDetailModal.fromJson(responseData['ContactDetail']);
      // List<WLLogoModal> logos = (responseData['Logos'] as List).map((logo) =>
      //     WLLogoModal.fromJson(logo)).toList();
      List<WLLogoModal> logosDetails = [];
      if (response.data['Logos'] != null) {
        for (var items in response.data['Logos']) {
          logosDetails.add(
              WLLogoModal(companyLogoId: items['company_logo_id'],
              companyId: items['company_id'] ?? 0,
              url: items['url'] ?? '',
              type: items['type'] ?? '',
              base: items['base'] ?? ''
          ));
        }
      }
      itemsData = WhiteLabellingCompanyDetailModal(
        companyDetail: WLCompanyDetailModal(
          companyId: response.data['CompanyDetail']['company_id'],
          name: response.data['CompanyDetail']['Name'],
          description: response.data['CompanyDetail']['description'],
          url: response.data['CompanyDetail']['url'],
          address: response.data['CompanyDetail']['address'],
          headOfficeId: response.data['CompanyDetail']['head_office_id'],
        ),
        contactDetail:response.data['ContactDetail'] != null ?WLContactDetailModal(
          companyContactId: response.data['ContactDetail']['company_contact_id']??0,
          companyId: response.data['ContactDetail']['company_id']??companyId,
          primaryPhone: response.data['ContactDetail']['primary_phone']??"",
          secondaryPhone: response.data['ContactDetail']['secondary_phone']??"",
          primaryFax: response.data['ContactDetail']['primary_fax']??"",
          alternativePhone: response.data['ContactDetail']['alternative_phone']??"",
          email: response.data['ContactDetail']['email']??"",
        ) :WLContactDetailModal(
          companyContactId: 0,
          companyId: companyId,
          primaryPhone: "",
          secondaryPhone: "",
          primaryFax: "",
          alternativePhone: "",
          email: "",
        ),
        logos: logosDetails,
        message: response.statusMessage ?? 'Success',
        success: true,
      );
      print("Company data ${itemsData}");
      return itemsData;
    } else {
      print("Api Error company details");
    }
    return itemsData;
  } catch (e) {
    print("Error ${e}");
    return itemsData;
  }

}

/// Upload Logo
Future<ApiData> postWhiteleblingCompanyData({
  required BuildContext context,
  required String companyName,
  required String description,
  required String url,
  required String address,
  required String headOfficeId
}
    ) async{
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await Api(context).post(
        path: EstablishmentManagerRepository.
        addCompanyWhitelebling(),
        data: {
          "Name": companyName,
          "description": description,
          "url": url,
          "address": address,
          "head_office_id": headOfficeId
        });
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Logo Uploaded");
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
    print("Error 2");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

/// workin api
// Future<WhiteLabellingCompanyDetailModal> getWhiteLabellingData(
//     BuildContext context,
//     int companyId,
//     ) async {
//   late WhiteLabellingCompanyDetailModal itemsData;
//   try {
//     final response = await Api(context).get(
//       path: EstablishmentManagerRepository.getWhitelabellingDetail(
//           companyId: companyId
//       ),
//     );
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       var responseData = response.data;
//       WLCompanyDetailModal companyDetail =
//       WLCompanyDetailModal.fromJson(responseData['CompanyDetail']);
//       WLContactDetailModal contactDetail =
//       WLContactDetailModal.fromJson(responseData['ContactDetail']);
//       List<WLLogoModal> logos = (responseData['Logos'] as List).map((logo) =>
//           WLLogoModal.fromJson(logo)).toList();
//
//       itemsData = WhiteLabellingCompanyDetailModal(
//         companyDetail: companyDetail,
//         contactDetail: contactDetail,
//         logos: logos,
//         message: response.statusMessage ?? 'Success',
//          success: true,
//       );
//     } else {
//       itemsData = WhiteLabellingCompanyDetailModal(
//
//         companyDetail: WLCompanyDetailModal(
//             companyId: 1,
//             name: '',
//             description: '',
//             url: '',
//             address: '',
//             headOfficeId: ''
//         ),
//         contactDetail: WLContactDetailModal(
//             companyContactId: 0,
//             companyId: 1,
//             primaryPhone: '',
//             secondaryPhone: '',
//             primaryFax: '',
//             alternativePhone: '',
//             email: ''),
//         logos: [],
//         success: false,
//         message: response.statusMessage ?? 'Whitelabelling get Error',
//       );
//     }
//   } catch (e) {
//     itemsData = WhiteLabellingCompanyDetailModal(
//       companyDetail: WLCompanyDetailModal(
//           companyId: 1,
//           name: '',
//           description: '',
//           url: '',
//           address: '',
//           headOfficeId: ''
//       ),
//       contactDetail: WLContactDetailModal(
//           companyContactId: 0,
//           companyId: 1,
//           primaryPhone: '',
//           secondaryPhone: '',
//           primaryFax: '',
//           alternativePhone: '',
//           email: ''
//       ),
//       logos: [
//
//       ],
//       success: false,
//       message: e.toString(),
//     );
//   }
//   return itemsData;
// }
