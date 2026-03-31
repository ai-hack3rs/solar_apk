import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SolarResults {
  final double totalSystemCost;
  final double subsidy;
  final double netInvestment;
  final double lifetimeSavings;
  final int? breakEvenYear;
  final double annualBattCosts;
  final List<int> batteryReplacementYears;
  final List<double> cumulativeCost;
  final List<double> cumulativeReturns;
  final double dcYield;
  final double acOutput;
  final double selfSufficiency;
  final double unmetLoad;
  final double annualGenBase;
  final double estTotalCost;
  final double estSubsidy;

  SolarResults({
    required this.totalSystemCost,
    required this.subsidy,
    required this.netInvestment,
    required this.lifetimeSavings,
    this.breakEvenYear,
    required this.annualBattCosts,
    required this.batteryReplacementYears,
    required this.cumulativeCost,
    required this.cumulativeReturns,
    required this.dcYield,
    required this.acOutput,
    required this.selfSufficiency,
    required this.unmetLoad,
    required this.annualGenBase,
    required this.estTotalCost,
    required this.estSubsidy,
  });
}

class DashboardProvider extends ChangeNotifier {
  // Input fields
  String _systemType = 'On-Grid';
  double _systemSize = 5.0; // kW
  double _dailyConsumption = 20.0; // kWh
  double _dayUsagePct = 70.0; // %
  double _lat = 23.022505;
  double _lng = 72.571362;
  double _gridRate = 8.0; // ₹
  double _installCost = 15000.0; // ₹
  double _panelDegradation = 0.5; // %
  int _voltage = 48; // V
  String _batteryType = 'LiFePO4';
  double _batteryCapacity = 10.0; // kWh
  String _hybridStrategy = 'Max Savings';
  double _systemLosses = 14.0; // %

  double? _overrideCost;
  double? _overrideSubsidy;

  SolarResults? _results;

  DashboardProvider() {
    _calculate();
  }

  // Getters
  String get systemType => _systemType;
  double get systemSize => _systemSize;
  double get dailyConsumption => _dailyConsumption;
  double get dayUsagePct => _dayUsagePct;
  double get lat => _lat;
  double get lng => _lng;
  double get gridRate => _gridRate;
  double get installCost => _installCost;
  double get panelDegradation => _panelDegradation;
  int get voltage => _voltage;
  String get batteryType => _batteryType;
  double get batteryCapacity => _batteryCapacity;
  String get hybridStrategy => _hybridStrategy;
  double get systemLosses => _systemLosses;
  double? get overrideCost => _overrideCost;
  double? get overrideSubsidy => _overrideSubsidy;
  SolarResults? get results => _results;
  double get psh => SolarConstants.calculatePSH(_lat);
  BatterySpec get batterySpec => SolarConstants.batteries[_batteryType]!;
  bool get hasBattery => _systemType != 'On-Grid';

  // Setters
  void updateSystemType(String val) { _systemType = val; _calculate(); }
  void updateSystemSize(double val) { _systemSize = val; _calculate(); }
  void updateDailyConsumption(double val) { _dailyConsumption = val; _calculate(); }
  void updateDayUsagePct(double val) { _dayUsagePct = val; _calculate(); }
  void updateLocation(double lat, double lng) { _lat = lat; _lng = lng; _calculate(); }
  void updateGridRate(double val) { _gridRate = val; _calculate(); }
  void updateInstallCost(double val) { _installCost = val; _calculate(); }
  void updatePanelDegradation(double val) { _panelDegradation = val; _calculate(); }
  void updateVoltage(int val) { _voltage = val; _calculate(); }
  void updateBatteryType(String val) { _batteryType = val; _calculate(); }
  void updateBatteryCapacity(double val) { _batteryCapacity = val; _calculate(); }
  void updateHybridStrategy(String val) { _hybridStrategy = val; _calculate(); }
  void updateSystemLosses(double val) { _systemLosses = val; _calculate(); }
  void updateOverrideCost(double? val) { _overrideCost = val; _calculate(); }
  void updateOverrideSubsidy(double? val) { _overrideSubsidy = val; _calculate(); }

