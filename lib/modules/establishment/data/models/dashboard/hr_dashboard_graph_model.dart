class EmployeeSexRatioData {
  final int totalEmployees;
  final List<GenderStatistic> genderStatistics;
  EmployeeSexRatioData({
    required this.totalEmployees,
    required this.genderStatistics,
  });
// Factory constructor to create an instance from a JSON map
// factory EmployeeStatistics.fromJson(Map<String, dynamic> json) {
//   return EmployeeStatistics(
//     totalEmployees: json['totalEmployees'],
//     genderStatistics: (json['genderStatistics'] as List)
//         .map((item) => GenderStatistic.fromJson(item))
//         .toList(),
//   );
// }

// Method to convert an instance back to JSON
// Map<String, dynamic> toJson() {
//   return {
//     'totalEmployees': totalEmployees,
//     'genderStatistics': genderStatistics.map((item) => item.toJson()).toList(),
//   };
// }
}

class GenderStatistic {
  final String gender;
  final int count;
  final String percentage;

  GenderStatistic({
    required this.gender,
    required this.count,
    required this.percentage,
  });

// Factory constructor to create an instance from a JSON map
// factory GenderStatistic.fromJson(Map<String, dynamic> json) {
//   return GenderStatistic(
//     gender: json['gender'],
//     count: json['count'],
//     percentage: json['percentage'],
//   );
// }
//
// // Method to convert an instance back to JSON
// Map<String, dynamic> toJson() {
//   return {
//     'gender': gender,
//     'count': count,
//     'percentage': percentage,
//   };
// }
}