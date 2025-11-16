import 'package:flutter/foundation.dart';
import '../models/settings.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  Settings? _settings;
  bool _isLoading = false;

  Settings? get settings => _settings;
  bool get isLoading => _isLoading;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    try {
      _settings = await _settingsService.getSettings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveSettings(Settings settings) async {
    await _settingsService.saveSettings(settings);
    _settings = settings;
    notifyListeners();
  }

  Future<void> updateShopInfo({
    required String shopName,
    String? address,
    String? phone,
  }) async {
    await _settingsService.updateShopInfo(
      shopName: shopName,
      address: address,
      phone: phone,
    );
    await loadSettings();
  }

  Future<void> updateTaxRate(double taxRate) async {
    await _settingsService.updateTaxRate(taxRate);
    await loadSettings();
  }

  Future<void> updateCurrencySymbol(String symbol) async {
    await _settingsService.updateCurrencySymbol(symbol);
    await loadSettings();
  }
}

