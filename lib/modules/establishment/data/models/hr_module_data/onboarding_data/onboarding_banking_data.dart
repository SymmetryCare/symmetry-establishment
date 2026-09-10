class OnboardingBankingData{
  final int empBankId;
  final String accNum;
  final int empId;
  final String bankName;
  final int amtRequested;
  final String checkUrl;
  final String effectiveDate;
  final String rountingNumber;
  final String type;
  final String requestedPercentage;
  final bool approved;

  OnboardingBankingData({required this.empBankId,
    required this.accNum,required this.empId,required this.bankName,required this.amtRequested,required this.checkUrl,
    required this.effectiveDate,required this.rountingNumber,
    required this.type,
    required this.requestedPercentage,
    required this.approved});
}

// {
// "empBankingId": 1,
// "accountNumber": "11100223300",
// "employeeId": 2,
// "bankName": "SWISS BANK",
// "amountRequested": 2500000,
// "checkUrl": "https://symmetry-office-document.s3.us-west-2.amazonaws.com/0d99984d-b902-4db5-a37f-044f2a7b21ae-Resume_SujataBhalerao%20-.docx",
// "effectiveDate": "2024-06-02T04:06:43.838Z",
// "routingNumber": "789",
// "type": "checking",
// "approved": null
// },