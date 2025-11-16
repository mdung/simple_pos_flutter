import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? get currentUser => _authService.currentUser;
  bool get isAuthenticated => _authService.isAuthenticated;

  Future<bool> loginWithPin(String pin) async {
    final success = await _authService.loginWithPin(pin);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  Future<bool> loginWithUsername(String username, String pin) async {
    final success = await _authService.loginWithUsername(username, pin);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  Future<void> initialize() async {
    await _authService.createDefaultUser();
  }
}

