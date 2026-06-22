import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // ── Keys ─────────────────────────────────────────────────────────────────
  static const _kThemeMode       = 'settings_theme_mode';
  static const _kCurrencyCode    = 'settings_currency_code';
  static const _kOdometerUnit    = 'settings_odometer_unit';
  static const _kVolumeUnit      = 'settings_volume_unit';
  static const _kConsumptionUnit = 'settings_consumption_unit';
  static const _kDateFormat      = 'settings_date_format';
  static const _kHomeCity        = 'settings_home_city';
  static const _kPaymentMethods  = 'settings_payment_methods';

  // ── Defaults ──────────────────────────────────────────────────────────────
  static const defaultPaymentMethods = ['Cash', 'Credit Card', 'Debit Card', 'UPI'];

  // ── Singleton prefs accessor ───────────────────────────────────────────────
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ── Theme ─────────────────────────────────────────────────────────────────
  Future<String> getThemeMode() async =>
      (await _prefs).getString(_kThemeMode) ?? 'system';
  Future<void> setThemeMode(String v) async =>
      (await _prefs).setString(_kThemeMode, v);

  // ── Currency ──────────────────────────────────────────────────────────────
  Future<String> getCurrencyCode() async =>
      (await _prefs).getString(_kCurrencyCode) ?? 'INR';
  Future<void> setCurrencyCode(String v) async =>
      (await _prefs).setString(_kCurrencyCode, v);

  // ── Odometer unit ─────────────────────────────────────────────────────────
  Future<String> getOdometerUnit() async =>
      (await _prefs).getString(_kOdometerUnit) ?? 'Kilometres';
  Future<void> setOdometerUnit(String v) async =>
      (await _prefs).setString(_kOdometerUnit, v);

  // ── Volume unit ───────────────────────────────────────────────────────────
  Future<String> getVolumeUnit() async =>
      (await _prefs).getString(_kVolumeUnit) ?? 'Litres';
  Future<void> setVolumeUnit(String v) async =>
      (await _prefs).setString(_kVolumeUnit, v);

  // ── Average consumption unit ───────────────────────────────────────────────
  Future<String> getConsumptionUnit() async =>
      (await _prefs).getString(_kConsumptionUnit) ?? 'km/l';
  Future<void> setConsumptionUnit(String v) async =>
      (await _prefs).setString(_kConsumptionUnit, v);

  // ── Date format ───────────────────────────────────────────────────────────
  Future<String> getDateFormat() async =>
      (await _prefs).getString(_kDateFormat) ?? 'DD/MM/YYYY';
  Future<void> setDateFormat(String v) async =>
      (await _prefs).setString(_kDateFormat, v);

  // ── Home city ─────────────────────────────────────────────────────────────
  Future<String?> getHomeCity() async =>
      (await _prefs).getString(_kHomeCity);
  Future<void> setHomeCity(String v) async =>
      (await _prefs).setString(_kHomeCity, v);
  Future<void> clearHomeCity() async =>
      (await _prefs).remove(_kHomeCity);

  // ── Payment methods ───────────────────────────────────────────────────────
  Future<List<String>> getPaymentMethods() async {
    final raw = (await _prefs).getString(_kPaymentMethods);
    if (raw == null) return List.from(defaultPaymentMethods);
    try {
      return List<String>.from(jsonDecode(raw) as List);
    } catch (_) {
      return List.from(defaultPaymentMethods);
    }
  }

  Future<void> setPaymentMethods(List<String> methods) async =>
      (await _prefs).setString(_kPaymentMethods, jsonEncode(methods));
}
