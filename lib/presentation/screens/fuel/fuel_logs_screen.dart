import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/fuel_provider.dart';
import '../../providers/selected_vehicle_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../../data/models/fuel_log_model.dart';
import '../../../routes/app_routes.dart';

class FuelLogsScreen extends StatefulWidget {
  const FuelLogsScreen({super.key});

  @override
  State<FuelLogsScreen> createState() => _FuelLogsScreenState();
}

class _FuelLogsScreenState extends State<FuelLogsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FuelProvider>().loadFuelLogs();
    });
  }

  Future<void> _confirmDelete(
      BuildContext ctx, FuelLogModel log) async {
    final df = DateFormat('MMM d, yyyy');
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        title: const Text('Delete Fuel Log'),
        content: Text(
            'Delete fuel log from ${df.format(log.date)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dCtx, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && ctx.mounted) {
      final provider = ctx.read<FuelProvider>();
      final success = await provider.deleteFuelLog(log.id);
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Fuel log deleted'
                : provider.error ?? 'Failed to delete'),
            backgroundColor:
                success ? null : Theme.of(ctx).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsProvider>().currencyFormat;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<FuelProvider>().loadFuelLogs(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.addFuel),
          ),
        ],
      ),
      body: Consumer<FuelProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.fuelLogs.isEmpty) {
            return const LoadingIndicator(message: 'Loading fuel logs...');
          }

          final selectedVehicle =
              context.watch<SelectedVehicleProvider>().selectedVehicle;
          final filtered = selectedVehicle == null
              ? provider.fuelLogs
              : provider.fuelLogs
                  .where((l) => l.vehicleId == selectedVehicle.id)
                  .toList();

          if (filtered.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.local_gas_station_outlined,
              title: 'No Fuel Logs Yet',
              subtitle: selectedVehicle != null
                  ? 'No logs for ${selectedVehicle.displayName}.'
                  : 'Start tracking your fuel fill-ups.',
              onAction: () =>
                  Navigator.pushNamed(context, AppRoutes.addFuel),
              actionLabel: 'Add Fuel Log',
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadFuelLogs,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final log = filtered[index];
                return Slidable(
                  key: ValueKey(log.id),
                  startActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (_) async {
                          final result = await Navigator.pushNamed(
                            context,
                            AppRoutes.editFuel,
                            arguments: log,
                          );
                          if (result == true && context.mounted) {
                            context.read<FuelProvider>().loadFuelLogs();
                          }
                        },
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (_) => _confirmDelete(context, log),
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: Colors.white,
                        icon: Icons.delete_outline,
                        label: 'Delete',
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                    ],
                  ),
                  child: _FuelLogCard(log: log, currency: currency),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _FuelLogCard extends StatelessWidget {
  final FuelLogModel log;
  final NumberFormat currency;

  const _FuelLogCard({required this.log, required this.currency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    final df = DateFormat(settings.datePattern);
    final odomAbbr = settings.odometerAbbr;
    final volAbbr = settings.volumeAbbr;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE65100).withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.local_gas_station,
                  color: Color(0xFFE65100), size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (log.vehicleName != null && log.vehicleName!.isNotEmpty)
                    Text(
                      log.vehicleName!,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  Text(
                    df.format(log.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withOpacity(0.55)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${log.liters.toStringAsFixed(2)} $volAbbr',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        '  •  ${currency.format(log.pricePerLiter)}/$volAbbr',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.55)),
                      ),
                    ],
                  ),
                  if (log.odometer != null)
                    Text(
                      '${log.odometer!.toStringAsFixed(0)} $odomAbbr',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.5)),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currency.format(log.totalCost),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE65100),
                  ),
                ),
                Text(
                  'Total',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
