import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../widgets/animated_sun.dart';
import 'panel_calculator_screen.dart';
import 'savings_calculator_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _HeroCard(),
                const SizedBox(height: 28),
                const _QuickStatsRow(),
                const SizedBox(height: 28),
                const _FeatureGrid(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0F0F1E),
      pinned: true,
      expandedHeight: 0,
      title: Row(
        children: [
          const AnimatedSun(size: 32),
          const SizedBox(width: 10),
          const Text(
            'Solar Calculator',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFFFFB300),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          ),
          icon: const Icon(Icons.history_rounded, color: Color(0xFFAAAAAA)),
          tooltip: 'History',
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1F00), Color(0xFF1A1A35)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x44FFB300), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Power Your Future',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Calculate solar output, savings & payback period for your home.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFFFB300).withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    '☀️ Clean Energy • 💰 Save Money • 🌍 Save Planet',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFFFB300),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const AnimatedSun(size: 80),
        ],
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CalculatorProvider>();
    final kw = (p.panelWatts * p.panelCount / 1000).toStringAsFixed(1);
    final daily = (p.panelWatts * p.panelCount / 1000 *
            p.peakSunHours *
            p.systemEfficiency)
        .toStringAsFixed(1);

    return Row(
      children: [
        _StatChip(
          value: '$kw kW',
          label: 'System Size',
          icon: Icons.solar_power_rounded,
          color: const Color(0xFFFFB300),
        ),
        const SizedBox(width: 12),
        _StatChip(
          value: '$daily kWh',
          label: 'Est. Daily',
          icon: Icons.bolt_rounded,
          color: const Color(0xFF66BB6A),
        ),
        const SizedBox(width: 12),
        _StatChip(
          value: '${p.panelCount}x',
          label: 'Panels',
          icon: Icons.grid_view_rounded,
          color: const Color(0xFF42A5F5),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF888899),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    final cards = [
      _FeatureCardData(
        title: 'Panel Output\nCalculator',
        subtitle: 'Daily, monthly & annual kWh generation',
        icon: Icons.wb_sunny_rounded,
        gradient: const [Color(0xFF2A1800), Color(0xFF1E1E35)],
        borderColor: const Color(0xFFFFB300),
        screen: const PanelCalculatorScreen(),
      ),
      _FeatureCardData(
        title: 'Savings &\nPayback',
        subtitle: 'ROI, payback period & lifetime savings',
        icon: Icons.savings_rounded,
        gradient: const [Color(0xFF001A10), Color(0xFF1E1E35)],
        borderColor: const Color(0xFF66BB6A),
        screen: const SavingsCalculatorScreen(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Calculators',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        ...cards.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _FeatureCard(data: c),
            )),
      ],
    );
  }
}

class _FeatureCardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Color borderColor;
  final Widget screen;

  const _FeatureCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.borderColor,
    required this.screen,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureCardData data;
  const _FeatureCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return PulsingGlow(
      glowColor: data.borderColor,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => data.screen),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: data.gradient,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: data.borderColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: data.borderColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(data.icon, color: data.borderColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888899),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: data.borderColor.withValues(alpha: 0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
