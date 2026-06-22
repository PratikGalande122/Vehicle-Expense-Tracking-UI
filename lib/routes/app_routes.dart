import 'package:flutter/material.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/verify_otp_screen.dart';
import '../presentation/screens/main_screen.dart';
import '../presentation/screens/vehicles/add_vehicle_screen.dart';
import '../presentation/screens/fuel/add_fuel_screen.dart';
import '../presentation/screens/fuel/edit_fuel_screen.dart';
import '../presentation/screens/expenses/add_expense_screen.dart';
import '../presentation/screens/expenses/edit_expense_screen.dart';
import '../presentation/screens/profile/edit_profile_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/settings/payment_methods_screen.dart';
import '../data/models/fuel_log_model.dart';
import '../data/models/expense_model.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String verifyOtp = '/verify-otp';
  static const String main = '/main';
  static const String addVehicle = '/add-vehicle';
  static const String addFuel = '/add-fuel';
  static const String editFuel = '/edit-fuel';
  static const String addExpense = '/add-expense';
  static const String editExpense = '/edit-expense';
  static const String editProfile = '/edit-profile';
  static const String settingsRoute = '/settings';
  static const String paymentMethods = '/payment-methods';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case verifyOtp:
        final args = settings.arguments as Map<String, String?>?;
        return MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(
            email: args?['email'] ?? '',
            devOtp: args?['devOtp'],
          ),
        );

      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case addVehicle:
        return MaterialPageRoute(builder: (_) => const AddVehicleScreen());

      case addFuel:
        return MaterialPageRoute(builder: (_) => const AddFuelScreen());

      case editFuel:
        final log = settings.arguments as FuelLogModel;
        return MaterialPageRoute(
            builder: (_) => EditFuelScreen(fuelLog: log));

      case addExpense:
        return MaterialPageRoute(builder: (_) => const AddExpenseScreen());

      case editExpense:
        final expense = settings.arguments as ExpenseModel;
        return MaterialPageRoute(
            builder: (_) => EditExpenseScreen(expense: expense));

      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case paymentMethods:
        return MaterialPageRoute(builder: (_) => const PaymentMethodsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
