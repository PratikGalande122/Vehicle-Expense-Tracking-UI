import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../routes/app_routes.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleProvider>().loadVehicles();
    });
  }

  Future<void> _confirmDelete(BuildContext ctx, VehicleModel vehicle) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text(
            'Delete "${vehicle.displayName}"? This may also remove associated fuel logs and expenses.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && ctx.mounted) {
      final provider = ctx.read<VehicleProvider>();
      final success = await provider.deleteVehicle(vehicle.id);
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(success
                ? '${vehicle.displayName} deleted'
                : provider.error ?? 'Failed to delete'),
            backgroundColor: success ? null : Theme.of(ctx).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => context.read<VehicleProvider>().loadVehicles(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Vehicle',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.addVehicle),
          ),
        ],
      ),
      body: Consumer<VehicleProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.vehicles.isEmpty) {
            return const LoadingIndicator(message: 'Loading vehicles...');
          }

          if (provider.vehicles.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.directions_car_outlined,
              title: 'No Vehicles Yet',
              subtitle: 'Add your first vehicle to start tracking expenses.',
              onAction: () =>
                  Navigator.pushNamed(context, AppRoutes.addVehicle),
              actionLabel: 'Add Vehicle',
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadVehicles,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: provider.vehicles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final vehicle = provider.vehicles[index];
                return Slidable(
                  key: ValueKey(vehicle.id),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (_) => _confirmDelete(context, vehicle),
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
                  child: _VehicleCard(vehicle: vehicle),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;

  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.directions_car,
                  color: theme.colorScheme.primary, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.displayName,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.badge_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Text(vehicle.licensePlate,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.65))),
                      if (vehicle.fuelType != null) ...[
                        const SizedBox(width: 10),
                        Icon(Icons.local_gas_station_outlined,
                            size: 14,
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.5)),
                        const SizedBox(width: 4),
                        Text(vehicle.fuelType!,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.65))),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (vehicle.createdAt != null)
              Text(
                DateFormat('MMM yyyy').format(vehicle.createdAt!),
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.4)),
              ),
          ],
        ),
      ),
    );
  }
}
