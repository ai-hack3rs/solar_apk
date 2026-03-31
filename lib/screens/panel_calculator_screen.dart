import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../widgets/result_card.dart';
import '../widgets/animated_sun.dart';

class PanelCalculatorScreen extends StatefulWidget {
  const PanelCalculatorScreen({super.key});

  @override
  State<PanelCalculatorScreen> createState() => _PanelCalculatorScreenState();
}

class _PanelCalculatorScreenState extends State<PanelCalculatorScreen> {
  bool _calculated = false;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CalculatorProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFFFB300)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          const Icon(Icons.wb_sunny_rounded, color: Color(0xFFFFB300), size: 22),
          const SizedBox(width: 8),
          const Text(
            'Panel Output',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inputs Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E35),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x33FFB300)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AnimatedSun(size: 28),
                      const SizedBox(width: 10),
                      const SectionHeader(
                        title: 'System Parameters',
                        subtitle: 'Configure your solar setup',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SliderRow(
                    label: 'Panel Wattage',
                    value: p.panelWatts,
                    min: 100,
                    max: 700,
                    divisions: 60,
                    displayValue: '${p.panelWatts.toInt()} W',
                    onChanged: (v) => p.setPanelWatts(v),
                  ),
                  const SizedBox(height: 8),
                  SliderRow(
                    label: 'Number of Panels',
                    value: p.panelCount.toDouble(),
                    min: 1,
                    max: 100,
                    divisions: 99,
                    displayValue: '${p.panelCount}',
                    onChanged: (v) => p.setPanelCount(v.toInt()),
                  ),
                  const SizedBox(height: 8),
                  SliderRow(
                    label: 'Peak Sun Hours / Day',
                    value: p.peakSunHours,
                    min: 1.0,
                    max: 9.0,
                    divisions: 16,
                    displayValue: '${p.peakSunHours.toStringAsFixed(1)} hrs',
                    onChanged: (v) => p.setPeakSunHours(v),
                  ),
                  const SizedBox(height: 8),
                  SliderRow(
                    label: 'System Efficiency',
                    value: p.systemEfficiency,
                    min: 0.60,
                    max: 0.95,
                    divisions: 35,
                    displayValue: '${(p.systemEfficiency * 100).toInt()}%',
                    onChanged: (v) => p.setSystemEfficiency(v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Peak sun hours hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF252540),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF888899)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'India avg: 4–6 hrs/day | North: 5–6 | South: 5.5–6.5 | Coastal: 4–5',
                      style: TextStyle(fontSize: 11, color: Color(0xFF888899)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  p.calculatePanelOutput();
                  setState(() => _calculated = true);
                },
                icon: const Icon(Icons.calculate_rounded),
                label: const Text('Calculate Output'),
              ),
            ),
            if (_calculated && p.panelResult != null) ...[
              const SizedBox(height: 28),
              const GradientDivider(),
              const SizedBox(height: 20),
              const SectionHeader(
                title: 'Results',
                subtitle: 'Based on your configuration',
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  ResultCard(
                    label: 'Peak Power',
                    value: p.panelResult!.peakPowerKw.toStringAsFixed(2),
                    unit: 'kilowatts (kW)',
                    icon: Icons.flash_on_rounded,
                    accentColor: const Color(0xFFFFB300),
                  ),
                  ResultCard(
                    label: 'Daily Generation',
                    value: p.panelResult!.dailyKwh.toStringAsFixed(2),
                    unit: 'kWh per day',
                    icon: Icons.wb_sunny_rounded,
                    accentColor: const Color(0xFFFF8F00),
                  ),
                  ResultCard(
                    label: 'Monthly Generation',
                    value: p.panelResult!.monthlyKwh.toStringAsFixed(1),
                    unit: 'kWh per month',
                    icon: Icons.calendar_month_rounded,
                    accentColor: const Color(0xFF42A5F5),
                  ),
                  ResultCard(
                    label: 'Annual Generation',
                    value: p.panelResult!.annualKwh.toStringAsFixed(0),
                    unit: 'kWh per year',
                    icon: Icons.bar_chart_rounded,
                    accentColor: const Color(0xFF66BB6A),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // CO2 Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00251A), Color(0xFF1E1E35)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x4466BB6A)),
                ),
                child: Row(
                  children: [
                    const Text('🌍', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CO₂ Offset',
                            style: TextStyle(color: Color(0xFF888899), fontSize: 12),
                          ),
                          Text(
                            '${(p.panelResult!.co2OffsetKgPerYear / 1000).toStringAsFixed(2)} tonnes/year',
                            style: const TextStyle(
                              color: Color(0xFF66BB6A),
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '≈ ${(p.panelResult!.co2OffsetKgPerYear / 200).toStringAsFixed(0)} trees planted equivalent',
                            style: const TextStyle(
                              color: Color(0xFF666680),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ],
        ),
      ),
    );
  }
}
