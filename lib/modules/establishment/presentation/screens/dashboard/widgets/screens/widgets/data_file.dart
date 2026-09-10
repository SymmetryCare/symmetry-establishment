class BarChartEMData {
  BarChartEMData(this.x, this.y, this.y1,);
  final String x;
  final double? y;
  final double? y1;
}

class ChartData {
  ChartData(this.x, this.y);
  final int x;
  final double? y;
}

///line graph doc auditing
class ChartDataLine {
  ChartDataLine(this.x, this.y);
  final String x;
  final double? y;
}

class ChartedDataLine {
  final int x;
  final double y;
  ChartedDataLine(this.x, this.y);
}