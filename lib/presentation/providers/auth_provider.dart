import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider(this._repository);

  bool _isLoading = false;
  String? _error;
  String? _devOtp;
  String? _pendingEmail;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get devOtp => _devOtp;
  String? get pendingEmail => _pendingEmail;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> sendOtp({
    required String email,
    required String fullName,
  }) async {
    _isLoading = true;
    _error = null;
    _pendingEmail = email;
    notifyListeners();

    try {
      _devOtp = await _repository.sendOtp(email: email, fullName: fullName);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.verifyOtp(email: email, otp: otp);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _devOtp = null;
    _pendingEmail = null;
    notifyListeners();
  }
}
