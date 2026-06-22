import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'vehicles/vehicles_screen.dart';
import 'fuel/fuel_logs_screen.dart';
import 'expenses/expenses_screen.dart';
import 'profile/profile_screen.dart';
import '../../routes/app_routes.dart';
import '../../presentation/providers/dashboard_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isMenuOpen = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  void _closeMenu() {
    if (_isMenuOpen) {
      setState(() {
        _isMenuOpen = false;
        _animController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Tab content - IndexedStack keeps all screens alive
          IndexedStack(
            index: _currentIndex,
            children: const [
              DashboardScreen(),
              VehiclesScreen(),
              FuelLogsScreen(),
              ExpensesScreen(),
              ProfileScreen(),
            ],
          ),
          // Semi-transparent backdrop when FAB menu is open
          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeMenu,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.black.withOpacity(0.45)),
              ),
            ),
          // Speed dial + main FAB
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Speed dial items (animated)
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: _isMenuOpen
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _SpeedDialItem(
                              heroTag: 'fab_vehicle',
                              icon: Icons.directions_car,
                              label: 'Add Vehicle',
                              color: const Color(0xFF1565C0),
                              onTap: () async {
                                _closeMenu();
                                final added = await Navigator.pushNamed(
                                    context, AppRoutes.addVehicle);
                                if (added == true && mounted) {
                                  context
                                      .read<DashboardProvider>()
                                      .loadDashboard();
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            _SpeedDialItem(
                              heroTag: 'fab_fuel',
                              icon: Icons.local_gas_station,
                              label: 'Add Fuel Log',
                              color: const Color(0xFFE65100),
                              onTap: () async {
                                _closeMenu();
                                final added = await Navigator.pushNamed(
                                    context, AppRoutes.addFuel);
                                if (added == true && mounted) {
                                  context
                                      .read<DashboardProvider>()
                                      .loadDashboard();
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            _SpeedDialItem(
                              heroTag: 'fab_expense',
                              icon: Icons.receipt_long,
                              label: 'Add Expense',
                              color: const Color(0xFF2E7D32),
                              onTap: () async {
                                _closeMenu();
                                final added = await Navigator.pushNamed(
                                    context, AppRoutes.addExpense);
                                if (added == true && mounted) {
                                  context
                                      .read<DashboardProvider>()
                                      .loadDashboard();
                                }
                              },
                            ),
                            const SizedBox(height: 14),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                // Main FAB
                FloatingActionButton(
                  heroTag: 'main_fab',
                  onPressed: _toggleMenu,
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  child: AnimatedRotation(
                    turns: _isMenuOpen ? 0.125 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.add, size: 28),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          _closeMenu();
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Vehicles',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_gas_station_outlined),
            selectedIcon: Icon(Icons.local_gas_station),
            label: 'Fuel',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _SpeedDialItem extends StatelessWidget {
  final String heroTag;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SpeedDialItem({
    required this.heroTag,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(10),
          color: theme.colorScheme.surface,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          heroTag: heroTag,
          onPressed: onTap,
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 3,
          child: Icon(icon, size: 20),
        ),
      ],
    );
  }
}
