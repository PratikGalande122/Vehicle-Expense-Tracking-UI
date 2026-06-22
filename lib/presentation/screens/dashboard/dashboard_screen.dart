import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/selected_vehicle_provider.dart';
import '../../providers/settings_provider.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/models/vehicle_model.dart';
import '../../widgets/loading_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  static const List<Color> _chartColors = [
    Color(0xFF1565C0),
    Color(0xFFE65100),
    Color(0xFF2E7D32),
    Color(0xFF6A1B9A),
    Color(0xFFAD1457),
    Color(0xFF00695C),
    Color(0xFFF57F17),
    Color(0xFF37474F),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsProvider>().currencyFormat;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                context.read<DashboardProvider>().loadDashboard(),
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.dashboard == null) {
            return const LoadingIndicator(message: 'Loading dashboard...');
          }

          if (provider.error != null && provider.dashboard == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 12),
                  Text(provider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.error)),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => provider.loadDashboard(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final dashboard = provider.dashboard;
          final selectedVehicle =
              context.watch<SelectedVehicleProvider>().selectedVehicle;

          // Find matching vehicle summary if one is selected
          VehicleSummary? vehicleSummary;
          if (selectedVehicle != null && dashboard != null) {
            vehicleSummary = dashboard.vehicleSummaries
                .cast<VehicleSummary?>()
                .firstWhere(
                  (s) => s?.vehicleId == selectedVehicle.id,
                  orElse: () => null,
                );
          }

          return RefreshIndicator(
            onRefresh: provider.loadDashboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Vehicle Selector ─────────────────────────────────
                  _VehicleSelector(),
                  const SizedBox(height: 16),
                  // ── Summary cards (filtered or total) ────────────────
                  if (selectedVehicle != null && vehicleSummary != null)
                    _buildVehicleFilteredCards(
                        context, selectedVehicle, vehicleSummary, theme, currency)
                  else
                    _buildSummaryCards(context, dashboard, theme, currency),
                  const SizedBox(height: 24),
                  // ── Expense breakdown chart (total only) ─────────────
                  if (selectedVehicle == null &&
                      dashboard != null &&
                      dashboard.expenseBreakdown.isNotEmpty) ...[
                    Text('Expense Breakdown',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildPieChart(
                        context, dashboard.expenseBreakdown, theme, currency),
                    const SizedBox(height: 24),
                  ],
                  // ── Vehicle summaries list ────────────────────────────
                  if (dashboard != null &&
                      dashboard.vehicleSummaries.isNotEmpty) ...[
                    Text(
                      selectedVehicle != null
                          ? 'Vehicle Summary'
                          : 'All Vehicles',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildVehicleSummaries(
                        context,
                        selectedVehicle != null && vehicleSummary != null
                            ? [vehicleSummary]
                            : dashboard.vehicleSummaries,
                        theme,
                        currency),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, DashboardModel? dashboard,
      ThemeData theme, NumberFormat currency) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.directions_car,
                label: 'Vehicles',
                value: '${dashboard?.totalVehicles ?? 0}',
                color: const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.local_gas_station,
                label: 'Fuel Cost',
                value: currency.format(dashboard?.totalFuelCost ?? 0),
                color: const Color(0xFFE65100),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.receipt_long,
                label: 'Expense Cost',
                value: currency.format(dashboard?.totalExpenseCost ?? 0),
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.account_balance_wallet,
                label: 'Total Spent',
                value: currency.format(dashboard?.totalCost ?? 0),
                color: const Color(0xFF6A1B9A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPieChart(BuildContext context,
      List<ExpenseBreakdown> breakdown, ThemeData theme, NumberFormat currency) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 220,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: breakdown.asMap().entries.map((entry) {
                          final color = _chartColors[
                              entry.key % _chartColors.length];
                          return PieChartSectionData(
                            value: entry.value.amount,
                            title:
                                '${entry.value.percentage.toStringAsFixed(0)}%',
                            color: color,
                            radius: 75,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList(),
                        centerSpaceRadius: 36,
                        sectionsSpace: 2,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Legend
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: breakdown.asMap().entries.map((entry) {
                      final color =
                          _chartColors[entry.key % _chartColors.length];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              entry.value.category,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSummaries(BuildContext context,
      List<VehicleSummary> summaries, ThemeData theme, NumberFormat currency) {
    return Column(
      children: summaries
          .map((s) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.directions_car,
                            color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.vehicleName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              'Fuel: ${currency.format(s.totalFuelCost)}  •  '
                              'Expenses: ${currency.format(s.totalExpenseCost)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currency.format(s.totalCost),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            'Total',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildVehicleFilteredCards(
    BuildContext context,
    VehicleModel vehicle,
    VehicleSummary summary,
    ThemeData theme,
    NumberFormat currency,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.local_gas_station,
                label: 'Fuel Cost',
                value: currency.format(summary.totalFuelCost),
                color: const Color(0xFFE65100),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.receipt_long,
                label: 'Expense Cost',
                value: currency.format(summary.totalExpenseCost),
                color: const Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.account_balance_wallet,
                label: 'Total Spent',
                value:
                    currency.format(summary.totalFuelCost + summary.totalExpenseCost),
                color: const Color(0xFF6A1B9A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.local_fire_department_outlined,
                label: 'Fuel Entries',
                value: '${summary.fuelLogCount}',
                color: const Color(0xFF1565C0),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal scrolling chip group for vehicle filtering
class _VehicleSelector extends StatelessWidget {
  const _VehicleSelector();

  @override
  Widget build(BuildContext context) {
    return Consumer2<VehicleProvider, SelectedVehicleProvider>(
      builder: (context, vp, svp, _) {
        if (vp.vehicles.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // "All" chip
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('All'),
                  selected: svp.selectedVehicle == null,
                  onSelected: (_) => svp.clearSelection(),
                ),
              ),
              ...vp.vehicles.map(
                (v) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(v.displayName),
                    selected: svp.selectedVehicle?.id == v.id,
                    onSelected: (_) => svp.select(v),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
