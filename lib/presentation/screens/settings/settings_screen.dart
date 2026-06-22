import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../../routes/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            children: [
              // ── Appearance ──────────────────────────────────────────────
              _SectionHeader(title: 'Appearance'),
              _SettingsTile(
                icon: Icons.brightness_6_outlined,
                title: 'Theme Mode',
                subtitle: _label(settings.themeMode, {
                  'system': 'System Default',
                  'light': 'Light',
                  'dark': 'Dark',
                }),
                onTap: () => _showOptions(
                  context,
                  title: 'Theme Mode',
                  options: const ['system', 'light', 'dark'],
                  labels: const ['System Default', 'Light', 'Dark'],
                  current: settings.themeMode,
                  onSelected: settings.setThemeMode,
                ),
              ),

              // ── Regional ────────────────────────────────────────────────
              _SectionHeader(title: 'Regional'),
              _SettingsTile(
                icon: Icons.attach_money,
                title: 'Default Currency',
                subtitle: settings.currencyCode,
                onTap: () => _showOptions(
                  context,
                  title: 'Currency Code',
                  options: const ['INR', 'USD', 'EUR', 'GBP', 'AED', 'SGD', 'JPY'],
                  labels: const ['INR – Indian Rupee', 'USD – US Dollar', 'EUR – Euro', 'GBP – British Pound', 'AED – Dirham', 'SGD – Singapore Dollar', 'JPY – Japanese Yen'],
                  current: settings.currencyCode,
                  onSelected: settings.setCurrencyCode,
                ),
              ),
              _SettingsTile(
                icon: Icons.calendar_today_outlined,
                title: 'Date Format',
                subtitle: settings.dateFormat,
                onTap: () => _showOptions(
                  context,
                  title: 'Date Format',
                  options: const ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD', 'D MMM YYYY'],
                  labels: const ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD', 'D MMM YYYY'],
                  current: settings.dateFormat,
                  onSelected: settings.setDateFormat,
                ),
              ),

              // ── Vehicle ──────────────────────────────────────────────────
              _SectionHeader(title: 'Vehicle Units'),
              _SettingsTile(
                icon: Icons.speed_outlined,
                title: 'Odometer Unit',
                subtitle: settings.odometerUnit,
                onTap: () => _showOptions(
                  context,
                  title: 'Odometer Unit',
                  options: const ['Kilometres', 'Miles'],
                  labels: const ['Kilometres (km)', 'Miles (mi)'],
                  current: settings.odometerUnit,
                  onSelected: settings.setOdometerUnit,
                ),
              ),
              _SettingsTile(
                icon: Icons.water_drop_outlined,
                title: 'Default Volume Unit',
                subtitle: settings.volumeUnit,
                onTap: () => _showOptions(
                  context,
                  title: 'Volume Unit',
                  options: const ['Litres', 'Gallons'],
                  labels: const ['Litres (L)', 'Gallons (gal)'],
                  current: settings.volumeUnit,
                  onSelected: settings.setVolumeUnit,
                ),
              ),
              _SettingsTile(
                icon: Icons.local_gas_station_outlined,
                title: 'Average Consumption',
                subtitle: settings.consumptionUnit,
                onTap: () => _showOptions(
                  context,
                  title: 'Consumption Unit',
                  options: const ['km/l', 'l/100km', 'mpg'],
                  labels: const ['km/l', 'l/100km', 'mpg'],
                  current: settings.consumptionUnit,
                  onSelected: settings.setConsumptionUnit,
                ),
              ),

              // ── Location ─────────────────────────────────────────────────
              _SectionHeader(title: 'Location'),
              _SettingsTile(
                icon: Icons.location_city_outlined,
                title: 'Home City',
                subtitle: settings.homeCity ?? 'Not set',
                onTap: () => showHomeCitySheet(context),
              ),

              // ── Payment methods ──────────────────────────────────────────
              _SectionHeader(title: 'Records'),
              _SettingsTile(
                icon: Icons.credit_card_outlined,
                title: 'Payment Methods',
                subtitle: '${settings.paymentMethods.length} methods',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, AppRoutes.paymentMethods),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  String _label(String value, Map<String, String> map) => map[value] ?? value;

  void _showOptions(
    BuildContext context, {
    required String title,
    required List<String> options,
    required List<String> labels,
    required String current,
    required Future<void> Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                title,
                style: Theme.of(ctx)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ...List.generate(options.length, (i) {
              final isSelected = options[i] == current;
              return ListTile(
                title: Text(labels[i]),
                trailing: isSelected
                    ? Icon(Icons.check,
                        color: Theme.of(ctx).colorScheme.primary)
                    : null,
                onTap: () {
                  onSelected(options[i]);
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Home City bottom sheet (standalone function so dashboard can call it too)
void showHomeCitySheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _HomeCitySheet(),
  );
}

class _HomeCitySheet extends StatefulWidget {
  const _HomeCitySheet();
  @override
  State<_HomeCitySheet> createState() => _HomeCitySheetState();
}

class _HomeCitySheetState extends State<_HomeCitySheet> {
  final _controller = TextEditingController();
  String _query = '';

  static const _cities = [
    'Ahmedabad', 'Bangalore', 'Chennai', 'Gurugram', 'Hyderabad', 'Jaipur',
    'Kolkata', 'Lucknow', 'Mumbai', 'New Delhi', 'Noida', 'Pune', 'Surat',
    'Bhopal', 'Chandigarh', 'Coimbatore', 'Indore', 'Kochi', 'Nagpur',
    'Patna', 'Thiruvananthapuram', 'Vadodara', 'Visakhapatnam',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(String city) {
    context.read<SettingsProvider>().setHomeCity(city);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Home city set to $city'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _cities
        .where((c) => c.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    final current = context.watch<SettingsProvider>().homeCity;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Set Your Home City',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter location...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 8),
          // Current location row
          ListTile(
            leading: const Icon(Icons.my_location, color: Color(0xFF1565C0)),
            title: const Text('Choose your current location'),
            onTap: () {
              // GPS not implemented — show a snack
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('GPS location not available on web'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const Divider(height: 1),
          // City chips
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: filtered.map((city) {
                  final isSelected = city == current;
                  return FilterChip(
                    label: Text(city),
                    selected: isSelected,
                    onSelected: (_) => _select(city),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Reusable section header ───────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Settings list tile ────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.55)),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.35)),
      onTap: onTap,
    );
  }
}
