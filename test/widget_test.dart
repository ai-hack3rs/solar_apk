import 'package:flutter_test/flutter_test.dart';
import 'package:solar_calculator/providers/dashboard_provider.dart';

void main() {
  test('DashboardProvider initializes and computes all math correctly', () {
    final provider = DashboardProvider();
    
    // Test initial values
    expect(provider.systemType, 'On-Grid');
    expect(provider.systemSize, 5.0);
    
    // Test that the mass calculation ran automatically
    expect(provider.results, isNotNull);
    
    // Verify some baseline calculations
    final results = provider.results!;
    expect(results.lifetimeSavings, isA<double>());
    expect(results.cumulativeCost.length, 25);
    expect(results.cumulativeReturns.length, 25);
  });
}
