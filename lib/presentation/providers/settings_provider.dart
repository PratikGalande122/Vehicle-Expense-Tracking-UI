import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _service;

  SettingsProvider(this._service);

  // ── State ──────────────────────────────────────────────────────────────────
  String _themeMode       = 'system';
  String _currencyCode    = 'INR';
  String _odometerUnit    = 'Kilometres';
  String _volumeUnit      = 'Litres';
  String _consumptionUnit = 'km/l';
  String _dateFormat      = 'DD/MM/YYYY';
  String? _homeCity;
  List<String> _paymentMethods = List.from(SettingsService.defaultPaymentMethods);

  // ── Getters ────────────────────────────────────────────────────────────────
  String get themeMode       => _themeMode;
  String get currencyCode    => _currencyCode;
  String get odometerUnit    => _odometerUnit;
  String get volumeUnit      => _volumeUnit;
  String get consumptionUnit => _consumptionUnit;
  String get dateFormat      => _dateFormat;
  String? get homeCity       => _homeCity;
  List<String> get paymentMethods => List.unmodifiable(_paymentMethods);

  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case 'dark':  return ThemeMode.dark;
      case 'light': return ThemeMode.light;
      default:      return ThemeMode.system;
    }
  }

  /// Returns a NumberFormat using the stored currency code.
  /// e.g. INR → ₹, USD → $, EUR → €
  NumberFormat get currencyFormat =>
      NumberFormat.simpleCurrency(name: _currencyCode);

  /// Short currency symbol only (e.g. '₹', '$')
  String get currencySymbol =>
      NumberFormat.simpleCurrency(name: _currencyCode).currencySymbol;

  /// Intl-compatible date pattern derived from the stored display format.
  String get datePattern {
    switch (_dateFormat) {
      case 'MM/DD/YYYY':   return 'MM/dd/yyyy';
      case 'YYYY-MM-DD':   return 'yyyy-MM-dd';
      case 'D MMM YYYY':   return 'd MMM yyyy';
      default:             return 'dd/MM/yyyy'; // DD/MM/YYYY
    }
  }

  /// Short date string for a given [DateTime] using the stored format.
  String formatDate(DateTime d) => DateFormat(datePattern).format(d);

  /// Abbreviation for the odometer unit (km / mi).
  String get odometerAbbr => _odometerUnit == 'Miles' ? 'mi' : 'km';

  /// Abbreviation for the volume unit (L / gal).
  String get volumeAbbr => _volumeUnit == 'Gallons' ? 'gal' : 'L';

  // ── Load all settings from storage ────────────────────────────────────────
  Future<void> load() async {
    _themeMode       = await _service.getThemeMode();
    _currencyCode    = await _service.getCurrencyCode();
    _odometerUnit    = await _service.getOdometerUnit();
    _volumeUnit      = await _service.getVolumeUnit();
    _consumptionUnit = await _service.getConsumptionUnit();
    _dateFormat      = await _service.getDateFormat();
    _homeCity        = await _service.getHomeCity();
    _paymentMethods  = await _service.getPaymentMethods();
    notifyListeners();
  }

  // ── Setters ────────────────────────────────────────────────────────────────
  Future<void> setThemeMode(String v) async {
    _themeMode = v;
    await _service.setThemeMode(v);
    notifyListeners();
  }

  Future<void> setCurrencyCode(String v) async {
    _currencyCode = v;
    await _service.setCurrencyCode(v);
    notifyListeners();
  }

  Future<void> setOdometerUnit(String v) async {
    _odometerUnit = v;
    await _service.setOdometerUnit(v);
    notifyListeners();
  }

  Future<void> setVolumeUnit(String v) async {
    _volumeUnit = v;
    await _service.setVolumeUnit(v);
    notifyListeners();
  }

  Future<void> setConsumptionUnit(String v) async {
    _consumptionUnit = v;
    await _service.setConsumptionUnit(v);
    notifyListeners();
  }

  Future<void> setDateFormat(String v) async {
    _dateFormat = v;
    await _service.setDateFormat(v);
    notifyListeners();
  }

  Future<void> setHomeCity(String v) async {
    _homeCity = v;
    await _service.setHomeCity(v);
    notifyListeners();
  }

  Future<void> clearHomeCity() async {
    _homeCity = null;
    await _service.clearHomeCity();
    notifyListeners();
  }

  // ── Payment methods ────────────────────────────────────────────────────────
  Future<void> addPaymentMethod(String method) async {
    final m = method.trim();
    if (m.isEmpty || _paymentMethods.contains(m)) return;
    _paymentMethods = [..._paymentMethods, m];
    await _service.setPaymentMethods(_paymentMethods);
    notifyListeners();
  }

  Future<void> removePaymentMethod(String method) async {
    _paymentMethods = _paymentMethods.where((e) => e != method).toList();
    await _service.setPaymentMethods(_paymentMethods);
    notifyListeners();
  }
}
