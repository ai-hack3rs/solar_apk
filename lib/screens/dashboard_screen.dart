import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../providers/dashboard_provider.dart';
import '../utils/constants.dart';
import '../widgets/app_styles.dart';
import '../widgets/financial_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient Orbs (mapped from index.css)
          Positioned(
            top: -200,
            left: -200,
            child: Container(
              width: 800,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -200,
            right: -200,
            child: Container(
              width: 600,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.success.withValues(alpha: 0.08),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ),
          // Main Scroll View
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const _Card1SystemUsage(),
                    const SizedBox(height: 20),
                    const _Card2LocationFinancials(),
                    const SizedBox(height: 20),
                    const _Card3TechSpecs(),
                    const SizedBox(height: 24),
                    const _ResultsSection(),
                    const SizedBox(height: 80), // bottom padding
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      pinned: true,
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withValues(alpha: 0.2),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.warning, AppColors.gold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: const Center(
              child: Text('☀️', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'SolarBharat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Calculator',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              Text(
                'Professional Lifetime ROI Analyzer',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// INPUT CARD 1: System & Usage
// ---------------------------------------------------------
class _Card1SystemUsage extends StatelessWidget {
  const _Card1SystemUsage();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DashboardProvider>();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(icon: '⚡', title: 'System & Usage'),
          SolarInput(
            label: 'System Type',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withValues(alpha: 0.05),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: p.systemType,
                  isExpanded: true,
                  dropdownColor: AppColors.background,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  items: ['On-Grid', 'Off-Grid', 'Hybrid'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) => context.read<DashboardProvider>().updateSystemType(val!),
                ),
              ),
            ),
          ),
          // System Size Slider
          SolarInput(
            label: 'System Size (kW)',
            hint: 'Typical residential: 1-10 kW',
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: p.systemSize,
                    min: 0.5,
                    max: 50.0,
                    divisions: 99,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.white.withValues(alpha: 0.1),
                    onChanged: (val) => context.read<DashboardProvider>().updateSystemSize(val),
                  ),
                ),
                Text('${p.systemSize.toStringAsFixed(1)} kW',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
              ],
            ),
          ),
          // Daily Consumption Slider
          SolarInput(
            label: 'Daily Consumption (kWh)',
            hint: 'Check your electricity bill',
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: p.dailyConsumption,
                    min: 1,
                    max: 100,
                    divisions: 99,
                    activeColor: AppColors.primary,
                    onChanged: (val) => context.read<DashboardProvider>().updateDailyConsumption(val),
                  ),
                ),
                Text('${p.dailyConsumption.toStringAsFixed(1)} kWh',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Day-time Usage
          SolarInput(
            label: 'Day-time Usage %',
            hint: 'What % of load runs during daylight hours',
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: p.dayUsagePct,
                    min: 10,
                    max: 100,
                    divisions: 18,
                    activeColor: AppColors.primaryLight,
                    onChanged: (val) => context.read<DashboardProvider>().updateDayUsagePct(val),
                  ),
                ),
                Text('${p.dayUsagePct.toInt()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// INPUT CARD 2: Location & Financials
// ---------------------------------------------------------
class _Card2LocationFinancials extends StatelessWidget {
  const _Card2LocationFinancials();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DashboardProvider>();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: '📍',
            title: 'Location & Financials',
            badge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '☀️ PSH ${p.psh.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 10, color: AppColors.gold, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SolarInput(
            label: 'Location Picker',
            hint: 'Tap to place marker (Lat: ${p.lat.toStringAsFixed(2)}, Lng: ${p.lng.toStringAsFixed(2)})',
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(p.lat, p.lng),
                    initialZoom: 4,
                    onTap: (tapPosition, point) {
                      context.read<DashboardProvider>().updateLocation(point.latitude, point.longitude);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.solar.bharat',
                      // Dark mode map simulation like index.css filter
                      tileBuilder: (context, widget, tile) {
                        return ColorFiltered(
                          colorFilter: const ColorFilter.matrix([
                            // Basic dark filter to blend with dark mode
                            -1, 0, 0, 0, 255,
                            0, -1, 0, 0, 255,
                            0, 0, -1, 0, 255,
                            0, 0, 0, 1, 0,
                          ]),
                          child: widget,
                        );
                      },
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(p.lat, p.lng),
                          width: 40,
                          height: 40,
                          child: const _MapMarker(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SolarInput(
            label: 'Grid Rate (₹/kWh)',
            hint: 'Your current electricity tariff',
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: p.gridRate,
                    min: 1,
                    max: 20,
                    divisions: 38,
                    activeColor: AppColors.primary,
                    onChanged: (val) => context.read<DashboardProvider>().updateGridRate(val),
                  ),
                ),
                Text('₹${p.gridRate.toStringAsFixed(1)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gold,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.5),
            blurRadius: 10,
          )
        ],
      ),
      alignment: Alignment.center,
      child: const Text('☀️', style: TextStyle(fontSize: 16)),
    );
  }
}

// ---------------------------------------------------------
// INPUT CARD 3: Tech Specs
// ---------------------------------------------------------
class _Card3TechSpecs extends StatelessWidget {
  const _Card3TechSpecs();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DashboardProvider>();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(icon: '🔋', title: 'Tech Specs'),
          if (p.hasBattery) ...[
            SolarInput(
              label: 'Battery Capacity (kWh)',
              child: Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: p.batteryCapacity,
                      min: 1,
                      max: 30,
                      divisions: 29,
                      activeColor: AppColors.success,
                      onChanged: (val) => context.read<DashboardProvider>().updateBatteryCapacity(val),
                    ),
                  ),
                  Text('${p.batteryCapacity.toStringAsFixed(1)} kWh',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
                ],
              ),
            ),
          ] else ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Battery settings not applicable for On-Grid systems.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// RESULTS SECTION
// ---------------------------------------------------------
class _ResultsSection extends StatelessWidget {
  const _ResultsSection();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DashboardProvider>();
    final r = p.results;

    if (r == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Total Investment Banner
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              const Text(
                'NET INVESTMENT (AFTER SUBSIDY)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryLight,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                SolarConstants.formatINR(r.netInvestment, compact: false),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('System Cost: ${SolarConstants.formatINR(r.totalSystemCost)}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(width: 16),
                  Text('Subsidy: -${SolarConstants.formatINR(r.subsidy)}',
                      style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Mini Stats
        Row(
          children: [
            Expanded(
              child: StatDisplay(
                label: 'Lifetime Savings',
                value: SolarConstants.formatINR(r.lifetimeSavings),
                highlight: true,
                color: AppColors.success,
                sub: '25-Year Projection',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatDisplay(
                label: 'Break-Even',
                value: r.breakEvenYear != null ? '${r.breakEvenYear} Years' : 'Never',
                highlight: true,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatDisplay(
                label: 'Daily Generation',
                value: '${(r.annualGenBase/365).toStringAsFixed(1)} kWh',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatDisplay(
                label: 'Self Sufficiency',
                value: '${r.selfSufficiency.toStringAsFixed(0)}%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          '25-Year Projection',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        const GlassCard(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: FinancialChart(),
        ),
      ],
    );
  }
}
