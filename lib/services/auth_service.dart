import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../data/repositories/user_repository.dart';

class AuthService {
  final UserRepository _userRepository = UserRepository();
  final Uuid _uuid = const Uuid();

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  Future<bool> loginWithPin(String pin) async {
    final user = await _userRepository.getUserByPin(pin);
    if (user != null) {
      _currentUser = user;
      return true;
    }
    return false;
  }

  Future<bool> loginWithUsername(String username, String pin) async {
    final isValid = await _userRepository.validateCredentials(username, pin);
    if (isValid) {
      final user = await _userRepository.getUserByUsername(username);
      _currentUser = user;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  Future<void> createDefaultUser() async {
    // Check if any user exists
    final existingUser = await _userRepository.getUserByUsername('admin');
    if (existingUser == null) {
      // Create default admin user with PIN 1234
      final defaultUser = User(
        id: _uuid.v4(),
        username: 'admin',
        pin: '1234',
        name: 'Administrator',
        createdAt: DateTime.now(),
      );
      await _userRepository.insertUser(defaultUser);
    }
  }
}

