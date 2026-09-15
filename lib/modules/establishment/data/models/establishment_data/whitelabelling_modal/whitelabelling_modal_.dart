///WL company Detail
// class WhiteLabellingCompanyDetailModal {
//   final int? companyId;
//   final String? name;
//   final String? discription;
//   final String? url;
//   final String? address;
//   final String? headOffId;
//   final bool? sucess;
//   final String? message;
//
//   WhiteLabellingCompanyDetailModal(
//      {
//        this.companyId,
//        this.name,
//        this.discription,
//        this.url,
//        this.address,
//        this.headOffId,
//        required this.sucess,
//     required this.message,
//   });
// }
///WL contactDetail
class WhiteLContactDetailModal{
  final int? companyContactId;
  final int? companyId;
  final String? primNo;
  final String? secNo;
  final String? primeFax;
  final String? altNo;
  final String? email;

  WhiteLContactDetailModal({
    this.companyContactId, this.companyId,
    this.primNo, this.secNo, this.primeFax, this.altNo, this.email
});
}
///WL Logos
class WhiteLabelLogosMaodal{
  final int? companyLogoId;
  final int? companyId;
  final String? url;
  final String? type;

  WhiteLabelLogosMaodal({
    this.companyLogoId,
    this.companyId,
    this.url,
    this.type
  });
}
///
class WLCompanyDetailModal {
  int companyId;
  String name;
  String description;
  String url;
  String address;
  String headOfficeId;

  WLCompanyDetailModal({
    required this.companyId,
    required this.name,
    required this.description,
    required this.url,
    required this.address,
    required this.headOfficeId,
  });

  // factory WLCompanyDetailModal.fromJson(Map<String, dynamic> json) {
  //   return WLCompanyDetailModal(
  //     companyId: json['company_id'],
  //     name: json['Name'],
  //     description: json['description'],
  //     url: json['url'],
  //     address: json['address'],
  //     headOfficeId: json['head_office_id'],
  //   );
  // }
}

class WLContactDetailModal {
  int companyContactId;
  int companyId;
  String primaryPhone;
  String secondaryPhone;
  String primaryFax;
  String alternativePhone;
  String email;

  WLContactDetailModal({
    required this.companyContactId,
    required this.companyId,
    required this.primaryPhone,
    required this.secondaryPhone,
    required this.primaryFax,
    required this.alternativePhone,
    required this.email,
  });

  // factory WLContactDetailModal.fromJson(Map<String, dynamic> json) {
  //   return WLContactDetailModal(
  //     companyContactId: json['company_contact_id']??0,
  //     companyId: json['company_id']??1,
  //     primaryPhone: json['primary_phone']??"",
  //     secondaryPhone: json['secondary_phone']??"",
  //     primaryFax: json['primary_fax']??"",
  //     alternativePhone: json['alternative_phone']??"",
  //     email: json['email']??"",
  //   );
  // }
}

class WLLogoModal {
  int companyLogoId;
  int companyId;
  String url;
  String type;
  String base;

  WLLogoModal({
    required this.companyLogoId,
    required this.companyId,
    required this.url,
    required this.type,
    required this.base,
  });

  // factory WLLogoModal.fromJson(Map<String, dynamic> json) {
  //   return WLLogoModal(
  //     companyLogoId: json['company_logo_id'],
  //     companyId: json['company_id'],
  //     url: json['url'],
  //     type: json['type'],
  //     base: json['base']
  //   );
  // }
}

class WhiteLabellingCompanyDetailModal {
  WLCompanyDetailModal companyDetail;
  WLContactDetailModal contactDetail;
  List<WLLogoModal> logos;
  bool success;
  String message;

  WhiteLabellingCompanyDetailModal({
    required this.companyDetail,
    required this.contactDetail,
    required this.logos,
    required this.success,
    required this.message,
  });
}

class CompanyContactPrefill {
  final int companyContactID;
  final int companyId;
  final String primaryNo;
  final String secondaryPhoneNo;
  final String primaryFax;
  final String alternativePhoneNo;
  final String email;


  CompanyContactPrefill({
    required this.companyContactID,
    required this.companyId,
    required this.primaryNo,
    required this.secondaryPhoneNo,
    required this.primaryFax,
    required this.alternativePhoneNo,
    required this.email,
  });
}