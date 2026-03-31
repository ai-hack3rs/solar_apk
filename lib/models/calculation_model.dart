import 'dart:convert';

class SolarCalculation {
  final String id;
  final DateTime createdAt;
  final String type; // 'panel_output', 'savings'
  final Map<String, dynamic> inputs;
  final Map<String, dynamic> results;

  SolarCalculation({
    required this.id,
    required this.createdAt,
    required this.type,
    required this.inputs,
    required this.results,
  });

  factory SolarCalculation.fromJson(Map<String, dynamic> json) {
    return SolarCalculation(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      type: json['type'],
      inputs: json['inputs'],
      results: json['results'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'type': type,
        'inputs': inputs,
        'results': results,
      };

  String toJsonString() => jsonEncode(toJson());
  static SolarCalculation fromJsonString(String s) =>
      SolarCalculation.fromJson(jsonDecode(s));
}

class PanelCalculationResult {
  final double dailyKwh;
  final double monthlyKwh;
  final double annualKwh;
  final double peakPowerKw;
  final double co2OffsetKgPerYear;

  PanelCalculationResult({
    required this.dailyKwh,
    required this.monthlyKwh,
    required this.annualKwh,
    required this.peakPowerKw,
    required this.co2OffsetKgPerYear,
  });
}

class SavingsCalculationResult {
  final double monthlyBill;
  final double annualSavings;
  final double paybackYears;
  final double roi25Years;
  final double lifetimeSavings;

  SavingsCalculationResult({
    required this.monthlyBill,
    required this.annualSavings,
    required this.paybackYears,
    required this.roi25Years,
    required this.lifetimeSavings,
  });
}
