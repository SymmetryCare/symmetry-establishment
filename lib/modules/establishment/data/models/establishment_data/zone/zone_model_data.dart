///zone GET
class AllZoneData {
  final int zoneId;
  final String zoneName;
  final int companyId;
  final String officeId;
  final int countyId;
  final bool sucess;
  final String message;

  AllZoneData({
    required this.companyId,
    required this.officeId,
    required this.countyId,
    required this.zoneId,
    required this.zoneName,
    required this.sucess,
    required this.message,
  });
}

class AllZoneCompanyWiseData {
  final int zoneId;
  final String zoneName;
  final int companyId;
  final String officeId;
  final int countyId;
  final bool sucess;
  final String message;

  AllZoneCompanyWiseData({
    required this.companyId,
    required this.officeId,
    required this.countyId,
    required this.zoneId,
    required this.zoneName,
    required this.sucess,
    required this.message,
  });
}

///county get last
class AllCountyGet {
  final int countyId;
  final String? countyName;
  // final int zoinId;
  final String? state;
  final String? country;
  final String? zipcodes;
  final List<String> zoneName;
  final bool? sucess;
  final String? message;
  AllCountyGet({
    required this.countyId,
    //required this.zoinId,
    required this.zoneName,
    required this.countyName,
    required this.state,
    required this.country,
    required this.zipcodes,
    required this.sucess,
    required this.message,
  });
}

class AllCountyByOfficeId{
  final int countyId;
  final String countyName;
  final String state;
  final String country;
  final String lat;
  final String long;
  final int companyId;
  final String officeId;
AllCountyByOfficeId({required this.countyId, required this.countyName, required this.state,
    required this.country, required this.lat, required this.long, required this.companyId, required this.officeId});
}

/// County prefill get
class CountyPrefillGet {
  final int companyId;
  final String officeId;
  final int countyId;
  final String? countyName;
  final String? state;
  final String? country;
  final bool? sucess;
  final String? message;
  CountyPrefillGet({
    required this.companyId,
    required this.officeId,
    required this.countyId,
    required this.countyName,
    required this.state,
    required this.country,
    required this.sucess,
    required this.message,
  });
}

/// County zone get
class AllCountyZoneGet {
  final String countyName;
  final int countyId;
  final int zoneId;
  final String zoneName;
  final String zipcodes;
  final String cities;
  final bool sucess;
  final String message;
  AllCountyZoneGet(
      {required this.countyName,
        required this.countyId,
        required this.zoneId,
        required this.zoneName,
        required this.zipcodes,
        required this.cities,
        required this.sucess,
        required this.message});
}

/// prefill county zone
class CountyZonePrefillGet {
  // "zone_id": 44,
  // "county_id": 25,
  // "zoneName": "23",
  // "companyId": 11,
  // "officeId": "2"

  final int countyId;
  final int zoneId;
  final String zoneName;
  final String countyName;
  // final int companyId;
  // final String officeId;

  CountyZonePrefillGet({required this.countyName,
    // required this.companyId,
    // required this.officeId,
    required this.countyId,
    required this.zoneId,
    required this.zoneName,
  });
}

/// County List Data
class AllCountyGetList {
  final String countyName;
  final int countyId;
  final int companyId;
  final String state;
  final String country;
  final String latitude;
  final String longitude;
  final String officeID;
  final bool sucess;
  final String message;
  AllCountyGetList({
    required this.officeID,
    required this.countyId,
    required this.companyId,
    required this.latitude,
    required this.longitude,
    required this.countyName,
    required this.state,
    required this.country,
    required this.sucess,
    required this.message,
  });
}

/// County Office wise drrropdown List Data
class OfficeWiseCountyData {
  final String countyName;
  final int countyId;
  final int companyId;
  final String state;
  final String country;
  final String latitude;
  final String longitude;
  final String officeId;
  final bool sucess;
  final String message;
  OfficeWiseCountyData({
    required this.officeId,
    required this.countyId,
    required this.companyId,
    required this.latitude,
    required this.longitude,
    required this.countyName,
    required this.state,
    required this.country,
    required this.sucess,
    required this.message,
  });
}

//
// class AllCountyGet {
//   final int? countyId;
//   final String? countyName;
//   final String? state;
//   final String? country;
//   final String? latitude;
//   final String? longitude;
//   final int? compId;
//   final int? officeId;
//   final bool? sucess;
//   final String? message;
//   AllCountyGet({required this.countyId,required this.latitude,required this.longitude,required this.compId,required this.officeId, required this.countyName,required this.state,required this.country,required this.sucess,required this.message,});
// }
///zipcode,zone get
class AllZipCodeGet {
  final int? zipcodeSetupId;
  final int? zoneId;
  final int? countyID;
  final int? companyID;
  final String zoneName;
  final String countyName;
  final String? city;
  final String? zipcode;
  final String? latitude;
  final String? longitude;
  final String? landmark;
  final String? officeId;
  final bool? sucess;
  final String? message;

  AllZipCodeGet({
    required this.zoneName,
    required this.countyName,
    required this.zipcodeSetupId,
    required this.zoneId,
    required this.countyID,
    required this.companyID,
    required this.city,
    required this.zipcode,
    required this.latitude,
    required this.longitude,
    required this.landmark,
    required this.officeId,
    required this.sucess,
    required this.message,
  });
}

///zipcode,zone get prefill
class ZipCodeGetPrefill {
  final int? zipcodeSetupId;
  final int? zoneId;
  final int? countyID;
  final int? companyID;
  final String zoneName;
  final String countyName;
  final String? city;
  final String? zipcode;
  final String? latitude;
  final String? longitude;
  final String? landmark;
  final String? officeId;


  ZipCodeGetPrefill({
    required this.zoneName,
    required this.countyName,
    required this.zipcodeSetupId,
    required this.zoneId,
    required this.countyID,
    required this.companyID,
    required this.city,
    required this.zipcode,
    required this.latitude,
    required this.longitude,
    required this.landmark,
    required this.officeId,

  });
}

/// Model class zipcode by countyId

class ZipcodeByCountyIdData {
  final int zipcodeSetupId;
  final int zoneId;
  final int countyId;
  final String city;
  final String zipCode;
  final String latitude;
  final String longitude;
  final String landMark;
  final int companyId;
  final String officeId;

  ZipcodeByCountyIdData({
    required this.zipcodeSetupId,
    required this.zoneId,
    required this.countyId,
    required this.city,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
    required this.landMark,
    required this.companyId,
    required this.officeId,
  });
}
class ZipcodeByCompnanyIdData {
  final int zipcodeSetupId;
  final int zoneId;
  final int countyId;
  final String city;
  final String zipCode;
  final String latitude;
  final String longitude;
  final String landMark;
  final int companyId;
  final String officeId;

  ZipcodeByCompnanyIdData({
    required this.zipcodeSetupId,
    required this.zoneId,
    required this.countyId,
    required this.city,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
    required this.landMark,
    required this.companyId,
    required this.officeId,
  });
}
class ZipcodeByCountyIdAndZoneIdData {
  final int zipcodeSetupId;
  final int zoneId;
  final int countyId;
  final String city;
  final String zipCode;
  final String latitude;
  final String longitude;
  final String landMark;
  final int companyId;
  final String officeId;

  ZipcodeByCountyIdAndZoneIdData({
    required this.zipcodeSetupId,
    required this.zoneId,
    required this.countyId,
    required this.city,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
    required this.landMark,
    required this.companyId,
    required this.officeId,
  });
}
class CountryGetData{
  final int countryId;
  final String name;
  final String short;
  CountryGetData({required this.countryId,required this.name,required this.short});
}
