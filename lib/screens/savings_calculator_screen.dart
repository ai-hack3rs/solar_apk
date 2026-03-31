import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../widgets/result_card.dart';

class SavingsCalculatorScreen extends StatefulWidget {
  const SavingsCalculatorScreen({super.key});

  @override
  State<SavingsCalculatorScreen> createState() =>
      _SavingsCalculatorScreenState();
}

class _SavingsCalculatorScreenState extends State<SavingsCalculatorScreen> {
  bool _calculated = false;
  final _costController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final p = context.read<CalculatorProvider>();
    _costController.text = p.systemCostInr.toInt().toString();
  }

  @override
  void dispose() {
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CalculatorProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF66BB6A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(children: [
          Icon(Icons.savings_rounded, color: Color(0xFF66BB6A), size: 22),
          SizedBox(width: 8),
          Text(
            'Savings & Payback',
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
            // System Config Summary
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF252540),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.solar_power_rounded,
                      color: Color(0xFFFFB300), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Using: ${p.panelCount} × ${p.panelWatts.toInt()}W panels | ${p.peakSunHours}h/day',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Financial Inputs
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E35),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x3366BB6A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Financial Parameters',
                    subtitle: 'Enter your electricity costs',
                  ),
                  const SizedBox(height: 24),
                  SliderRow(
                    label: 'Electricity Tariff',
                    value: p.tariffPerKwh,
                    min: 1.0,
                    max: 20.0,
                    divisions: 190,
                    displayValue: '₹${p.tariffPerKwh.toStringAsFixed(1)}/kWh',
                    onChanged: (v) => p.setTariffPerKwh(v),
                    activeColor: const Color(0xFF66BB6A),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'System Installation Cost',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFCCCCDD),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _costController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: const TextStyle(
                          color: Color(0xFF66BB6A),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          prefixText: '₹ ',
                          prefixStyle: const TextStyle(
                            color: Color(0xFF66BB6A),
                            fontWeight: FontWeight.w700,
                          ),
                          hintText: '350000',
                          helperText:
                              'India avg: ₹40,000–70,000 per kW installed',
                          helperStyle: const TextStyle(
                            color: Color(0xFF666680),
                            fontSize: 11,
                          ),
                        ),
                        onChanged: (v) {
                          final val = double.tryParse(v);
                          if (val != null) p.setSystemCost(val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF66BB6A),
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  p.calculateSavings();
                  setState(() => _calculated = true);
                },
                icon: const Icon(Icons.calculate_rounded),
                label: const Text('Calculate Savings'),
              ),
            ),

            if (_calculated && p.savingsResult != null) ...[
              const SizedBox(height: 28),
              const GradientDivider(),
              const SizedBox(height: 20),
              const SectionHeader(title: 'Financial Results'),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
                children: [
                  ResultCard(
                    label: 'Monthly Savings',
                    value: '₹${p.savingsResult!.monthlyBill.toStringAsFixed(0)}',
                    unit: 'per month',
                    icon: Icons.calendar_today_rounded,
                    accentColor: const Color(0xFF66BB6A),
                  ),
                  ResultCard(
                    label: 'Annual Savings',
                    value: '₹${_formatLakh(p.savingsResult!.annualSavings)}',
                    unit: 'per year',
                    icon: Icons.trending_up_rounded,
                    accentColor: const Color(0xFF42A5F5),
                  ),
                  ResultCard(
                    label: 'Payback Period',
                    value: p.savingsResult!.paybackYears.isFinite
                        ? '${p.savingsResult!.paybackYears.toStringAsFixed(1)} yrs'
                        : '∞',
                    unit: 'break even point',
                    icon: Icons.access_time_rounded,
                    accentColor: const Color(0xFFFFB300),
                  ),
                  ResultCard(
                    label: '25-Year ROI',
                    value: '${p.savingsResult!.roi25Years.toStringAsFixed(0)}%',
                    unit: 'return on investment',
                    icon: Icons.percent_rounded,
                    accentColor: const Color(0xFFFF7043),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Lifetime savings banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF001A2A), Color(0xFF1A1A35)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x4442A5F5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '25-Year Lifetime Savings',
                      style: TextStyle(
                        color: Color(0xFF888899),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${_formatLakh(p.savingsResult!.lifetimeSavings)}',
                      style: const TextStyle(
                        color: Color(0xFF42A5F5),
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'After recovering ₹${_formatLakh(p.systemCostInr)} investment',
                      style: const TextStyle(
                        color: Color(0xFF666680),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PaybackTimeline(
                      paybackYears: p.savingsResult!.paybackYears,
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

  String _formatLakh(double value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(2)} Cr';
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)} L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}

class _PaybackTimeline extends StatelessWidget {
  final double paybackYears;
  const _PaybackTimeline({required this.paybackYears});

  @override
  Widget build(BuildContext context) {
    final clamped = paybackYears.clamp(0, 25).toDouble();
    final fraction = clamped / 25.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Payback Timeline (25 yr)',
              style: TextStyle(fontSize: 12, color: Color(0xFF888899)),
            ),
            Text(
              paybackYears.isFinite
                  ? '${paybackYears.toStringAsFixed(1)} years'
                  : 'N/A',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFFFB300),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: const Color(0xFF333355),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Year 0', style: TextStyle(fontSize: 10, color: Color(0xFF666680))),
            Text('Year 25', style: TextStyle(fontSize: 10, color: Color(0xFF666680))),
          ],
        ),
      ],
    );
  }
}
