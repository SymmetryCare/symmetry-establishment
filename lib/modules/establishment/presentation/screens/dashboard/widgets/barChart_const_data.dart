import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';

class ComboChartData {
  ComboChartData(this.x, this.y, this.y1,);
  final String x;
  final double? y;
  final double? y1;

}
class ChartAreaData {
  ChartAreaData(this.x, this.y, this.y1);
  final int x;
  final double y;
  final double y1;
}

class TrackBallChartData {
  TrackBallChartData(this.empName, this.firstSale, this.secondSale);
  final String empName;
  final double firstSale;
  final double secondSale;
}

class HalfChartData {
  HalfChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}