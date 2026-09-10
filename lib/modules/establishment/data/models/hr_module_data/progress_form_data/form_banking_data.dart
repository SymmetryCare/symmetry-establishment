class BankingDataForm {
  final int empBankingId;
  final String accountNumber;
  final int employeeId;
  final String bankName;
  final int amountRequested;
  final String checkUrl;
  final String effectiveDate;
  final String routingNumber;
  final String type;
  bool? approved;
  final String requestedPercentage;

  BankingDataForm({
    required this.empBankingId,
    required this.accountNumber,
    required this.employeeId,
    required this.bankName,
    required this.amountRequested,
    required this.checkUrl,
    required this.effectiveDate,
    required this.routingNumber,
    required this.type,
    this.approved,
    required this.requestedPercentage,
  });
}
