import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation_model.dart';

class CalculatorProvider extends ChangeNotifier {
  // Panel Calculator State
  double panelWatts = 400;
  int panelCount = 10;
  double peakSunHours = 5.0;
  double systemEfficiency = 0.80;

  // Savings Calculator State
  double tariffPerKwh = 7.0; // ₹ per kWh (India default)
  double systemCostInr = 350000; // ₹3.5 Lakh default
  double currentMonthlyBill = 2000;

  // Results
  PanelCalculationResult? panelResult;
  SavingsCalculationResult? savingsResult;

  // History
  List<SolarCalculation> history = [];

  CalculatorProvider() {
    _loadHistory();
  }

  // ─── Panel Output Calculator ────────────────────────────────────────────────
  void calculatePanelOutput() {
    final peakPowerKw = (panelWatts * panelCount) / 1000.0;
    final dailyKwh = peakPowerKw * peakSunHours * systemEfficiency;
    final monthlyKwh = dailyKwh * 30;
    final annualKwh = dailyKwh * 365;
    // CO2: average grid emission factor ~0.82 kg CO2/kWh (India) 
    final co2Offset = annualKwh * 0.82;

    panelResult = PanelCalculationResult(
      dailyKwh: dailyKwh,
      monthlyKwh: monthlyKwh,
      annualKwh: annualKwh,
      peakPowerKw: peakPowerKw,
      co2OffsetKgPerYear: co2Offset,
    );

    _saveCalculation(
      type: 'panel_output',
      inputs: {
        'panelWatts': panelWatts,
        'panelCount': panelCount,
        'peakSunHours': peakSunHours,
        'systemEfficiency': systemEfficiency,
      },
      results: {
        'dailyKwh': dailyKwh,
        'monthlyKwh': monthlyKwh,
        'annualKwh': annualKwh,
        'peakPowerKw': peakPowerKw,
        'co2OffsetKgPerYear': co2Offset,
      },
    );

    notifyListeners();
  }

  // ─── Savings Calculator ─────────────────────────────────────────────────────
  void calculateSavings() {
    if (panelResult == null) calculatePanelOutput();

    final monthlyKwh = panelResult!.monthlyKwh;
    final monthlyBill = monthlyKwh * tariffPerKwh;
    final annualSavings = monthlyBill * 12;
    final paybackYears = annualSavings > 0
        ? systemCostInr / annualSavings
        : double.infinity;
    // 25 year lifetime, 0.5% annual panel degradation
    double lifetimeSavings = 0;
    double currentAnnual = annualSavings;
    for (int i = 0; i < 25; i++) {
      lifetimeSavings += currentAnnual;
      currentAnnual *= 0.995;
    }
    final roi25Years =
        ((lifetimeSavings - systemCostInr) / systemCostInr) * 100;

    savingsResult = SavingsCalculationResult(
      monthlyBill: monthlyBill,
      annualSavings: annualSavings,
      paybackYears: paybackYears,
      roi25Years: roi25Years,
      lifetimeSavings: lifetimeSavings,
    );

    _saveCalculation(
      type: 'savings',
      inputs: {
        'panelWatts': panelWatts,
        'panelCount': panelCount,
        'peakSunHours': peakSunHours,
        'tariffPerKwh': tariffPerKwh,
        'systemCostInr': systemCostInr,
      },
      results: {
        'monthlyBill': monthlyBill,
        'annualSavings': annualSavings,
        'paybackYears': paybackYears,
        'roi25Years': roi25Years,
        'lifetimeSavings': lifetimeSavings,
      },
    );

    notifyListeners();
  }

  // ─── History Persistence ────────────────────────────────────────────────────
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('calc_history') ?? [];
    history = raw
        .map((s) => SolarCalculation.fromJsonString(s))
        .toList()
        .reversed
        .toList();
    notifyListeners();
  }

  Future<void> _saveCalculation({
    required String type,
    required Map<String, dynamic> inputs,
    required Map<String, dynamic> results,
  }) async {
    final calc = SolarCalculation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      type: type,
      inputs: inputs,
      results: results,
    );

    history.insert(0, calc);
    if (history.length > 50) history = history.sublist(0, 50);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'calc_history',
      history.map((c) => c.toJsonString()).toList(),
    );
  }

  Future<void> clearHistory() async {
    history.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('calc_history');
    notifyListeners();
  }

  // ─── Setters ─────────────────────────────────────────────────────────────
  void setPanelWatts(double v) { panelWatts = v; notifyListeners(); }
  void setPanelCount(int v) { panelCount = v; notifyListeners(); }
  void setPeakSunHours(double v) { peakSunHours = v; notifyListeners(); }
  void setSystemEfficiency(double v) { systemEfficiency = v; notifyListeners(); }
  void setTariffPerKwh(double v) { tariffPerKwh = v; notifyListeners(); }
  void setSystemCost(double v) { systemCostInr = v; notifyListeners(); }
  void setCurrentMonthlyBill(double v) { currentMonthlyBill = v; notifyListeners(); }
}
