import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  /// Base URL selection:
  ///   - Web (Chrome/Edge at http://localhost:4200) → uses http to avoid mixed-content;
  ///     add "http://localhost:4200" to your .NET CORS AllowedOrigins.
  ///   - Android emulator → 10.0.2.2 maps to host machine's localhost.
  ///   - iOS / Windows desktop → https://localhost:7257.
  static String get baseUrl {
    if (kIsWeb) {
      // Browser running at http://localhost:4200 — must use HTTP port 5201,
      // because port 7257 is HTTPS-only. The API also listens on http://localhost:5201.
      return 'http://localhost:5201/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'https://10.0.2.2:7257/api';
    }
    return 'https://localhost:7257/api';
  }

  // Auth
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';

  // User
  static const String userProfile = '/user/profile';
  static const String userAccount = '/user/account';

  // Vehicles
  static const String vehicles = '/vehicles';
  static String vehicleById(String id) => '/vehicles/$id';

  // Fuel
  static const String fuel = '/fuel';
  static String fuelById(String id) => '/fuel/$id';

  // Expenses
  static const String expenses = '/expenses';
  static String expenseById(String id) => '/expenses/$id';

  // Dashboard
  static const String dashboard = '/dashboard';
}
