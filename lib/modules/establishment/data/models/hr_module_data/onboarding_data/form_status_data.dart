// class FormModel {
//   List<SignedForm> signedForms;
//   List<UnsignedForm> unsignedForms;
//
//   FormModel({
//     required this.signedForms,
//     required this.unsignedForms,
//   });
//
//   // factory FormModel.fromJson(Map<String, dynamic> json) {
//   //   return FormModel(
//   //     signedForms: json['signedForms'] ?? [],
//   //     unsignedForms: (json['unsignedForms'] as List)
//   //         .map((item) => UnsignedForm.fromJson(item))
//   //         .toList(),
//   //   );
//   // }
//   //
//   // Map<String, dynamic> toJson() {
//   //   return {
//   //     'signedForms': signedForms,
//   //     'unsignedForms': unsignedForms.map((item) => item.toJson()).toList(),
//   //   };
//   // }
// }

class FormModel {
  int formHtmlTemplatesId;
  String htmlname;
  int companyId;
  bool signed;
  String url;

  FormModel({
    required this.formHtmlTemplatesId,
    required this.htmlname,
    required this.companyId,
    required this.signed,
    required this.url,
});
}
// class UnsignedForm {
//   int formHtmlTemplatesId;
//   String htmlname;
//   int companyId;
//   bool signed;
//
//   UnsignedForm({
//     required this.formHtmlTemplatesId,
//     required this.htmlname,
//     required this.companyId,
//     required this.signed,
//   });
//
//   // factory UnsignedForm.fromJson(Map<String, dynamic> json) {
//   //   return UnsignedForm(
//   //     formHtmlTemplatesId: json['formHtmlTemplatesId'],
//   //     htmlname: json['htmlname'],
//   //     companyId: json['company_Id'],
//   //     signed: json['signed'],
//   //   );
//   // }
//   //
//   // Map<String, dynamic> toJson() {
//   //   return {
//   //     'formHtmlTemplatesId': formHtmlTemplatesId,
//   //     'htmlname': htmlname,
//   //     'company_Id': companyId,
//   //     'signed': signed,
//   //   };
//   // }
// }
//
// class SignedForm {
//   int formHtmlTemplatesId;
//   String htmlname;
//   int companyId;
//   bool signed;
//
//   SignedForm({
//     required this.formHtmlTemplatesId,
//     required this.htmlname,
//     required this.companyId,
//     required this.signed,
//   });
//
// // factory UnsignedForm.fromJson(Map<String, dynamic> json) {
// //   return UnsignedForm(
// //     formHtmlTemplatesId: json['formHtmlTemplatesId'],
// //     htmlname: json['htmlname'],
// //     companyId: json['company_Id'],
// //     signed: json['signed'],
// //   );
// // }
// //
// // Map<String, dynamic> toJson() {
// //   return {
// //     'formHtmlTemplatesId': formHtmlTemplatesId,
// //     'htmlname': htmlname,
// //     'company_Id': companyId,
// //     'signed': signed,
// //   };
// // }
// }
