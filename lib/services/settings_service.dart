import '../models/settings.dart';
import '../data/repositories/settings_repository.dart';

class SettingsService {
  final SettingsRepository _repository = SettingsRepository();

  Future<Settings> getSettings() async {
    return await _repository.getSettings();
  }

  Future<void> saveSettings(Settings settings) async {
    await _repository.saveSettings(settings);
  }

  Future<void> updateShopInfo({
    required String shopName,
    String? address,
    String? phone,
  }) async {
    final current = await getSettings();
    final updated = current.copyWith(
      shopName: shopName,
      address: address,
      phone: phone,
    );
    await saveSettings(updated);
  }

  Future<void> updateTaxRate(double taxRate) async {
    final current = await getSettings();
    final updated = current.copyWith(taxRate: taxRate);
    await saveSettings(updated);
  }

  Future<void> updateCurrencySymbol(String symbol) async {
    final current = await getSettings();
    final updated = current.copyWith(currencySymbol: symbol);
    await saveSettings(updated);
  }
}

