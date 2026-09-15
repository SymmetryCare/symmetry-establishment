

class HRModuleAEClinicalRepository {
      ///employee type department
      static String emplyType = "/employee-types/";
      static String dept =  "Department/";
      ///city
      static String city = "/city";
      ///Reporting office
      static String companyOffice = "/company-office/";
      ///zone
      static String zone = "/zone/";
      ///service
      static String service = "company-office-service";
      static String addEmployees = "/employees/add";
      static String employees = "/employees";
      static String attachPhoto = "/attach-photo/";
      static String servicesradiobutton = "/service-metadata";
          // "/company-office-service/";


  static String getEmployeeTypeDept(int deptId){
    return "$emplyType$dept$deptId";
  }
  static String getAddEmployeeTypeCity(){
    return "$city";
  }
  static String getAddEmplyReportingOffice(int companyID){
    return "$companyOffice$companyID";
  }
  static String getAddEmplyZone({required int companyId}){
    return "$zone/zoneDropdownByCompany/$companyId";
  }
  static String getAddEmplyService(
      //{required int companyID}
      ){return "$service";}
  static String getEmplyServiceRadiobutton({required int companyID}){
        return "/$service/$companyID";
      }
      static String postAddEmployeeClinical(){
    return "$addEmployees";
    }
    static String getEmployees(){
    return "$employees";
    }
    static String addphoto({
     required int employeeID
    }){
    return "$employees$attachPhoto$employeeID";
   }



   ////radio button

      static String getEmpServiceRadiobutton(){
        return "$servicesradiobutton";
      }


}
// { required int companyID,
//   required int officeID,
//   required int countyID,
//   required int pageNo,
//   required int rowsNo}