import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/selected_vehicle_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../../data/models/expense_model.dart';
import '../../../routes/app_routes.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  Future<void> _confirmDelete(
      BuildContext ctx, ExpenseModel expense) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        title: const Text('Delete Expense'),
        content:
            Text('Delete "${expense.description}" expense?'),
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
      final provider = ctx.read<ExpenseProvider>();
      final success = await provider.deleteExpense(expense.id);
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Expense deleted'
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
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<ExpenseProvider>().loadExpenses(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.addExpense),
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.expenses.isEmpty) {
            return const LoadingIndicator(message: 'Loading expenses...');
          }

          final selectedVehicle =
              context.watch<SelectedVehicleProvider>().selectedVehicle;
          final filtered = selectedVehicle == null
              ? provider.expenses
              : provider.expenses
                  .where((e) => e.vehicleId == selectedVehicle.id)
                  .toList();

          if (filtered.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: 'No Expenses Yet',
              subtitle: selectedVehicle != null
                  ? 'No expenses for ${selectedVehicle.displayName}.'
                  : 'Track your vehicle maintenance and other costs.',
              onAction: () =>
                  Navigator.pushNamed(context, AppRoutes.addExpense),
              actionLabel: 'Add Expense',
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadExpenses,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final expense = filtered[index];
                return Slidable(
                  key: ValueKey(expense.id),
                  startActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (_) async {
                          final result = await Navigator.pushNamed(
                            context,
                            AppRoutes.editExpense,
                            arguments: expense,
                          );
                          if (result == true && context.mounted) {
                            context.read<ExpenseProvider>().loadExpenses();
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
                        onPressed: (_) =>
                            _confirmDelete(context, expense),
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
                  child:
                      _ExpenseCard(expense: expense, currency: currency),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final NumberFormat currency;

  const _ExpenseCard({required this.expense, required this.currency});

  static const Map<String, Color> _categoryColors = {
    'Maintenance': Color(0xFF1565C0),
    'Repair': Color(0xFFAD1457),
    'Insurance': Color(0xFF2E7D32),
    'Registration': Color(0xFF6A1B9A),
    'Parking': Color(0xFFE65100),
    'Tolls': Color(0xFF00695C),
    'Cleaning': Color(0xFF37474F),
    'Other': Color(0xFF5D4037),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    final df = DateFormat(settings.datePattern);
    final color =
        _categoryColors[expense.category] ?? const Color(0xFF5D4037);

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
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.receipt_long, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          expense.category,
                          style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (expense.vehicleName != null &&
                          expense.vehicleName!.isNotEmpty) ...[
                        Icon(Icons.directions_car_outlined,
                            size: 13,
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.45)),
                        const SizedBox(width: 3),
                        Text(
                          expense.vehicleName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.55)),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        df.format(expense.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.45)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              currency.format(expense.amount),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