  void _calculate() {
    // 1. Costs
    final panelPrice = _systemType == 'On-Grid' ? SolarConstants.panels['DCR']! : SolarConstants.panels['NonDCR']!;
    final panelCost = _systemSize * 1000 * panelPrice;

    String invKey = 'GridTie';
    if (_systemType == 'Hybrid') {
      invKey = 'Hybrid';
    } else if (_systemType == 'Off-Grid') {
      invKey = 'OffGrid';
    }

    bool isBatt = hasBattery;
    final actualBatteryCap = isBatt ? _batteryCapacity : 0.0;
    final batteryCost = actualBatteryCap * batterySpec.pricePerKWh;

    final estPanelInvCost = panelCost + (_systemSize * SolarConstants.inverters[invKey]!);
    final estTotalCost = estPanelInvCost + batteryCost + _installCost;
    final totalSystemCost = _overrideCost ?? estTotalCost;

    // Subsidy
    final estSubsidy = SolarConstants.calculateSubsidy(_systemSize, _systemType, panelCost);
    final subsidy = _overrideSubsidy ?? estSubsidy;
    final netInvestment = totalSystemCost - subsidy;

    // Generation
    final efficiencyFactor = (1 - _systemLosses / 100);
    final annualGenBase = _systemSize * psh * 365 * efficiencyFactor; // kWh/yr

    // Battery Replacement
    final calLife = batterySpec.calendarLife;
    List<int> batteryReplacementYears = [];
    if (isBatt) {
      for (int y = calLife; y <= 25; y += calLife) {
        batteryReplacementYears.add(y);
      }
    }

    // 25 year projection
    List<double> cumulativeCost = [];
    List<double> cumulativeReturns = [];
    double costSoFar = netInvestment;
    double returnsSoFar = 0;
    double annualBattCosts = 0;
    int? breakEvenYear;

    for (int y = 1; y <= 25; y++) {
      bool isBattReplace = isBatt && y % calLife == 0 && y != 0;
      if (isBattReplace) {
        costSoFar += batteryCost;
        annualBattCosts += batteryCost;
      }

      double degradedGen = annualGenBase * pow(1 - _panelDegradation / 100, y - 1);
      double yearlySaving = 0;

      if (_systemType == 'Off-Grid') {
        double effectiveDailyStorage = actualBatteryCap * batterySpec.dod;
        double nightCons = _dailyConsumption * (1 - _dayUsagePct / 100);
        double nightCovered = min(nightCons, effectiveDailyStorage);
        double dayCons = _dailyConsumption * (_dayUsagePct / 100);
        double dayGen = min(degradedGen / 365, dayCons);
        yearlySaving = (dayGen + nightCovered) * 365 * _gridRate;
      } else if (_systemType == 'Hybrid') {
        double selfConsumption = min(degradedGen, _dailyConsumption * 365);
        double exportAmt = max(0, degradedGen - _dailyConsumption * 365);
        double exportRate = _hybridStrategy == 'Max Savings' ? _gridRate * 0.9 : _gridRate * 0.5;
        yearlySaving = selfConsumption * _gridRate + exportAmt * exportRate;
      } else {
        yearlySaving = min(degradedGen, _dailyConsumption * 365) * _gridRate;
      }

      returnsSoFar += yearlySaving;
      cumulativeCost.add(costSoFar);
      cumulativeReturns.add(returnsSoFar);

      if (breakEvenYear == null && returnsSoFar >= costSoFar) {
        breakEvenYear = y;
      }
    }

    final lifetimeSavings = cumulativeReturns[24] - cumulativeCost[24];
    final selfSufficiency = min(100.0, (annualGenBase / (_dailyConsumption * 365)) * 100.0);
    final dcYield = _systemSize * psh * 365;
    final acOutput = dcYield * efficiencyFactor;
    final unmetLoad = max(0.0, _dailyConsumption * 365 - acOutput);

    _results = SolarResults(
      totalSystemCost: totalSystemCost,
      subsidy: subsidy,
      netInvestment: netInvestment,
      lifetimeSavings: lifetimeSavings,
      breakEvenYear: breakEvenYear,
      annualBattCosts: annualBattCosts,
      batteryReplacementYears: batteryReplacementYears,
      cumulativeCost: cumulativeCost,
      cumulativeReturns: cumulativeReturns,
      dcYield: dcYield,
      acOutput: acOutput,
      selfSufficiency: selfSufficiency,
      unmetLoad: unmetLoad,
      annualGenBase: annualGenBase,
      estTotalCost: estTotalCost,
      estSubsidy: estSubsidy,
    );
    notifyListeners();
  }
}
