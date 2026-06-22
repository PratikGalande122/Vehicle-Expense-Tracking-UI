import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/vehicle_repository.dart';
import 'data/repositories/fuel_repository.dart';
import 'data/repositories/expense_repository.dart';
import 'data/repositories/dashboard_repository.dart';
import 'data/services/settings_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/providers/vehicle_provider.dart';
import 'presentation/providers/fuel_provider.dart';
import 'presentation/providers/expense_provider.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'presentation/providers/selected_vehicle_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'routes/app_routes.dart';

/// Global navigator key used by the Dio interceptor to redirect to login on 401.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure the 401 → login redirect before injecting into the widget tree.
  ApiClient().setOnUnauthorized(() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  });

  runApp(const VehicleExpenseApp());
}

class VehicleExpenseApp extends StatefulWidget {
  const VehicleExpenseApp({super.key});

  @override
  State<VehicleExpenseApp> createState() => _VehicleExpenseAppState();
}

class _VehicleExpenseAppState extends State<VehicleExpenseApp> {
  late final SettingsProvider _settingsProvider;

  @override
  void initState() {
    super.initState();
    _settingsProvider = SettingsProvider(SettingsService());
    _settingsProvider.load();
  }

  @override
  Widget build(BuildContext context) {
    // Create the singleton ApiClient once and share it with all repositories.
    final apiClient = ApiClient();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _settingsProvider),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthRepository(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(UserRepository(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => VehicleProvider(VehicleRepository(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => FuelProvider(FuelRepository(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(ExpenseRepository(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(DashboardRepository(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => SelectedVehicleProvider(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Vehicle Expense Tracker',
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          themeMode: settings.flutterThemeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1565C0),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: const Color(0xFF1565C0).withOpacity(0.08),
                ),
              ),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1565C0),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
          ),
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.generateRoute,
        ),
      ),
    );
  }
}
