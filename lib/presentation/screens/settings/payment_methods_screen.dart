import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Payment Method'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g. Paytm, PhonePe, NEFT',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) {
            _add(ctx, controller.text);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _add(ctx, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _add(BuildContext ctx, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    context.read<SettingsProvider>().addPaymentMethod(trimmed);
    Navigator.pop(ctx);
  }

  Future<void> _confirmDelete(String method) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Payment Method'),
        content: Text('Remove "$method" from your list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<SettingsProvider>().removePaymentMethod(method);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          final all = settings.paymentMethods;
          final filtered = _query.isEmpty
              ? all
              : all
                  .where((m) =>
                      m.toLowerCase().contains(_query.toLowerCase()))
                  .toList();

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    isDense: true,
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              if (filtered.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.credit_card_off_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.3)),
                        const SizedBox(height: 12),
                        Text(
                          _query.isEmpty
                              ? 'No payment methods yet'
                              : 'No results for "$_query"',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final method = filtered[i];
                      return ListTile(
                        leading: Icon(
                          _iconForMethod(method),
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(method),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline,
                              color: theme.colorScheme.error),
                          onPressed: () => _confirmDelete(method),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  IconData _iconForMethod(String method) {
    final m = method.toLowerCase();
    if (m.contains('credit')) return Icons.credit_card;
    if (m.contains('debit')) return Icons.credit_card_outlined;
    if (m.contains('cash') || m.contains('money')) return Icons.payments_outlined;
    if (m.contains('upi') || m.contains('gpay') || m.contains('paytm') ||
        m.contains('phonepe')) return Icons.phone_android_outlined;
    if (m.contains('neft') || m.contains('imps') || m.contains('rtgs')) {
      return Icons.account_balance_outlined;
    }
    return Icons.payment_outlined;
  }
}
