import '../../models/user.dart';
import '../db/app_database.dart';

class UserRepository {
  final AppDatabase _db = AppDatabase();

  Future<String> insertUser(User user) async {
    final db = await _db.database;
    await db.insert('users', user.toMap());
    return user.id;
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await _db.database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<User?> getUserByPin(String pin) async {
    final db = await _db.database;
    final maps = await db.query(
      'users',
      where: 'pin = ?',
      whereArgs: [pin],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<bool> validateCredentials(String username, String pin) async {
    final user = await getUserByUsername(username);
    return user != null && user.pin == pin;
  }

  Future<bool> validatePin(String pin) async {
    final user = await getUserByPin(pin);
    return user != null;
  }
}

