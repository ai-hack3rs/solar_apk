import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/calculator_provider.dart';
import '../models/calculation_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CalculatorProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFFFFB300)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Calculation History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (p.history.isNotEmpty)
            TextButton.icon(
              onPressed: () => _confirmClear(context, p),
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFFF7043), size: 18),
              label: const Text(
                'Clear',
                style: TextStyle(color: Color(0xFFFF7043), fontSize: 13),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: p.history.isEmpty
          ? const _EmptyHistory()
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: p.history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _HistoryCard(calc: p.history[i]),
            ),
    );
  }

  void _confirmClear(BuildContext context, CalculatorProvider p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear History',
            style: TextStyle(color: Colors.white)),
        content: const Text('Delete all saved calculations?',
            style: TextStyle(color: Color(0xFFAAAAAA))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFFAAAAAA))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7043),
                foregroundColor: Colors.white),
            onPressed: () {
              p.clearHistory();
              Navigator.pop(context);
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_rounded,
            size: 64,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          const Text(
            'No calculations yet',
            style: TextStyle(
              color: Color(0xFF888899),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Run a calculation to see it here',
            style: TextStyle(color: Color(0xFF555570), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final SolarCalculation calc;
  const _HistoryCard({required this.calc});

  @override
  Widget build(BuildContext context) {
    final isPanelCalc = calc.type == 'panel_output';
    final color =
        isPanelCalc ? const Color(0xFFFFB300) : const Color(0xFF66BB6A);
    final icon =
        isPanelCalc ? Icons.wb_sunny_rounded : Icons.savings_rounded;
    final fmt = DateFormat('dd MMM yyyy, hh:mm a');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPanelCalc ? 'Panel Output' : 'Savings Estimate',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    fmt.format(calc.createdAt),
                    style: const TextStyle(
                      color: Color(0xFF666680),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2A2A45)),
          const SizedBox(height: 8),
          if (isPanelCalc) ..._panelSummary(calc.results, color)
          else ..._savingsSummary(calc.results, color),
        ],
      ),
    );
  }

  List<Widget> _panelSummary(Map<String, dynamic> r, Color color) => [
        _Row('Daily', '${(r['dailyKwh'] as num).toStringAsFixed(2)} kWh', color),
        _Row('Monthly', '${(r['monthlyKwh'] as num).toStringAsFixed(1)} kWh', color),
        _Row('Annual', '${(r['annualKwh'] as num).toStringAsFixed(0)} kWh', color),
        _Row('CO₂ Offset', '${((r['co2OffsetKgPerYear'] as num) / 1000).toStringAsFixed(2)} T/yr', const Color(0xFF66BB6A)),
      ];

  List<Widget> _savingsSummary(Map<String, dynamic> r, Color color) => [
        _Row('Monthly Savings', '₹${(r['monthlyBill'] as num).toStringAsFixed(0)}', color),
        _Row('Annual Savings', '₹${(r['annualSavings'] as num).toStringAsFixed(0)}', color),
        _Row('Payback', '${(r['paybackYears'] as num).toStringAsFixed(1)} years', const Color(0xFFFFB300)),
        _Row('25-yr ROI', '${(r['roi25Years'] as num).toStringAsFixed(0)}%', const Color(0xFF42A5F5)),
      ];
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Row(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: Color(0xFF888899))),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
