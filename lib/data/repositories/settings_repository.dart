import '../../models/settings.dart';
import '../db/app_database.dart';

class SettingsRepository {
  final AppDatabase _db = AppDatabase();
  static const String defaultSettingsId = 'default';

  Future<Settings> getSettings() async {
    final db = await _db.database;
    final maps = await db.query(
      'settings',
      where: 'id = ?',
      whereArgs: [defaultSettingsId],
    );
    if (maps.isEmpty) {
      // Return default settings
      return Settings(
        id: defaultSettingsId,
        shopName: 'My Shop',
        taxRate: 0.0,
        currencySymbol: '\$',
      );
    }
    return Settings.fromMap(maps.first);
  }

  Future<void> saveSettings(Settings settings) async {
    final db = await _db.database;
    await db.insert(
      'settings',
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

