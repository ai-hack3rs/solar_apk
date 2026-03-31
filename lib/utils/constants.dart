import 'dart:math';

class BatterySpec {
  final String label;
  final int pricePerKWh;
  final int cycles;
  final int calendarLife;
  final double dod;
  final double efficiency;
  final double selfDischarge;

  const BatterySpec({
    required this.label,
    required this.pricePerKWh,
    required this.cycles,
    required this.calendarLife,
    required this.dod,
    required this.efficiency,
    required this.selfDischarge,
  });
}

class SolarConstants {
  static const int year = 2025;
  static const String currency = '₹';

  static const Map<String, int> panels = {
    'DCR': 30, // ₹ per Watt
    'NonDCR': 22, // ₹ per Watt
  };

  static const Map<String, int> inverters = {
    'GridTie': 8, // ₹ per Watt
    'Hybrid': 15,
    'OffGrid': 10,
  };

  static const Map<String, BatterySpec> batteries = {
    'LiFePO4': BatterySpec(
      label: 'LiFePO4 (Lithium Iron Phosphate)',
      pricePerKWh: 15000,
      cycles: 3000,
      calendarLife: 15,
      dod: 0.90,
      efficiency: 0.97,
      selfDischarge: 0.01,
    ),
    'LeadAcid': BatterySpec(
      label: 'Lead Acid (VRLA Sealed)',
      pricePerKWh: 7000,
      cycles: 1000,
      calendarLife: 5,
      dod: 0.50,
      efficiency: 0.80,
      selfDischarge: 0.03,
    ),
  };

  static const Map<String, int> subsidy = {
    'upTo1kW': 30000,
    'upTo2kW': 60000,
    'upTo3kW': 78000,
    'above3kW': 78000,
  };

  static const Map<String, double> efficiency = {
    'mppt': 0.97,
    'inverter': 0.95,
    'wiring': 0.98,
    'soiling': 0.97,
  };

  static double calculatePSH(double lat) {
    final absLat = lat.abs();
    if (absLat <= 15) return 5.8;
    if (absLat <= 20) return 5.5;
    if (absLat <= 25) return 5.5;
    if (absLat <= 30) return 5.0;
    if (absLat <= 35) return 4.5;
    return max(3.0, 5.5 - (absLat / 90) * 2);
  }

  static double calculateSubsidy(num sizeKW, String systemType, num panelCost) {
    if (systemType == 'Off-Grid') return 0.0;
    if (sizeKW <= 1) return subsidy['upTo1kW']!.toDouble();
    if (sizeKW <= 2) return subsidy['upTo2kW']!.toDouble();
    if (sizeKW <= 3) return subsidy['upTo3kW']!.toDouble();
    return subsidy['above3kW']!.toDouble();
  }

  static String formatINR(num amount, {bool compact = true}) {
    if (!compact) {
      // Basic formatting without intl package for simplicity
      return '₹${amount.toStringAsFixed(0)}';
    }
    final abs = amount.abs();
    if (abs >= 10000000) return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    if (abs >= 100000) return '₹${(amount / 100000).toStringAsFixed(2)} L';
    if (abs >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }
}
